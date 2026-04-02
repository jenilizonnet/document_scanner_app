import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../screens/preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool isScanning = false;

  // 📝 Auto Scan Function (FIXED)
  Future<void> startScan() async {
    // 1. Permission
    if (!await Permission.camera.request().isGranted) return;

    try {
      setState(() => isScanning = true);

      // ✅ Scanner Open (Auto detect + crop)
      final List<String>? images = await CunningDocumentScanner.getPictures();

      setState(() => isScanning = false);

      // ✅ Result check
      if (images != null && images.isNotEmpty && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => PreviewScreen(
                  imagePath: images.first, // first scanned image
                ),
          ),
        );
      }
    } catch (e) {
      setState(() => isScanning = false);
      debugPrint("Scan Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Document Scanner"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.document_scanner,
              size: 100,
              color: Colors.white54,
            ),
            const SizedBox(height: 20),

            // 🔘 Button
            ElevatedButton.icon(
              onPressed: isScanning ? null : startScan,
              icon: const Icon(Icons.camera),
              label: Text(isScanning ? "Scanning..." : "Start Auto-Scan"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                "The scanner will automatically detect edges and crop the document for you.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
