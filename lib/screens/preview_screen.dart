import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
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

  bool get isPdf => widget.imagePath.toLowerCase().endsWith('.pdf');

  Future<void> convertToPDF() async {
    if (isPdf) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File is already a PDF")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final pdfFile = await _pdfService.createPdfFromImage(
        File(widget.imagePath),
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      _showSuccessDialog("PDF Created", "File saved at: ${pdfFile.path}");
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("PDF Error: $e");
    }
  }

  Future<void> saveToGallery() async {
    if (isPdf) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot save PDF to Gallery directly. Use File Manager.")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);
      final result = await ImageGallerySaver.saveFile(widget.imagePath);
      
      if (!mounted) return;
      setState(() => isLoading = false);

      if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Saved to Gallery Successfully!")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Gallery Save Error: $e");
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Awesome"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Preview Document"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: isPdf
                    ? _buildPdfPreview()
                    : Image.file(File(widget.imagePath), fit: BoxFit.contain),
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildPdfPreview() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.picture_as_pdf_rounded, size: 100, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            widget.imagePath.split('/').last,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text("PDF Document", style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(backgroundColor: Colors.white10),
            ),
          Row(
            children: [
              Expanded(
                child: _buildSmallButton(
                  icon: Icons.refresh_rounded,
                  label: "Retake",
                  color: Colors.white10,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _buildSmallButton(
                  icon: Icons.save_alt_rounded,
                  label: "Save to Gallery",
                  color: const Color(0xFF6366F1),
                  onTap: saveToGallery,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!isPdf)
            SizedBox(
              width: double.infinity,
              child: _buildLargeButton(
                icon: Icons.picture_as_pdf_rounded,
                label: "Export as PDF",
                onTap: convertToPDF,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSmallButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF0F172A), size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
