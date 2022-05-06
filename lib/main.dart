import 'dart:convert';
// import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
// import 'package:pdftest2/space.dart';
// import 'package:pdftest2/simple.dart';
import 'package:pdfx/pdfx.dart';
import 'package:internet_file/internet_file.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

// import 'modal_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // final _pdfController = PdfController(
  //   document: PdfDocument.openAsset('assets/song_book.pdf'),
  // );

// player songbook url:
//   final String _songBookUrl =
//       "https://923caa80-9a0f-4b60-9e0c-85536338de9d.usrfiles.com/ugd/923caa_088942b2022d48a6b005e6b36a8b2a2d.pdf";

  late List<Map> _toc;

  final PdfController _pdfController = PdfController(
      document: PdfDocument.openData(InternetFile.get(
          "https://923caa80-9a0f-4b60-9e0c-85536338de9d.usrfiles.com/ugd/923caa_088942b2022d48a6b005e6b36a8b2a2d.pdf")));

  @override
  void initState() {
    _setup();
    super.initState();
  }

  void _setup() async {
    var contents = await rootBundle.loadString('assets/out.txt');
    final regex = RegExp(r'"(.*)"\s#(\d+)');
    final List<String> lines = const LineSplitter().convert(contents);
    List<Map> indexes = [];
    for (var l = 0; l < lines.length; l++) {
//     print('line $l: ${lines[l]}');
      final match = regex.firstMatch(lines[l]);
      if (match != null) {
//       for (var n = 1; n < 3; n++) {
//         print(
//           'line $l group $n: ${match.group(n)} ',
//         );
//       }
        indexes.add({'title': match.group(1), 'page': match.group(2)});
      }
    }
    // print('indexes: $indexes');
    _toc = indexes;
  }

  // Future<String> _loadAsset(assetName) async {
  //   return await rootBundle.loadString('assets/${assetName}');
  // }

  void _nextPage() {
    // print('_nextPage');
    _pdfController.nextPage(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 100),
    );
  }

  void _previousPage() {
    // print('_previousPage');
    _pdfController.previousPage(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 100),
    );
  }

  Future<Future> _showTOC() async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
            title: const Text('Table of Contents',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,),
            content: SizedBox(
              width: double.minPositive,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _toc.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    title: Text(_toc[index]['title'],
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.pop(context, _toc[index]);
                      _pdfController.jumpToPage(int.parse(_toc[index]['page']));
                    },
                  );
                },
              ),
            ),
          );
        });
  }
  
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.green,
          child: ListView(
            shrinkWrap: true,
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: width,
                height: width * 1.5,
                child: PdfView(
                  controller: _pdfController,
                ),
              ),
              Container(
                color: Colors.amber,
                // height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.navigate_before),
                      onPressed: () {
                        _previousPage();
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        // print('page index tap...');
                        _showTOC();
                      },
                      child: PdfPageNumber(
                        controller: _pdfController,
                        builder: (_, loadingState, page, pagesCount) =>
                            Container(
                          alignment: Alignment.center,
                          child: Text(
                            '$page/${pagesCount ?? 0}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.navigate_next),
                      onPressed: () {
                        _nextPage();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
