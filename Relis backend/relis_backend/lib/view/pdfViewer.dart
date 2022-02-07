// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:path/path.dart';
// import 'package:relis/globals.dart';
// import 'package:relis/view/pdfLoader.dart';

// class PDFViewer extends StatefulWidget {
//   String? url;
//   String? path;

//   PDFViewer({
//     this.url,
//   });

//   @override
//   _PDFViewerState createState() => _PDFViewerState();
// }

// class _PDFViewerState extends State<PDFViewer> {
//   ller controller;
//   File? file;
//   int pages = 0;
//   int indexPage = 0;

//   @override
//   void initState() {
//     super.initState();
//     print("In PDFViewer - initState ");
//     // widget.url ?? 
//     loadFile(widget.path ?? "book/book1.pdf");
//   }

//   void loadFile(String url) async {
//     print("In PDFViewer - Loading File, url: $url ");
//     file = await PDFLoader.loadAsset(url);
//     // file = await PDFLoader.loadNetwork(url);
//     print("In PDFViewer - File Loaded, file: ${file!.path} ");
//   }

//   @override
//   Widget build(BuildContext context) {
//     isLoggedIn(context);
//     final name = basename(file!.path);
//     final text = '${indexPage + 1} of $pages';
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('ReLis - $name'),
//         actions: pages >= 2
//         ? [
//           Center(child: Text(text)),
//           IconButton(
//             icon: Icon(Icons.chevron_left, size: 32),
//             onPressed: () {
//               final page = indexPage == 0 ? pages : indexPage - 1;
//               controller.setPage(page);
//             },
//           ),
//           IconButton(
//           icon: Icon(Icons.chevron_right, size: 32),
//           onPressed: () {
//             final page = indexPage == pages - 1 ? 0 : indexPage + 1;
//             controller.setPage(page);
//           },
//         ),
//         ]
//         : null,
//       ),
//       body: PDFView(
//         filePath: file!.path,
//         // autoSpacing: false,
//         // swipeHorizontal: true,
//         // pageSnap: false,
//         // pageFling: false,
//         onRender: (pages) => setState(() => this.pages = pages!),
//         onViewCreated: (controller) =>
//             setState(() => this.controller = controller),
//         onPageChanged: (indexPage, _) =>
//             setState(() => this.indexPage = indexPage!),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:relis/globals.dart';

class PDFViewer extends StatefulWidget {
  String? url;
  String? path;

  PDFViewer({
    this.url,
    this.path,
  });

  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  static final int _initialPage = 1;
  int _actualPageNumber = _initialPage, _allPagesCount = 0;
  bool isSampleDoc = true;
  double viewportFraction = 1;
  PdfController _pdfController = PdfController(
    document: PdfDocument.openAsset('ReLis.gif'),
  );

  @override
  void initState() {
    _pdfController = PdfController(
      document: PdfDocument.openAsset(widget.path!),
      initialPage: _initialPage,
      viewportFraction: viewportFraction,
    );
    super.initState();
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("viewportFraction: ${viewportFraction}");
    return Scaffold(
      appBar: AppBar(
        title: Text(appTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.zoom_in),
            onPressed: () {
              viewportFraction = viewportFraction * 2;
              WidgetsBinding.instance!.addPostFrameCallback((_){
                setState(() {});
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.navigate_before),
            onPressed: () {
              _pdfController.previousPage(
                curve: Curves.ease,
                duration: Duration(milliseconds: 100),
              );
            },
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              '$_actualPageNumber/$_allPagesCount',
              style: TextStyle(fontSize: 22),
            ),
          ),
          IconButton(
            icon: Icon(Icons.navigate_next),
            onPressed: () {
              _pdfController.nextPage(
                curve: Curves.ease,
                duration: Duration(milliseconds: 100),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              if (isSampleDoc) {
                _pdfController.loadDocument(
                    PdfDocument.openAsset(widget.path!));
              } else {
                _pdfController.loadDocument(
                    PdfDocument.openAsset(widget.path!));
              }
              isSampleDoc = !isSampleDoc;
            },
          )
        ],
      ),
      body: PdfView(
        documentLoader: Center(child: CircularProgressIndicator()),
        pageLoader: Center(child: CircularProgressIndicator()),
        controller: _pdfController,
        onDocumentLoaded: (document) {
          setState(() {
            _allPagesCount = document.pagesCount;
          });
        },
        onPageChanged: (page) {
          setState(() {
            _actualPageNumber = page;
          });
        },
        backgroundDecoration: BoxDecoration(
          color: appBarBackgroundColor,
        ),
        errorBuilder: (exception) {
          return Container(
            child: Text(
              "Some Error Occured!! Please Log-in again. If Error continues, write email to us",
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              softWrap: true,
              style: TextStyle(color: Color(0xFFFF0000)),
            ),
            color: mainAppAmber,
          );
        },
        renderer: (PdfPage page) => page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: PdfPageFormat.PNG,
          backgroundColor: appBarBackgroundColor.toString(),
        ),
      ),
    );
  }
}