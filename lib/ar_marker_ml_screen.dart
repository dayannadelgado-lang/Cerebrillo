// lib/ar_marker_ml_screen.dart (CORREGIDO)

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:permission_handler/permission_handler.dart';
import '../ar_viewer_screen.dart'; // Importamos nuestra V1

class ARMarkerMLScreen extends StatefulWidget {
  const ARMarkerMLScreen({super.key});

  @override
  State<ARMarkerMLScreen> createState() => _ARMarkerMLScreenState();
}

class _ARMarkerMLScreenState extends State<ARMarkerMLScreen> {
  CameraController? _cameraController;
  ImageLabeler? _imageLabeler;
  bool _isProcessing = false;
  bool _modelLaunched = false;
  String _detectedLabel = "Apuntando...";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    _imageLabeler?.close();
    super.dispose();
  }

  Future<void> _initialize() async {
    // 1. Pedir permiso de cámara
    if (await Permission.camera.request() != PermissionStatus.granted) {
      debugPrint("Permiso de cámara denegado");
      return;
    }

    // 2. Inicializar el Etiquetador (usaremos el modelo base)
    _imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.7));

    // 3. Inicializar la Cámara
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras.first, ResolutionPreset.medium);
    await _cameraController!.initialize();

    if (!mounted) return;
    setState(() {}); // Para mostrar la vista previa

    // 4. Iniciar el Stream de Imágenes para procesarlas
    _cameraController!.startImageStream(_processCameraImage);
  }

  // Esta función se llama por cada frame de la cámara
  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing || _modelLaunched) return;
    _isProcessing = true;

    // 5. Convertir formato de imagen
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      _isProcessing = false;
      return;
    }

    // 6. Procesar la imagen con ML Kit
    final labels = await _imageLabeler!.processImage(inputImage);

    String bestLabel = "Apuntando...";
    for (var label in labels) {
      debugPrint("ML Kit Vio: ${label.label} (Confianza: ${label.confidence})");
      bestLabel = label.label;

      // 7. ¡ACCIÓN! Si vemos un código QR (nuestro marcador)...
      if (label.label == 'Barcode' || label.label == 'QR Code') {
        _modelLaunched = true;
        _cameraController?.stopImageStream();

        // CORRECCIÓN (Error 3): Añadimos un 'mounted' check
        // antes de usar 'Navigator' en un async gap.
        if (!mounted) {
          _isProcessing = false;
          return;
        }

        // Lanzamos la V1 con el modelo del CORAZÓN
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ARViewerScreen(
              modelUrl: "https://modelviewer.dev/shared-assets/models/Heart.glb",
            ),
          ),
        );

        // Cuando el usuario cierre la V1, reiniciamos
        _modelLaunched = false;
        if (mounted) {
          _cameraController?.startImageStream(_processCameraImage);
        }
        break; // Salir del bucle
      }
    }

    if(mounted) {
      setState(() { _detectedLabel = bestLabel; });
    }
    _isProcessing = false;
  }

  // --- Widget de UI ---
  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    // Muestra la cámara como fondo
    return Scaffold(
      appBar: AppBar(title: const Text("V2: Escáner de Marcadores")),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),
          // Muestra lo que ML Kit está detectando
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              // CORRECCIÓN (Error 4): Reemplazamos 'withOpacity' por 'Colors.black54'
              color: Colors.black54,
              child: Text(
                "Detectando: $_detectedLabel",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          )
        ],
      ),
    );
  }
  
  // --- Función de ayuda para conversión de formato ---
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;
    final camera = _cameraController!.description;
    final sensorOrientation = camera.sensorOrientation;
    
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final InputImageRotation imageRotation =
        InputImageRotationValue.fromRawValue(sensorOrientation) ??
            InputImageRotation.rotation0deg;

    final InputImageFormat inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21;
    
    // CORRECCIÓN (Error 1 y 2):
    // La API solo necesita 'bytesPerRow' del primer plano,
    // no una lista de 'InputImagePlaneMetadata' ni el parámetro 'planeData'.
    final bytesPerRow = image.planes.first.bytesPerRow;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: bytesPerRow, // Solo pasamos esto
        // 'planeData' (Error 2) ya no es un parámetro
      ),
    );
  }
}