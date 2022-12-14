
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// import 'package:path_provider/path_provider.dart';
// import 'package:camera/camera.dart';


// class CameraScreen extends StatefulWidget {
//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State {
//   late CameraController controller;
//   late List cameras;
//   late int selectedCameraIndex;
//   late String imgPath;

//   @override
//   void initState() {
//     super.initState();
//     availableCameras().then((availableCameras) {
//       cameras = availableCameras;

//       if (cameras.isNotEmpty) { // up me - cameras.length > 0
//         setState(() {
//           selectedCameraIndex = 1;
//         });
//         _initCameraController(cameras[selectedCameraIndex]).then((void v) {});
//       } else {
//         print('No camera available');
//       }
//     }).catchError((err) {
//       print('Error :${err.code}Error message : ${err.message}');
//     });
//   }

//   Future _initCameraController(CameraDescription cameraDescription) async {
//     if (controller != null) {
//       await controller.dispose();
//     }
//     controller = CameraController(cameraDescription, ResolutionPreset.high);

//     controller.addListener(() {
//       if (mounted) {
//         setState(() {});
//       }

//       if (controller.value.hasError) {
//         print('Camera error ${controller.value.errorDescription}');
//       }
//     });

//     try {
//       await controller.initialize();
//     } on CameraException catch (e) {
//       _showCameraException(e);
//     }
//     if (mounted) {
//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         child: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               Expanded(
//                 flex: 1,
//                 child: _cameraPreviewWidget(),
//               ),
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Container(
//                   height: 120,
//                   width: double.infinity,
//                   padding: EdgeInsets.all(15),
//                   color: Colors.black,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: <Widget>[
//                       _cameraToggleRowWidget(),
//                       _cameraControlWidget(context),
//                       Spacer()
//                     ],
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _cameraPreviewWidget() {
//     if (controller == null || !controller.value.isInitialized) {
//       return const Text(
//         'Loading',
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 20.0,
//           fontWeight: FontWeight.w900,
//         ),
//       );
//     }

//     return AspectRatio(
//       aspectRatio: controller.value.aspectRatio,
//       child: CameraPreview(controller),
//     );
//   }

//   Widget _cameraControlWidget(context) {
//     return Expanded(
//       child: Align(
//         alignment: Alignment.center,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           mainAxisSize: MainAxisSize.max,
//           children: <Widget>[
//             FloatingActionButton(
//               child: const Icon(
//                 Icons.camera,
//                 color: Colors.black,
//               ),
//               backgroundColor: Colors.white,
//               onPressed: () {
//                 _onCapturePressed(context);
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _cameraToggleRowWidget() {
//     if (cameras == null || cameras.isEmpty) {
//       return Spacer();
//     }
//     CameraDescription selectedCamera = cameras[selectedCameraIndex];
//     CameraLensDirection lensDirection = selectedCamera.lensDirection;

//     return Expanded(
//       child: Align(
//         alignment: Alignment.centerLeft,
//         child: FlatButton.icon(
//           onPressed: _onSwitchCamera,
//           icon: Icon(
//             _getCameraLensIcon(lensDirection),
//             color: Colors.white,
//             size: 24,
//           ),
//           label: Text(
//             '${lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1).toUpperCase()}',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
//           ),
//         ),
//       ),
//     );
//   }

//   IconData _getCameraLensIcon(CameraLensDirection direction) {
//     switch (direction) {
//       case CameraLensDirection.back:
//         return CupertinoIcons.switch_camera;
//       case CameraLensDirection.front:
//         return CupertinoIcons.switch_camera_solid;
//       case CameraLensDirection.external:
//         return Icons.camera;
//       default:
//         return Icons.device_unknown;
//     }
//   }

//   void _showCameraException(e) { // up me CameraException
//     String errorText = 'Error:${e.code}\nError message : ${e.description}';
//     print(errorText);
//   }

//   void _onCapturePressed(context) async {
//     try {
//       DateTime now = DateTime.now();
//       String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);

//       // final path = join((await getTemporaryDirectory()).path, '${formattedDate}.png');
//       //final pathup = getTemporaryDirectory().path + '1234.png';

//       await controller.takePicture(); // re me - CameraException
//       //print("path :"+path);
//       // Navigator.of(context).pushAndRemoveUntil(
//       //     MaterialPageRoute(
//       //         builder: (context) => AttendanceScreen(
//       //               imgPath: path,
//       //             )),
//       //     (Route<dynamic> route) => false);
//     } catch (e) {
//       _showCameraException(e);
//     }
//   }

//   void _onSwitchCamera() {
//     selectedCameraIndex =
//         selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
//     CameraDescription selectedCamera = cameras[selectedCameraIndex];
//     _initCameraController(selectedCamera);
//   }
// }
