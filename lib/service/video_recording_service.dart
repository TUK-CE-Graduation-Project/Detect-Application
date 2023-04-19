

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:test2/result.dart';
import 'package:test2/service/video_playback_service.dart';

import 'accelerometer_data_service.dart';

class CameraApp extends StatefulWidget {
  const CameraApp({Key? key, required this.result}) : super(key: key);

  final CallBackResult result;

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  final AccelerometerService _dataCollect = AccelerometerService();
  bool _cameraLoading = true;
  bool _cameraRecoding = false;
  bool _dataCollectState = false;
  CallBackResult result = CallBackResult(
      data: AccelerometerData(dataList: [], eventTimeList: []),
      filePath: "");


  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _initCamera();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _cameraController.dispose();
    _dataCollect.cancel();
  }

  // Cameracontroller 초기화
  _initCamera() async {

    // 사용할 카메라 목록 받기
    final cameras = await availableCameras();
    // 전면 카메라 사용
    final front = cameras.firstWhere((element) => element.lensDirection == CameraLensDirection.back);
    // 해상도 조절

    _cameraController = CameraController(front, ResolutionPreset.high);

    await _cameraController.initialize();

    setState(() {
      _cameraLoading = false;
    });
  }
  
  Widget cameraPreview(CameraController cameraController){
    return Center(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CameraPreview(cameraController),
          Padding(
            padding: const EdgeInsets.all(25),
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              child: Icon(_cameraRecoding? Icons.stop: Icons.circle),
              onPressed: () {
                _recordVideo();
              },
            )
          )
        ],
      )
    );
  }

  _finishDialog() async{
    return AlertDialog(
      content: SingleChildScrollView(
        child: ListBody(
          children: const <Widget>[
            Text('촬영을 종료하시겠습니까?')
          ],
        )
      ),
      actions: <Widget>[
        FloatingActionButton(
          child: const Text('종료 및 이동'),
          onPressed: () async {


            Navigator.pop(context, true);
          }
        ),
        FloatingActionButton(
            child: const Text('취소'),
            onPressed: (){
              Navigator.pop(context);
            }
        ),
      ],
    );
  }

  _recordVideo() async{
    if(_cameraRecoding){
      final file = await _cameraController.stopVideoRecording();  //  비디오 녹화 중지
      var data = await _dataCollect.cancelAndSave();

      setState(() {
        _cameraRecoding = false;
        _dataCollectState = !_dataCollectState;
      });

      /*final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPlayback(filePath: file.path)
      );*/
      // 동영상 녹화 후 어떻게 할까?
      //  BuildContext를 비동기 작업과 함께 사용 x -> wait 이후 사용할 BuildContext를 가지고 있으면 오류가 어디서 발생했는지 찾기 힘듬
      if (!mounted) return; // 이 코드를 context 사용한 부분 앞에 붙임 -> 위젯이 마운트 되지 않으면 async를 썼을 때 그 안에 아무런 값도 들어있지 않을 수 있기 때문
      Navigator.pop(context, CallBackResult(data: data, filePath: file.path));
      _finishDialog();
    } else{
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();  //  비디오 녹화 시작

      _dataCollect.startRecord();
      setState(() {
        _dataCollectState = !_dataCollectState;
        _cameraRecoding = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraLoading){
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator()
        )
      );
    } else{
      return cameraPreview(_cameraController);
    }
  }
}
