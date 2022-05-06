import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:pdftest2/space.dart';
// import 'package:pdftest2/simple.dart';
import 'package:pdfx/pdfx.dart';
import 'package:internet_file/internet_file.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

import 'modal_dialog.dart';

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
  final String _songBookUrl =
      "https://923caa80-9a0f-4b60-9e0c-85536338de9d.usrfiles.com/ugd/923caa_088942b2022d48a6b005e6b36a8b2a2d.pdf";
  late List<Map> _toc;
  // PdfController? _pdfController;

  var _indexPage = "0";

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
    final List<String> lines = LineSplitter().convert(contents);
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

  Future<String> _loadAsset(assetName) async {
    return await rootBundle.loadString('assets/${assetName}');
  }

  void _nextPage() {
    print('_nextPage');
    _pdfController.nextPage(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 100),
    );
  }

  void _previousPage() {
    print('_previousPage');
    _pdfController.previousPage(
      curve: Curves.ease,
      duration: const Duration(milliseconds: 100),
    );
  }

  void _showIndex() async {
    // _showTOCDialog();
    var result = await _askFavColor();
    print ('_showIndex result:  $result');
  }

  _showTOCDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          double containerWidth = MediaQuery.of(context).size.width * 0.8;
          bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
          Color borderColor = isDarkMode ? Colors.white : Colors.brown;
          return StatefulBuilder(
            builder: (context, setState) => ModalDialog(
              content: SingleChildScrollView(
                  child: Container(
                width: containerWidth,
                height: containerWidth * 1.6,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: borderColor,
                    width: 2,
                  ),
                  borderRadius:
                      BorderRadius.circular(20), //widget.cornerRadius),
                ),
                child: Column(
                  children: [
                    const VSpace(10),
                    const Text('Table of Contents'),
                    const VSpace(10),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _toc.length,
                        itemBuilder: (context, index) {
                          return Card(
                            // margin: const EdgeInsets.all(10),
                            child: ListTile(
                              leading: Text(
                                _toc[index]['title'],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Divider(height: 2.0, color: borderColor),
                    TextButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ],
                ),
              )),
            ),
          );
        }).then((valueFromDialog){
      // use the value as you wish
      print('valueFromDialog: $valueFromDialog');
    });
  }

  List<String> colorList = ['Orange', 'Yellow', 'Pink','White', 'Red', 'Black', 'Green'];

  Future<Future> _askFavColor() async {

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
            title: Text('Table of Contents',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,),
            content: Container(
              width: double.minPositive,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _toc.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 0),
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
  // _showTOCDialog() {
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         double containerWidth = MediaQuery.of(context).size.width * 0.8;
  //         bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  //         Color borderColor = isDarkMode ? Colors.white : Colors.brown;
  //         return StatefulBuilder(
  //           builder: (context, setState) => ModalDialog(
  //             content: Container(
  //               width: containerWidth,
  //               height: containerWidth * 1.6,
  //               decoration: BoxDecoration(
  //                 border: Border.all(
  //                   color: borderColor,
  //                   width: 2,
  //                 ),
  //                 borderRadius:
  //                     BorderRadius.circular(20), //widget.cornerRadius),
  //               ),
  //               child: ListView.builder(
  //                   itemCount: _toc.length,
  //                   itemBuilder: (context, index) {
  //                     ListTile(
  //                       leading: Text(
  //                         _toc[index]['title'],
  //                         style: const TextStyle(fontSize: 12),
  //                       ),
  //                     ),
  //                   }),
  //             ),
  //             //   Divider(height: 2.0, color: borderColor),
  //             //   TextButton(
  //             //       child: const Text('Close'),
  //             //       onPressed: () {
  //             //         Navigator.pop(context);
  //             //       }),
  //             // ],
  //           ),
  //         );
  //       });
  // }

  Widget _showChild1() {
    return Container(height: 400, color: Colors.amber);
  }

  Widget _showChild2() {
    return Container(height: 400, color: Colors.green);
  }

  Widget _showChild3() {
    return Container(height: 400, color: Colors.red);
  }

  @override
  // Widget buildx(BuildContext context) {
  //   double width = MediaQuery.of(context).size.width * 1.0;
  //   double height = MediaQuery.of(context).size.height;
  //   return new ListView(children: <Widget>[
  //     _showChild1(),
  //     _showChild2(),
  //     // PdfWidget(_pdfController),
  //     Container(
  //       width: width,
  //       height: width * 1.5,
  //       // child: PdfView(
  //         // controller: _pdfController,
  //       ),
  //     ),
  //     _showChild3(),
  //   ]);
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
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
              Container(
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
                        // _pdfController.previousPage(
                        //   curve: Curves.ease,
                        //   duration: const Duration(milliseconds: 100),
                        // );
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        print('page index tap...');
                        _showIndex();
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
                        // print('next');
                        // _pdfController.nextPage(
                        //   curve: Curves.ease,
                        //   duration: const Duration(milliseconds: 100),
                        // );
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

class PdfWidget extends StatefulWidget {
  final PdfController pdfController;
  const PdfWidget(this.pdfController, {Key? key}) : super(key: key);

  @override
  State<PdfWidget> createState() => _PdfWidgetState();
}

class _PdfWidgetState extends State<PdfWidget> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      height: width * 1.5,
      child: PdfView(
        controller: widget.pdfController,
      ),
    );
  }
}
