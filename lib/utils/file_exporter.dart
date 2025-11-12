import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:csv/csv.dart';
import '../globals.dart';
import 'package:torquedoc/styles/app_text_styles.dart';

class FileExporter {
  /// Exportiert die übergebenen Daten als PDF oder CSV.
  static Future<String?> exportData({
    required List<Map<String, dynamic>> data,
    required String projectVar,
    required String format, // "pdf" oder "csv"
  }) async {
    if (data.isEmpty) {
      debugPrint("[EXPORT] Keine Daten vorhanden – Abbruch");
      return null;
    }

    await _checkStoragePermission();
    final file = await _getProjectPdfFile(projectVar);

    if (format == "pdf") {
      final logoBytes = await rootBundle.load('assets/logosd.jpg');
      final logoUint8 = logoBytes.buffer.asUint8List();
      await _exportPdf(data, file, logoUint8);
    } else if (format == "csv") {
      await _exportCsv(data, file.path);
    } else {
      throw Exception("Unbekanntes Format: $format");
    }

    debugPrint("[EXPORT] Datei gespeichert unter: ${file.path}");
    return file.path;
  }

  /// 🔐 Prüft und fordert ggf. Schreibrechte an (Android only)
  static Future<void> _checkStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    }
  }

  /// 📂 Holt Datei-Pfad für PDF nach Schema projectVar_YYYY-MM-DD.pdf
  static Future<File> _getProjectPdfFile(String projectVar) async {
    final now = DateTime.now();
    final dateString =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final safeProjectVar = projectVar.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), "_");
    final fileName = "${safeProjectVar}_$dateString.pdf";

    Directory dir;

    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download');
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getTemporaryDirectory();
    }

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File('${dir.path}/$fileName');

    if (await file.exists()) {
      await file.delete();
      debugPrint("Existierende Datei gelöscht: $fileName");
    }

    return file;
  }

  /// Öffnet eine Datei in einer kompatiblen App
  static Future<void> openFile(String path) async {
    await OpenFile.open(path);
  }

  /// 🧾 CSV-Export
  static Future<void> _exportCsv(List<Map<String, dynamic>> data, String path) async {
    final headers = data.first.keys.toList();
    final rows = [
      headers,
      ...data.map((row) => headers.map((h) => row[h]).toList()).toList(),
    ];

    final csvString = const ListToCsvConverter().convert(rows);
    final file = File(path);
    await file.writeAsString(csvString);
  }

  /// 📘 PDF-Export (statisch + LogoBytes als Parameter)
  static Future<void> _exportPdf(List<Map<String, dynamic>> data, File file, Uint8List logoBytes) async {
    final pdf = pw.Document();
    final firstPage = await _buildFirstPageStatic(logoBytes);
    pdf.addPage(firstPage);

    await file.writeAsBytes(await pdf.save());
  }

  /// Statische Version der ersten Seite
  static Future<pw.Page> _buildFirstPageStatic(Uint8List logoBytes) async {
    final tableData = <List<String>>[];

    if (UserName.isNotEmpty) tableData.add(['User', UserName]);
    if (Projectnumber.isNotEmpty) tableData.add(['Project', Projectnumber]);
    if (Serialpump.isNotEmpty) tableData.add(['Serial', Serialpump]);
    if (Serialhose.isNotEmpty) tableData.add(['SerialHose', Serialhose]);
    if (Serialtool.isNotEmpty) tableData.add(['SerialTool', Serialtool]);
    if (Tool.isNotEmpty) tableData.add(['Tool', Tool]);

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Logo in Container, kein Abstand oben
            pw.Container(
              width: PdfPageFormat.a4.width,
              height: 95, // gewünschte Höhe
              child: pw.Image(
                pw.MemoryImage(logoBytes),
                fit: pw.BoxFit.cover, // füllt Container, keine Verzerrung
              ),
            ),

            // Tabelle direkt darunter
            if (tableData.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 20, top: 5),
                child: pw.Table.fromTextArray(
                  headers: [],
                  data: tableData,
                  cellAlignment: pw.Alignment.centerLeft,
                  cellStyle: pw.TextStyle(
                    fontSize: AppTextStyles.body.fontSize?.toDouble() ?? 12,
                    fontWeight: pw.FontWeight.normal,
                  ),
                  border: null,
                  columnWidths: {
                    0: const pw.FixedColumnWidth(80),
                    1: const pw.FixedColumnWidth(120),
                  },
                  cellPadding: const pw.EdgeInsets.only(bottom: 4),
                ),
              ),
          ],
        );
      },
    );
  }

}
