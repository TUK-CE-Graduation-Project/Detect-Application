
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayback extends StatefulWidget {
  final String filePath;
  const VideoPlayback({Key? key, required this.filePath}) : super(key: key);

  @override
  State<VideoPlayback> createState() => _VideoPlaybackState();
}

class _VideoPlaybackState extends State<VideoPlayback> {
  late VideoPlayerController _videoPlayerController;

  void dispose(){
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future _initVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
  }


  Widget videoPreview(){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playing Video'),
        elevation: 0,
        backgroundColor: Colors.black26,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: (){
              // 서버에 영상 전송하기

            },
          )
        ],
      ),
      extendBodyBehindAppBar:  true,
      body: FutureBuilder(
        future: _initVideoPlayer(),
        builder: (context, state){
          if (state.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          } else{
            return VideoPlayer(_videoPlayerController);
          }
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return videoPreview();
  }
}
