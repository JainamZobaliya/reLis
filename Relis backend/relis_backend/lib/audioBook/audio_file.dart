import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:relis/globals.dart';

class AudioFile extends StatefulWidget {
  final AudioPlayer advancedPlayer;
  dynamic audioFile, book, audioBook, index;
  AudioFile(
    {Key? key,
    required this.advancedPlayer,
    required this.audioFile,
    required this.book,
    required this.audioBook,
    required this.index,
    }
  ) : super(key: key);
  @override
  _AudioFileState createState() => _AudioFileState();
}

class _AudioFileState extends State<AudioFile> {
  Duration _duration = new Duration();
  Duration _position = new Duration();
  // final String path = "https://drive.google.com/file/d/1FuoF2-CiOItuzypVvCO7izwzwyNv8_X9/view?usp=sharing";
  final String path =
      "/assets/audiobooks/https___archive.org_download_prideandprejudice_1005_librivox_prideandprejudice_01_austen_64kb.mp3";
  bool isPlaying = false;
  bool isPaused = false;
  bool isLoop = false;
  int allGood = 0;
  late AudioPlayer advancedPlayer;
  var min = 0.0;
  var max = 0.0;
  String startDuration = "00.00";
  String endDuration = "00.00";
  // bool isRepeat = false;
  List<IconData> _icons = [
    Icons.play_circle_fill,
    Icons.pause_circle_filled,
  ];

  @override
  void initState() {
    super.initState();
    advancedPlayer = this.widget.advancedPlayer;
    endDuration = getDuration(widget.audioBook[widget.index]["audioBookMaxDuration"]);
    print("audioBook: ");
    print(widget.audioBook[widget.index]);
    print("audioBook-endDuration: ${endDuration}");
    Future.delayed(Duration.zero, () async {
      await loadPlayer();
    });
  }

  Future loadPlayer() async {
    advancedPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        print("\n1------\n");
        print(d);
        _duration = d;
        // endDuration = _duration.toString().split(".")[0];
        print("\na------\n");
      });
    });
    advancedPlayer.onAudioPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
        startDuration = _position.toString().split(".")[0];
      });
    });
    advancedPlayer.onPlayerError.listen((error) {
      print("...error: ");
      print(error);
    });
    advancedPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        _position = Duration(seconds: 0);
        isPlaying = false;
      });
    });
    // endDuration = _duration.toString().split(".")[0];
    allGood = await advancedPlayer.setUrl("${widget.audioBook[widget.index]["bookId"]}/${widget.audioBook[widget.index]["id"]}.mp3", isLocal: true).onError(
      (error, stackTrace) {
        print("error:");
        print(error);
        print("\n\n");
        print("stackTrace:");
        print(stackTrace);
        throw error!;
      }
    );
    setState(() {});
    print("endInit...allGood: ${allGood}");
  }

  @override
  void dispose() {
    advancedPlayer.dispose();
    advancedPlayer.release();
    super.dispose();
  }

  Widget audioSlider() {
    return Slider(
      activeColor: Colors.red,
      inactiveColor: Colors.grey,
      value: _position.inSeconds.toDouble(),
      min: min,
      // max: _duration.inSeconds.toDouble(),
      max: 1000,
      onChanged: (double value) {
        setState(() {
          print("\n4------\n");
          changeToSecond(value.toInt());
          value = value;
          print("\nd------\n");
        });
      },
    );
  }

  void changeToSecond(int sec) {
    Duration newDuration = Duration(seconds: sec);
    advancedPlayer.seek(newDuration);
    print("Seeking: ${newDuration.toString()}");
  }

  Widget btnStart() {
    return IconButton(
      padding: const EdgeInsets.only(bottom: 10),
      onPressed: () {
        if (isPlaying == false && _position != 0) {
          advancedPlayer.resume();
          setState(() {
            isPlaying = true;
            isPaused = false;
          });
          print("...Resuming");
        } else if (isPlaying == false) {
          advancedPlayer.play(path);
          setState(() {
            isPlaying = true;
            isPaused = false;
          });
          print("...Playing");
        } else {
          advancedPlayer.pause();
          setState(() {
            isPlaying = false;
            isPaused = true;
          });
          print("...Paused");
        }
      },
      icon: isPlaying == false ? Icon(_icons[0]) : Icon(_icons[1]),
    );
  }

  Widget btnSlow() {
    return RotatedBox(
      quarterTurns: 2,
      child: IconButton(
        icon: const Icon(Icons.fast_forward),
        onPressed: () {
          _position = Duration(seconds: _position.inSeconds - 10);
          advancedPlayer.seek(_position);
          print("Going behind to: ${_position.toString()}");
        },
      ),
    );
  }

  Widget btnFast() {
    return IconButton(
      icon: const Icon(Icons.fast_forward),
      onPressed: () {
        _position = Duration(seconds: _position.inSeconds + 10);
        advancedPlayer.seek(_position);
        print("Going ahead to: ${_position.toString()}");
      },
    );
  }

  // Widget btnRepeat() {
  //   return IconButton(
  //     icon: const ImageIcon(
  //       AssetImage('Images/SlowForward.png'),
  //       size: 10,
  //       color: Colors.black,
  //     ),
  //     onPressed: () {
  //       if (isRepeat == false) {
  //         widget.advancedPlayer.setReleaseMode(ReleaseMode.LOOP);
  //         setState(() {
  //           isRepeat = true;
  //         });
  //       } else {
  //         widget.advancedPlayer.setReleaseMode(ReleaseMode.RELEASE);
  //         setState(() {
  //           isRepeat = false;
  //         });
  //       }
  //     },
  //   );
  // }

  Widget audioController() {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          // btnRepeat(),
          btnSlow(),
          btnStart(),
          btnFast(),
        ],
      ),
    );
  }

  Widget audioTimeStamp() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            startDuration,
            style: TextStyle(fontSize: 10.0),
          ),
          Text(
            endDuration,
            style: TextStyle(fontSize: 10.0),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("build...allGood: ${allGood}");
    return allGood != 1 ? Container(
      child: CircularProgressIndicator(
        backgroundColor: Colors.transparent,
        color: Colors.red,
      )
    ) 
    : Container(
      child: Column(
        children: <Widget>[
          audioTimeStamp(),
          audioSlider(),
          audioController(),
        ],
      ),
    );
  }


  Widget notification() {
    return Wrap(
      alignment: WrapAlignment.spaceAround,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text("Play notification sound: 'messenger.mp3':"),
        TextButton(
          child: Text('Play'),
          onPressed: () {
            advancedPlayer.play(path);
          },
        ),
        const Text('Notification Service'),
        TextButton(
          child: Text('Notification'),
          onPressed: () async {
            await advancedPlayer.notificationService.startHeadlessService();
            await advancedPlayer.notificationService.setNotification(
              title: 'My Song',
              albumTitle: 'My Album',
              artist: 'My Artist',
              imageUrl: 'Image URL or blank',
              forwardSkipInterval: const Duration(seconds: 30),
              backwardSkipInterval: const Duration(seconds: 30),
              duration: const Duration(minutes: 3),
              elapsedTime: const Duration(seconds: 15),
              enableNextTrackButton: true,
              enablePreviousTrackButton: true,
            );

            await advancedPlayer.play(
              path,
            );
          },
        ),
        TextButton(
          child: Text('Clear Notification'),
          onPressed: () async {
            await advancedPlayer.stop();
            await advancedPlayer.notificationService.clearNotification();
          },
        ),
      ],
    );
  }

}
