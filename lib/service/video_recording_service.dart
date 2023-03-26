

import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test2/service/video_playback_service.dart';

import 'accelerometer_data_service.dart';

class CameraApp extends StatefulWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  bool _cameraLoading = true;
  bool _cameraRecoding = false;
  late CameraController _cameraController;

  Timer? _timer;  //  타이머
  int _seconds = 0;  //


  @override
  void initState() {

    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _cameraController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // Cameracontroller 초기화
  _initCamera() async {

    // 사용할 카메라 목록 받기
    final cameras = await availableCameras();
    // 전면 카메라 사용
    final front = cameras.firstWhere((element) => element.lensDirection == CameraLensDirection.front);
    // 해상도 조절

    await _cameraController.initialize();
    setState(() {
      _cameraLoading = false;
    });
  }
  
  Widget cameraPreview(){
    return Center(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CameraPreview(_cameraController),
          Padding(
            padding: const EdgeInsets.all(25),
            child: FloatingActionButton(
              backgroundColor: Colors.red,
              child: Icon(_cameraRecoding? Icons.stop: Icons.circle),
              onPressed: () => _recordVideo(),
            )
          )
        ],
      )
    );
  }

  _recordVideo() async{
    if(_cameraRecoding){
      final file = await _cameraController.stopVideoRecording();  //  비디오 녹화 중지
      _timer!.cancel();
      setState(() {
        _cameraRecoding = false;
      });
      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPlayback(filePath: file.path)
      );
      // 동영상 녹화 후 어떻게 할까?
      //  BuildContext를 비동기 작업과 함께 사용 x -> wait 이후 사용할 BuildContext를 가지고 있으면 오류가 어디서 발생했는지 찾기 힘듬
      if (!mounted) return; // 이 코드를 context 사용한 부분 앞에 붙임 -> 위젯이 마운트 되지 않으면 async를 썼을 때 그 안에 아무런 값도 들어있지 않을 수 있기 때문
      Navigator.push(context, route);
    } else{
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();  //  비디오 녹화 시작
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _seconds++; //  타이머 시작
        });
      });

      // imu 센서 감지도 추가하기

     setState(() {
        _cameraRecoding = true;
      });
    }
  }

  changeSeconds(int seconds){ //  맞나?
    var hour = (seconds/(60*60))%24;
    var minute = (seconds/60)%60;
    var second = (seconds)%60;
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
      return cameraPreview();
    }
  }
}
