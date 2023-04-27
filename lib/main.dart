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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _positionStream.controller.stream.listen((event) {
      setState(() {
        _position = event;
      });
    });
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Center(
              child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 3 / 2,
            child: LineChart(LineChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                        color: const Color.fromARGB(144, 255, 255, 255),
                        strokeWidth: 1);
                  },
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                        color: const Color.fromARGB(144, 255, 255, 255),
                        strokeWidth: 1);
                  },
                ),
                borderData: FlBorderData(
                    show: true,
                    border:
                        Border.all(color: const Color(0xff02d39a), width: 1)),
                lineBarsData: [
                  LineChartBarData(
                    spots: _data.map((e) {
                      indexX++;
                      return FlSpot(indexX, e.accelerometerEvent?.x ?? 0);
                    }).toList(),
                    isCurved: true,
                    barWidth: 5,
                    color: const Color(0xff23b6e6),
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                    ),
                    belowBarData: BarAreaData(
                        show: true,
                        color: const Color.fromARGB(122, 27, 206, 113)),
                  ),
                  LineChartBarData(
                    spots: _data.map((e) {
                      indexY++;
                      return FlSpot(indexY, e.accelerometerEvent?.y ?? 0);
                    }).toList(),
                    isCurved: true,
                    barWidth: 5,
                    color: const Color.fromARGB(187, 22, 194, 65),
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                    ),
                    belowBarData: BarAreaData(
                        show: true,
                        color: const Color.fromARGB(112, 22, 194, 65)),
                  ),
                  LineChartBarData(
                    spots: _data.map((e) {
                      indexZ++;
                      return FlSpot(indexZ, e.accelerometerEvent?.z ?? 0);
                    }).toList(),
                    isCurved: true,
                    barWidth: 5,
                    color: const Color.fromARGB(255, 194, 213, 14),
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color.fromARGB(108, 193, 213, 14),
                    ),
                  ),
                ])),
          ),
          Text(
            "Latitude: ${_position!.latitude.toString() ?? ""}",
            style: const TextStyle(color: Colors.black),
          ),
          Text(
            "Longitude: ${_position!.longitude.toString()??""}",
            style: const TextStyle(color: Colors.black),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'x',
                style: TextStyle(
                    color: Color(0xff23b6e6), fontWeight: FontWeight.bold),
              ),
              Text(
                'y',
                style: TextStyle(
                    color: Color.fromARGB(187, 22, 194, 65),
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'z',
                style: TextStyle(
                    color: Color.fromARGB(255, 194, 213, 14),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          /*TextButton(
              child: Container(
                  color: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    state == false ? '시작' : '중지',
                    style: const TextStyle(color: Colors.white),
                  )),
              onPressed: () async {
                List<Data> data;

                if (!state) {
                  _dataCollect.startRecord();
                  setState(() {
                    state = !state;
                  });
                } else {
                  data = await _dataCollect.cancelAndSave();
                  setState(() {
                    state = !state;
                    _data = data;
                  });
                }
              }),*/
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
                  child: const Text("영상 자르기",
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
