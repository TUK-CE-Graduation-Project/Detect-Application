import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';


class VideoEditor {
  Future<File> cutVideoAndUploadToServer(
      Duration duration, String inputPath, String outputPath) async {

    final ffmpeg = FlutterFFmpeg();


    final startTime = duration.toString().split('.').first.padLeft(8, "0");
    final endTime =
    (duration + Duration(seconds: 10)).toString().split('.').first.padLeft(8, "0");

    final arguments = [
      '-i', inputPath,
      '-ss', startTime,
      '-t', endTime,
      '-c:v', 'libx264',
      '-preset', 'ultrafast',
      '-c:a', 'copy',
      '-f', 'mp4',
      outputPath
    ];

    final completer = Completer<File>();

    try {
      final rc = await ffmpeg.executeWithArguments(arguments);
      if (rc == 0) {
        final file = File(outputPath);
        completer.complete(file);
      } else {
        print("else에서 에러");
        throw Exception('FFmpeg exited with error code $rc');
      }
    } catch (e) {
      print("아예 이 함수가 문제인 듯?");
      completer.completeError(e);
    }


    final result = await completer.future;
    return result;
  }
}