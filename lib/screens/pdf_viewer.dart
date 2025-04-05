import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatelessWidget {
  final String filePath;

  PdfViewer({required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF Viewer")),
      body: SfPdfViewer.file(
        File(filePath),
        enableDoubleTapZooming: true, // Aktifkan double tap zoom
        maxZoomLevel: 45.0, // Bisa zoom hingga 400%
      ),
    );
  }
}
