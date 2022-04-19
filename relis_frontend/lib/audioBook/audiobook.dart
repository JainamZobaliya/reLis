// // import 'package:audioplayers/audioplayers.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:relis/audioBook/audio_file.dart';
// import 'package:relis/authentication/user.dart';
// import 'package:relis/globals.dart';

// class AudioBook extends StatefulWidget {
//   static const routeName = '/AudioBook';
//   //const AudioBook({Key? key}) : super(key: key);
//   dynamic book, audioBook, audioBytes, index;
//   AudioBook({
//     this.book,
//     this.audioBook,
//     this.audioBytes,
//     this.index,
//   });

//   @override
//   _AudioBookState createState() => _AudioBookState();
// }

// class _AudioBookState extends State<AudioBook> {
//   late AudioPlayer advPlayer;
//   @override
//   void initState() {
//     print("...in AudioBook");
//     super.initState();
//     advPlayer = AudioPlayer(userAgent: "${user!["emailId"]}-${widget.audioBook[widget.index]["id"]}");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: Colors.yellow[800],
//       appBar: AppBar(
//         title: Text("ReLis: Audio-Book"),
//         backgroundColor: appBarBackgroundColor,
//         shadowColor: appBarShadowColor,
//         elevation: 2.0,
//       ),
//       body: view(context, advPlayer, widget.index, widget.book, widget.audioBook, widget.audioBytes),
//     );
//   }
// }

// Widget view(BuildContext context, AudioPlayer advancedPlayer, var index, var book, var audioBook, var audioBytes) {
//   print("...in view of AudioBook");
//   return Center(
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         Center(
//           child: Container(
//             height: MediaQuery.of(context).size.height / 2,
//             width: MediaQuery.of(context).size.width / 2,
//             padding: EdgeInsets.all(10.00),
//             margin: EdgeInsets.all(10.00),
//             color: Colors.yellow[700],
//             alignment: Alignment.center,
//             child: book["image"],
//           ),
//         ),
//         Container(
//           padding: EdgeInsets.all(10.00),
//           margin: EdgeInsets.all(10.00),
//           child: Column(
//             children: [
//               Text(
//                 "${audioBook[index]["audioBookChapterName"]}",
//                 style: TextStyle(fontSize: 20.0),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               Text(
//                 "${book["bookName"]} by ${book["authorName"]}",
//                 style: TextStyle(fontSize: 15.0),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//         Container(
//           margin: EdgeInsets.all(10.00),
//           padding: EdgeInsets.all(10.00),
//           color: Colors.yellow[700],
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: <Widget>[
//               //Audio line and Icons...
//               AudioFile(advancedPlayer: advancedPlayer, index: index, book: book, audioBook: audioBook, audioBytes: audioBytes),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }


import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:relis/globals.dart';

class AudioBook extends StatefulWidget {
  
  static const routeName = '/AudioBook';
  //const AudioBook({Key? key}) : super(key: key);
  dynamic book, audioBook, audioBytes, index, docContent;
  AudioBook({
    this.book,
    this.audioBook,
    this.audioBytes,
    this.index,
    this.docContent,
  });

  @override
  _AudioBookState createState() => _AudioBookState();
}

enum TtsState { playing, stopped, paused, continued }

class _AudioBookState extends State<AudioBook> {
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String? _newVoiceText;
  int? _inputLength;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWeb => kIsWeb;

  @override
  initState() {
    super.initState();
    _onChange(widget.docContent);
    initTts();
  }

  initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    if (isWeb || isIOS) {
      flutterTts.setPauseHandler(() {
        setState(() {
          print("Paused");
          ttsState = TtsState.paused;
        });
      });

      flutterTts.setContinueHandler(() {
        setState(() {
          print("Continued");
          ttsState = TtsState.continued;
        });
      });
    }

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() => flutterTts.getLanguages;

  Future<dynamic> _getEngines() => flutterTts.getEngines;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(dynamic engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  void changedEnginesDropDownItem(String? selectedEngine) {
    flutterTts.setEngine(selectedEngine!);
    language = null;
    setState(() {
      engine = selectedEngine;
    });
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(
      dynamic languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text(type as String)));
    }
    return items;
  }

  void changedLanguageDropDownItem(String? selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language!);
      if (isAndroid) {
        flutterTts
            .isLanguageInstalled(language!)
            .then((value) => isCurrentLanguageInstalled = (value as bool));
      }
    });
  }

  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScrollController pageScroller = new ScrollController();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("ReLis: Audio-Book"),
        backgroundColor: appBarBackgroundColor,
        shadowColor: appBarShadowColor,
        elevation: 2.0,
      ),
      backgroundColor: mainAppAmber,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        margin: EdgeInsets.fromLTRB(10.00, 10.00, 10.00, 10.00),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: pageScroller,
          child: Column(
            children: [
              _inputSection(),
              _btnSection(),
              // _futureBuilder(),
              _buildSliders(),
              // if (isAndroid) _getMaxSpeechInputLengthSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _engineSection() {
    if (isAndroid) {
      return FutureBuilder<dynamic>(
          future: _getEngines(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return _enginesDropDownSection(snapshot.data);
            } else if (snapshot.hasError) {
              return Text('Error loading engines...');
            } else
              return Text('Loading engines...');
          });
    } else
      return Container(width: 0, height: 0);
  }

  Widget _futureBuilder() => FutureBuilder<dynamic>(
      future: _getLanguages(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return _languageDropDownSection(snapshot.data);
        } else if (snapshot.hasError) {
          return Text('Error loading languages...');
        } else
          return Text('Loading Languages...');
      });

  Widget _inputSection() {
    ScrollController docScroller = new ScrollController();
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width / 2,
        padding: EdgeInsets.all(10.00),
        margin: EdgeInsets.all(10.00),
        color: Colors.yellow[700],
        alignment: Alignment.center,
        child: widget.book["image"],
      ),
    );;
  }

  Widget _btnSection() {
    if (isAndroid) {
      return Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(10.0),
        decoration: categoryDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if(!isPlaying)
              _buildButtonColumn(
                Colors.green,
                Colors.greenAccent,
                Icons.play_arrow,
                'PLAY',
                _speak,
              ),
            _buildButtonColumn(
              Colors.red,
              Colors.redAccent,
              Icons.stop,
              'STOP',
              _stop,
            ),
          ],
        ),
      );
    }
    else {
      return Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(10.0),
        decoration: categoryDecoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if(!isPlaying)
              _buildButtonColumn(
                Colors.green,
                Colors.greenAccent,
                Icons.play_arrow,
                'PLAY',
                _speak,
              ),
            if(isPlaying)
              _buildButtonColumn(
                Colors.blue,
                Colors.blueAccent,
                Icons.pause,
                'PAUSE',
                _pause,
              ),
            _buildButtonColumn(
              Colors.red,
              Colors.redAccent,
              Icons.stop,
              'STOP',
              _stop,
            ),
          ],
        ),
      );
    }
  }

  Widget _enginesDropDownSection(dynamic engines) => Container(
        padding: EdgeInsets.only(top: 50.0),
        child: DropdownButton(
          value: engine,
          items: getEnginesDropDownMenuItems(engines),
          onChanged: changedEnginesDropDownItem,
        ),
      );

  Widget _languageDropDownSection(dynamic languages) => Container(
      padding: EdgeInsets.only(top: 10.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        DropdownButton(
          value: language,
          items: getLanguageDropDownMenuItems(languages),
          onChanged: changedLanguageDropDownItem,
        ),
        Visibility(
          visible: isAndroid,
          child: Text("Is installed: $isCurrentLanguageInstalled"),
        ),
      ]));

  Column _buildButtonColumn(Color color, Color splashColor, IconData icon, String label, Function func) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              icon: Icon(icon),
              color: color,
              splashColor: splashColor,
              onPressed: () => func()),
          Container(
              margin: const EdgeInsets.only(top: 8.0),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: color)))
        ]);
  }

  Widget _getMaxSpeechInputLengthSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          child: Text('Get max speech input length'),
          onPressed: () async {
            _inputLength = await flutterTts.getMaxSpeechInputLength;
            setState(() {});
          },
        ),
        Text("$_inputLength characters"),
      ],
    );
  }

  Widget _buildSliders() {
    return Column(
      children: [
        _volume(),
        _pitch(),
        // _rate(),
      ],
    );
  }

  Widget _volume() {
    return Slider(
      value: volume,
      onChanged: (newVolume) {
        setState(() => volume = newVolume);
      },
      min: 0.0,
      max: 1.0,
      divisions: 10,
      label: "Volume: $volume",
      activeColor: mainAppBlue,
    );
  }

  Widget _pitch() {
    return Slider(
      value: pitch,
      onChanged: (newPitch) {
        setState(() => pitch = newPitch);
      },
      min: 0.5,
      max: 2.0,
      divisions: 15,
      label: "Pitch: $pitch",
      activeColor: mainAppBlue,
    );
  }

  Widget _rate() {
    return Slider(
      value: rate,
      onChanged: (newRate) {
        setState(() => rate = newRate);
      },
      min: 0.0,
      max: 1.0,
      divisions: 10,
      label: "Rate: $rate",
      activeColor: Colors.green,
    );
  }
}
