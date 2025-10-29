import 'dart:io' show Platform;
import 'package:flutter/material.dart';
// Importamos ambos paquetes
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart'; 
import 'package:arkit_plugin/arkit_plugin.dart'; 
import 'package:vector_math/vector_math_64.dart' as vector;

class ARNativeScreen extends StatelessWidget {
  const ARNativeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return const _ARCoreView();
    } else if (Platform.isIOS) {
      return const _ARKitView();
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text("V3: RA Nativa")),
        body: const Center(child: Text("Plataforma no soportada")),
      );
    }
  }
}

// --- WIDGET DE ANDROID (CORREGIDO) ---
class _ARCoreView extends StatefulWidget {
  const _ARCoreView();
  @override
  _ARCoreViewState createState() => _ARCoreViewState();
}

class _ARCoreViewState extends State<_ARCoreView> {
  late ArCoreController arCoreController;

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    arCoreController.onPlaneTap = _onPlaneTap;
  }

  void _onPlaneTap(List<ArCoreHitTestResult> hits) {
    final hit = hits.first;

    // 1. Creamos un material (rojo)
    final material = ArCoreMaterial(color: Colors.red);
    // 2. Creamos una forma (esfera)
    final sphere = ArCoreSphere(materials: [material], radius: 0.1);
    // 3. Creamos el nodo con la forma y la posición del toque
    final node = ArCoreNode(
      shape: sphere,
      position: hit.pose.translation,
    );
    
    // 4. Añadimos el nodo
    arCoreController.addArCoreNode(node);
  }

  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("V3: ARCore (Android)")),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        enableTapRecognizer: true,
        // CORRECCIÓN FINAL (Error 1 y 2)
        // El parámetro correcto es 'enablePlaneRenderer'
        enablePlaneRenderer: true,
      ),
    );
  }
}

// --- WIDGET DE IOS (Este ya estaba bien) ---
class _ARKitView extends StatefulWidget {
  const _ARKitView();
  @override
  _ARKitViewState createState() => _ARKitViewState();
}

class _ARKitViewState extends State<_ARKitView> {
  late ARKitController arkitController;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  void _onARKitViewCreated(ARKitController controller) {
    arkitController = controller;
    arkitController.onARTap = _onARTap;
  }

  void _onARTap(List<ARKitTestResult> results) {
    final hit = results.firstWhere(
      (r) => r.type == ARKitHitTestResultType.existingPlaneUsingExtent,
    );

    final material = ARKitMaterial(
      diffuse: ARKitMaterialProperty.color(Colors.red),
    );
    final sphere = ARKitSphere(materials: [material], radius: 0.1);

    final node = ARKitNode(
      geometry: sphere, 
      position: vector.Vector3(hit.worldTransform.getColumn(3).x,
          hit.worldTransform.getColumn(3).y, hit.worldTransform.getColumn(3).z),
    );
    
    arkitController.add(node);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("V3: ARKit (iOS)")),
      body: ARKitSceneView(
        onARKitViewCreated: _onARKitViewCreated,
        planeDetection: ARPlaneDetection.horizontal,
      ),
    );
  }
}