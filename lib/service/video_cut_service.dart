import 'dart:async';
import 'dart:ffi';
import 'dart:html';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';


class VideoEditor {


  Future<void> cutVideoAndUploadToServer(String startTime, String endTime,
      String inputPath) async {
    final ffmpeg = FlutterFFmpeg();

    final arguments = [
      '-i', inputPath,
      '-ss', startTime,
      '-t', endTime,
      '-c:v', 'libx264',
      '-preset', 'ultrafast',
      '-c:a', 'copy',
      '-f', 'mp4',
      '-'
    ];

    final completer = Completer<Uint8List>();
    final List<int> uint8list = [];
    ffmpeg.executeWithArguments(arguments).then((rc){
      completer.complete(Uint8List.fromList(uint8list));
    });

    final result = await completer.future;

    // 서버로 result 전송
  }
}