import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  /// 📄 Create PDF from single image
  Future<File> createPdfFromImage(File imageFile) async {
    try {
      final pdf = pw.Document();

      final imageBytes = await imageFile.readAsBytes();

      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Container(
              margin: const pw.EdgeInsets.all(10),
              child: pw.Center(
                child: pw.Image(
                  pw.MemoryImage(imageBytes),
                  fit: pw.BoxFit.contain,
                ),
              ),
            );
          },
        ),
      );

      return await _savePdfFile(pdf, "scan");
    } catch (e) {
      throw Exception("Single PDF Error: $e");
    }
  }

  /// 📄 Create PDF from multiple images (multi-page)
  Future<File> createPdfFromImages(List<File> images) async {
    try {
      if (images.isEmpty) {
        throw Exception("No images provided");
      }

      final pdf = pw.Document();

      for (var imageFile in images) {
        final imageBytes = await imageFile.readAsBytes();

        pdf.addPage(
          pw.Page(
            build: (context) {
              return pw.Container(
                margin: const pw.EdgeInsets.all(10),
                child: pw.Center(
                  child: pw.Image(
                    pw.MemoryImage(imageBytes),
                    fit: pw.BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        );
      }

      return await _savePdfFile(pdf, "multi_scan");
    } catch (e) {
      throw Exception("Multi PDF Error: $e");
    }
  }

  /// 💾 Save PDF File
  Future<File> _savePdfFile(pw.Document pdf, String name) async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      final filePath =
          "${dir.path}/${name}_${DateTime.now().millisecondsSinceEpoch}.pdf";

      final file = File(filePath);

      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      throw Exception("Save PDF Error: $e");
    }
  }
}
