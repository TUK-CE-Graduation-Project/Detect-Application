import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:test2/service/position_stream.dart';
import 'package:test2/service/video_playback_service.dart';
import 'package:test2/service/video_recording_service.dart';

import '../network/network_helper.dart';
import 'location_service.dart';

class Data {
  Position? position;
  AccelerometerEvent? accelerometerEvent;
  DateTime time;

  Data({this.accelerometerEvent, required this.position, required this.time});
}

class Data2 {
  List<Data> data;
  int time;

  Data2({required this.data, required this.time});
}

class AccelerometerService {
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  final PositionStream _positionStream = PositionStream();
  Position? _position = MyLocation().position;

  List<Data> _data = [];
  AccelerometerEvent? _event;

  Stopwatch? _stopwatch;
  Timer? _timer;
  List<int> _eventTimeList = [];

  void startRecord() async {

    _data = [];
    _stopwatch = Stopwatch();
    _stopwatch!.start();
    _position = await MyLocation().getMyCurrentLocation();

    // 위치 데이터 받는 곳
    _positionStream.controller.stream.listen((event) {
      _position = event;
    });

    // 가속도 데이터 받는 곳
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      _event = event;
      // 일정치 이상이면 Timer 저장
      // ex: event.x > 5
      if (true){
        _eventTimeList.add(_stopwatch!.elapsed.inSeconds);
        log("stopwatch: ${_stopwatch!.elapsed.inSeconds}");
      }
    }));

    // 0.002초 마다 한 번씩 데이터 저장
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      _data.add(Data(
          accelerometerEvent: _event,
          position: _position,
          time: DateTime.now()));
    });
  }

  Future<File> createFile() async {
    final directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/data.txt');

    return file;
  }

  Future<List<Data>> cancelAndSave() async {
    int time = _stopwatch!.elapsed.inSeconds;
    cancel();

    String dataString = '$time\n';
    for (var element in _data) {
      dataString +=
          '${element.position?.latitude}, ${element.position?.longitude}, ${element.accelerometerEvent?.x}, ${element.accelerometerEvent?.y}, ${element.accelerometerEvent?.z} ${element.time}\n';
    }
    File file = await createFile();
    file.writeAsString(dataString);

    FormData formData = FormData.fromMap({'file': file});
    DioClient().post('url', formData);

    return _data;
  }

  void cancel() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _timer?.cancel();
    _stopwatch?.stop();
    _stopwatch?.reset();
    _positionStream.dispose();
  }
}
