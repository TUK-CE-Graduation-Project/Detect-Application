import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';


class VideoEditor {
  Future<String> cutVideo(int timer, String originalFilePath) async {

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

    uploadVideoToServer(outputFile, 'url');

    return outputFile;
  }
}

Future<void> uploadVideoToServer(String filePath, String url) async {
  final file = File(filePath);
  final videoStream = http.ByteStream(file.openRead());
  final videoLength = await file.length();

  final request = http.MultipartRequest('POST', Uri.parse(url));
  final multipartFile = http.MultipartFile(
    'video',
    videoStream,
    videoLength,
    filename: file.path.split('/').last,
  );

  request.files.add(multipartFile);

  final response = await request.send();

  if (response.statusCode == 200) {
    print('Video uploaded successfully!');
  } else {
    print('Error uploading video. Status code: ${response.statusCode}');
  }
}



String formatSeconds(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  final remainingSeconds = seconds % 60;
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
}
