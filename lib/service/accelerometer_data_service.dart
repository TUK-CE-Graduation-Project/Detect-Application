import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:test2/service/position_stream.dart';

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
  Data2? _data2;
  late Stopwatch _stopwatch;
  AccelerometerEvent? _event;

  late Timer _timer;
  void accelermeter() async {
    _data = [];
    _stopwatch = Stopwatch();
    _stopwatch.start();
    _position = await MyLocation().getMyCurrentLocation();

    _positionStream.controller.stream.listen((event) {
      _position = event;
    });
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      _event = event;
    }));

    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      _data.add(Data(
          accelerometerEvent: _event,
          position: _position,
          time: DateTime.now()));
    });
  }

  Future<File> createFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/data');

    return file;
  }

  Future<List<Data>> save() async {
    _data2 = Data2(data: _data, time: _stopwatch.elapsed.inSeconds);
    cancel();

    File file = await createFile();
    file.writeAsString(
        'gps: ${_position?.latitude}, ${_position?.longitude} data: $_data');
    print(file.path);
    // 서버 전송
    DioClient().post('url', {'data': _data});

    return _data;
  }

  void cancel() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _timer.cancel();
    _positionStream.dispose();
  }
}
