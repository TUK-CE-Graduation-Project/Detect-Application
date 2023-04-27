import 'package:camera/camera.dart';
import 'package:test2/service/accelerometer_data_service.dart';

class PotholeRegistrationRequest {
  int? geotabId;
  int xacc;
  int yacc;
  int zacc;
  Point point;
  dynamic response;

  PotholeRegistrationRequest({
    this.geotabId,
    required this.xacc,
    required this.yacc,
    required this.zacc,
    required this.point
  });
}

class Point {
  late int x;
  late int y;
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
