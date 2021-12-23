import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path/path.dart';
import 'package:relis/globals.dart';
import 'package:relis/view/pdfLoader.dart';

class PDFViewer extends StatefulWidget {
  String url;

  PDFViewer({
    required this.url,
  });

  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  late PDFViewController controller;
  File? file;
  int pages = 0;
  int indexPage = 0;

  @override
  void initState() {
    super.initState();
    print("In PDFViewer - initState ");
    loadFile(widget.url);
  }

  void loadFile(String url) async {
    print("In PDFViewer - Loading File, url: $url ");
    file = await PDFLoader.loadNetwork(url);
    print("In PDFViewer - File Loaded, file: ${file!.path} ");
  }

  @override
  Widget build(BuildContext context) {
    isLoggedIn(context);
    final name = basename(file!.path);
    final text = '${indexPage + 1} of $pages';
    return Scaffold(
      appBar: AppBar(
        title: Text('ReLis - $name'),
        actions: pages >= 2
        ? [
          Center(child: Text(text)),
          IconButton(
            icon: Icon(Icons.chevron_left, size: 32),
            onPressed: () {
              final page = indexPage == 0 ? pages : indexPage - 1;
              controller.setPage(page);
            },
          ),
          IconButton(
          icon: Icon(Icons.chevron_right, size: 32),
          onPressed: () {
            final page = indexPage == pages - 1 ? 0 : indexPage + 1;
            controller.setPage(page);
          },
        ),
        ]
        : null,
      ),
      body: PDFView(
        filePath: file!.path,
        // autoSpacing: false,
        // swipeHorizontal: true,
        // pageSnap: false,
        // pageFling: false,
        onRender: (pages) => setState(() => this.pages = pages!),
        onViewCreated: (controller) =>
            setState(() => this.controller = controller),
        onPageChanged: (indexPage, _) =>
            setState(() => this.indexPage = indexPage!),
      ),
    );
  }
}