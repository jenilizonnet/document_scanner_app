import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/pdf_service.dart';

class PreviewScreen extends StatefulWidget {
  final String imagePath;

  const PreviewScreen({super.key, required this.imagePath});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  bool isLoading = false;

  final PdfService _pdfService = PdfService();

  // 📄 Convert Image to PDF (using service)
  Future<void> convertToPDF() async {
    try {
      setState(() => isLoading = true);

      final pdfFile = await _pdfService.createPdfFromImage(
        File(widget.imagePath),
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("PDF Saved: ${pdfFile.path}")));
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("PDF Error: $e");
    }
  }

  // 💾 Save Image
  Future<void> saveImage() async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      final newPath =
          "${dir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.jpg";

      final newFile = await File(widget.imagePath).copy(newPath);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Image Saved: ${newFile.path}")));
    } catch (e) {
      debugPrint("Save Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Preview"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 📷 Image Preview
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
              ),
            ),
          ),

          // 🔘 Buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: CircularProgressIndicator(),
                  ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 🔁 Retake
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retake"),
                    ),

                    // 💾 Save Image
                    ElevatedButton.icon(
                      onPressed: saveImage,
                      icon: const Icon(Icons.image),
                      label: const Text("Save Image"),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // 📄 Save as PDF
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : convertToPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Save as PDF"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
