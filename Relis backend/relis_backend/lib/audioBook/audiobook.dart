import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:relis/audioBook/audio_file.dart';
import 'package:relis/authentication/user.dart';
import 'package:relis/globals.dart';

class AudioBook extends StatefulWidget {
  static const routeName = '/AudioBook';
  //const AudioBook({Key? key}) : super(key: key);
  @override
  _AudioBookState createState() => _AudioBookState();
}

class _AudioBookState extends State<AudioBook> {
  late AudioPlayer advPlayer;
  @override
  void initState() {
    super.initState();
    advPlayer = AudioPlayer(playerId: "${user!["emailId"]}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.yellow[800],
      appBar: AppBar(
        title: Text("ReLis: Audio-Book"),
        backgroundColor: appBarBackgroundColor,
        shadowColor: appBarShadowColor,
        elevation: 2.0,
      ),
      body: view(context, advPlayer),
    );
  }
}

Widget view(BuildContext context, AudioPlayer advancedPlayer) {
  return Center(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height / 2,
          padding: EdgeInsets.all(10.00),
          margin: EdgeInsets.all(10.00),
          color: Colors.yellow[700],
          alignment: Alignment.center,
          child: Text('Image of Audio-Book'),
        ),
        Container(
          padding: EdgeInsets.all(10.00),
          margin: EdgeInsets.all(10.00),
          child: Column(
            children: const [
              Text(
                "FileName",
                style: TextStyle(fontSize: 20.0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "authorName",
                style: TextStyle(fontSize: 15.0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.all(10.00),
          padding: EdgeInsets.all(10.00),
          color: Colors.yellow[700],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              //Audio line and Icons...
              AudioFile(advancedPlayer: advancedPlayer),
            ],
          ),
        ),
      ],
    ),
  );
}
