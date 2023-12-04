import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('RTSP Streaming Capture'),
        ),
        body: const MyAppBody(),
      ),
    );
  }
}

class MyAppBody extends StatelessWidget {
  const MyAppBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () async {
              await capture();
            },
            child: const Text("Manual Capture"),
          )
        ],
      ),
    );
  }
}

Future<void> capture() async {
  const String basePath = '/storage/emulated/0/Download/';
  const String video = basePath + 'output.mp4';
  const String audioPath = basePath + 'audio.mp3';
  const String imagePath = basePath + '003.jpeg';
  const String outputPath = basePath + 'videoWithoutVoice.mp4';

  if (await Permission.storage.request().isGranted) {
    String commandToExecute =
        '-i ${video} -r 1 -f image2 ${basePath + 'image-%1d.png'}';
    await FFmpegKit.execute(commandToExecute).then((session) async {
      final returnCode = await session.getReturnCode();
      if (ReturnCode.isSuccess(returnCode)) {
        print("completed create");
      } else if (ReturnCode.isCancel(returnCode)) {
        print("cancel");
      } else {
        print("error ");
      }
    });
  } else if (await Permission.storage.isPermanentlyDenied) {
    openAppSettings();
  }
}
