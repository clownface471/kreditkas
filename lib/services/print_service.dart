import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'dart:html' as html;

class PrintService {
  /// Print or download PDF based on platform
  Future<void> printPdf(Uint8List pdfBytes, {String filename = 'receipt.pdf'}) async {
    if (kIsWeb) {
      // Web: Download the PDF
      await _downloadPdfWeb(pdfBytes, filename);
    } else {
      // Desktop/Mobile: Open print dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    }
  }

  /// Share PDF (save to file on desktop, download on web)
  Future<void> sharePdf(Uint8List pdfBytes, {String filename = 'receipt.pdf'}) async {
    if (kIsWeb) {
      // Web: Download the PDF
      await _downloadPdfWeb(pdfBytes, filename);
    } else {
      // Desktop: Use the share dialog
      await Printing.sharePdf(bytes: pdfBytes, filename: filename);
    }
  }

  /// Download PDF on web platform
  Future<void> _downloadPdfWeb(Uint8List pdfBytes, String filename) async {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = filename;

    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  /// Open PDF in new tab (web only)
  Future<void> previewPdfWeb(Uint8List pdfBytes) async {
    if (!kIsWeb) return;

    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, '_blank');

    // Revoke URL after a delay to allow the browser to load it
    Future.delayed(const Duration(seconds: 2), () {
      html.Url.revokeObjectUrl(url);
    });
  }

  /// Print using the printing package (works on all platforms)
  Future<void> printDocument(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }

  /// Check if platform supports printing
  bool get canPrint {
    return true; // All platforms support printing via the printing package
  }
}
