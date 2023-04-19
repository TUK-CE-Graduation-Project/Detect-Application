import 'package:camera/camera.dart';
import 'package:test2/service/accelerometer_data_service.dart';

class NetWorkResult {
  Result result;
  dynamic response;

  NetWorkResult({
    required this.result,
    this.response,
  });
}

enum Result {
  fail,
  success,
}

class CallBackResult {
  AccelerometerData data;
  String filePath;

  CallBackResult({required this.data, required this.filePath});
}
