import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ARViewerScreen extends StatefulWidget {
  final String modelUrl; // URL del modelo .glb
  final String? iosModelUrl; // URL del modelo .usdz (para iOS)

  const ARViewerScreen({
    super.key,
    required this.modelUrl,
    this.iosModelUrl,
  });

  @override
  State<ARViewerScreen> createState() => _ARViewerScreenState();
}

class _ARViewerScreenState extends State<ARViewerScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final String htmlContent = _buildHtml(widget.modelUrl, widget.iosModelUrl);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() { _isLoading = false; });
          },
        ),
      )
      ..loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Visor de Modelo")),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  // Función clave que genera el HTML con <model-viewer>
  String _buildHtml(String modelUrl, String? iosModelUrl) {
    final String finalIosModel = iosModelUrl ?? modelUrl;
    return '''
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Model Viewer</title>
      <script type="module" src="https://ajax.googleapis.com/ajax/libs/model-viewer/3.5.0/model-viewer.min.js"></script>
      <style>
        body, html { margin: 0; padding: 0; width: 100%; height: 100%; }
        model-viewer { width: 100%; height: 100%; }
      </style>
    </head>
    <body>
      <model-viewer
          src="$modelUrl"
          ios-src="$finalIosModel"
          alt="Modelo 3D"
          ar
          ar-modes="webxr scene-viewer quick-look"
          camera-controls
          autoplay>
          <button slot="ar-button" style="background-color: white; border-radius: 4px; border: 1px solid black; padding: 10px 16px; position: absolute; bottom: 16px; right: 16px;">
              Ver en tu espacio
          </button>
      </model-viewer>
    </body>
    </html>
    ''';
  }
}