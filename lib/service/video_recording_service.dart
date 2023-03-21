

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CameraApp extends StatefulWidget {
  const CameraApp({Key? key}) : super(key: key);

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  bool _cameraLoading = true;
  bool _cameraRecoding = false;
  late CameraController _cameraController;

  @override
  void initState() {

    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _cameraController.dispose();
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
      final file = await _cameraController.stopVideoRecording();
      setState(() {
        _cameraRecoding = false;
      });
      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPage(fillPath: file.path)
      );
      Navigator.push(context, route);
    } else{
      await _cameraController.prepareForVideoRecording();
      await _cameraController.startVideoRecording();
      setState(() {
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
      return cameraPreview();
    }
  }
}
