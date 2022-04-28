import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:relis/globals.dart';
import 'package:video_player/video_player.dart';

class DemoMode extends StatefulWidget {
  const DemoMode({Key? key}) : super(key: key);
  static const routeName = '/DemoMode';

  @override
  _DemoModeState createState() => _DemoModeState();
}

class _DemoModeState extends State<DemoMode> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  @override
  void initState() {
    _controller = VideoPlayerController.network(
      // "https://firebasestorage.googleapis.com/v0/b/audiobook-404e3.appspot.com/o/ReLis-UserManual.mp4?alt=media&token=cb935f5e-454e-42cf-a04a-f8ebc42dd5c7", // With bg-music,
      "https://firebasestorage.googleapis.com/v0/b/relis-frontend.appspot.com/o/ReLis-UserManual-NoBgMusic.mp4?alt=media&token=95f6edbc-36b5-45ca-bd27-77780ff50506", // Without bg-music,
    )..initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      setState(() {});
    });
    _initializeVideoPlayerFuture =  _controller.initialize();
    Future.delayed(
      Duration.zero,
      () async {
        await _controller.setVolume(0);
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    Future.delayed(
      Duration.zero,
      () async {
        await _controller.pause();
        await _controller.setVolume(0);
        await _controller.dispose();
      },
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainAppBlue,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: appBarBackgroundColor,
        shadowColor: appBarShadowColor,
        elevation: 2.0,
        leading: IconButton(
          color: mainAppAmber,
          splashColor: Colors.white,
          icon: Icon(Icons.arrow_back),
          iconSize: 28,
          onPressed: (){
            Future.delayed(
              Duration.zero,
              () async {
                await _controller.pause();
                await _controller.setVolume(0);
                await _controller.dispose();
                Navigator.of(context).pop();
              },
            );
          },),
        centerTitle: true,
        title: Text(
          "Video demonstrating how to use this application",
          style: TextStyle(color: mainAppAmber, fontSize: 20,),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            alignment: Alignment.center,
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
            onPressed: (){
              setState(() async {
                if (_controller.value.isPlaying) {
                  await _controller.pause();
                  await _controller.setVolume(0);
                } else {
                  if( _controller.value.isInitialized) {
                    await _controller.play();
                    await _controller.setVolume(1.0);
                  }
                }
              });
            },
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: mainAppAmber,
            ),
          ),
          PopupMenuButton<double>(
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
            color: mainAppAmber,
            initialValue: _controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) async {
              await _controller.setPlaybackSpeed(speed);
              setState(() {});
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text(
                      '${speed}x',
                      style: TextStyle(
                        color: mainAppBlue,
                      ),
                    ),
                  ),
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              child: Text(
                '${_controller.value.playbackSpeed}x',
                style: TextStyle(
                  color: mainAppBlue,
                )
              ),
            ),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // If the VideoPlayerController has finished initialization, use
              // the data it provides to limit the aspect ratio of the video.
              return Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  VideoPlayer(_controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true,),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

}


