import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class ScannerService {
  // ✅ BEST (Stable version)
  final DocumentScanner _scanner = DocumentScanner(
    options: DocumentScannerOptions(),
  );

  /// 📷 Open Scanner UI
  Future<List<String>?> scanDocument() async {
    try {
      final result = await _scanner.scanDocument();

      if (result.images.isEmpty) {
        return null;
      }

      return result.images; // scanned image paths
    } catch (e) {
      debugPrint("Scan Error: $e");
      return null;
    }
  }

  /// 💾 Save Image
  Future<File> saveImage(File imageFile) async {
    final dir = await getApplicationDocumentsDirectory();

    final filePath =
        "${dir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.jpg";

    return await imageFile.copy(filePath);
  }

  /// 📄 Single PDF
  Future<File> convertToPDF(File imageFile) async {
    final pdf = pw.Document();
    final imageBytes = await imageFile.readAsBytes();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Center(
            child: pw.Image(pw.MemoryImage(imageBytes), fit: pw.BoxFit.contain),
          );
        },
      ),
    );

    return await _savePdf(pdf, "scan");
  }

  /// 📄 Multi PDF
  Future<File> convertMultipleToPDF(List<File> images) async {
    final pdf = pw.Document();

    for (var imageFile in images) {
      final imageBytes = await imageFile.readAsBytes();

      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Center(
              child: pw.Image(
                pw.MemoryImage(imageBytes),
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );
    }

    return await _savePdf(pdf, "multi_scan");
  }

  /// 🔒 Save PDF
  Future<File> _savePdf(pw.Document pdf, String name) async {
    final dir = await getApplicationDocumentsDirectory();

    final filePath =
        "${dir.path}/${name}_${DateTime.now().millisecondsSinceEpoch}.pdf";

    final file = File(filePath);

    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
