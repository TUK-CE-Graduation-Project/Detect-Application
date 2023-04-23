import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';


class VideoEditor {
  Future<String> cutVideoAndUploadToServer(int timer, String originalFilePath) async {

    final directory = await getApplicationDocumentsDirectory();
    final outputFile = '${directory.path}/${DateTime.now()}_$timer.mp4';

    final arguments = [
      '-i',
      originalFilePath,
      '-ss',
      (formatSeconds(timer)), //
      '-t',
      (formatSeconds(timer+3)), //  3후
      '-async',
      '1',
      outputFile
    ];


    final flutterFFmpeg = FlutterFFmpeg();
    flutterFFmpeg.executeWithArguments(arguments);

    return outputFile;
  }
}


String formatSeconds(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}