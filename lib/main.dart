import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test2/result.dart';
import 'package:test2/service/accelerometer_data_service.dart';
import 'package:test2/service/location_service.dart';
import 'package:test2/service/position_stream.dart';
import 'package:test2/service/video_cut_service.dart';
import 'package:test2/service/video_playback_service.dart';
import 'package:test2/service/video_recording_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MyLocation().getMyCurrentLocation();

// ...

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Test(),
    );
  }
}

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  bool state = false;
  List<Data> _data = [];
  Position? _position;
  List<String> cutVideoPathList = [];
  String cutVideoPath = ""; //  마지막으로 잘린 비디오 확
  CallBackResult result = CallBackResult(
      data: AccelerometerData(dataList: [], eventTimeList: []), filePath: "");
  final PositionStream _positionStream = PositionStream();
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];
  double indexX = 0;
  double indexY = 0;
  double indexZ = 0;
  final directory = getApplicationDocumentsDirectory();

  @override
  void initState() {
    _positionStream.controller.stream.listen((event) {
      setState(() {
        _position = event;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Center(
              child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Latitude: ${_position?.latitude.toString() ?? ""}",
            style: const TextStyle(color: Colors.black),
          ),
          Text(
            "Longitude: ${_position?.longitude.toString()??""}",
            style: const TextStyle(color: Colors.black),
          ),
          TextButton(
              child: Container(
                  color: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child:
                      const Text("영상 촬영", style: TextStyle(color: Colors.white))),
              onPressed: () async {
                result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CameraApp(result: result)));
                setState(() {
                  _data = result.data.dataList;
                });
              }),
          TextButton(
              child: Container(
                  color: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: const Text("카메라 시작",
                      style: TextStyle(color: Colors.white))),
              onPressed: () async {
                String videoPath = "";
                // 타이머 중복 제거 및 int로 변환
                var timerList = result.data.eventTimeList;
                int count = 0;
                print(timerList);

                for (var element in timerList) {
                  videoPath =
                      await VideoEditor().cutVideo(element, result.filePath);

                  print("완료된 비디오 $videoPath");
                  cutVideoPathList.add(videoPath);
                }
                cutVideoPath = videoPath;
              }),
          Text('이벤트 발생 시간은 : ${result.data.eventTimeList.toString()}',
              style: const TextStyle(color: Colors.black)),
          TextButton(
              child: Container(
                  color: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: const Text("영상 재생(테스트용)",
                      style: TextStyle(color: Colors.white))),
              onPressed: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            VideoPlayback(filePath: cutVideoPath)));
              })
        ],
      ))),
    );
  }
}
