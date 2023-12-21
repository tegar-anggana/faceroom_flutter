import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
  // karna nama file saved image nya udah dinamis (pake timestamp), maka gaakan error.
  // jika file exist lalu mencoba untuk save dengan nama yang sama, maka akan error,
  // tidak akan otomatis mereplace file yang exist.
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

class MyAppBody extends StatefulWidget {
  const MyAppBody({super.key});

  @override
  State<MyAppBody> createState() => _MyAppBodyState();
}

class _MyAppBodyState extends State<MyAppBody> {
  bool isLoading = false;
  final TextEditingController rtspStreamingUrlController = 
      TextEditingController(text: 'rtsp://192.168.100.6:8554/cam');
  final TextEditingController apiEndpointController =
      TextEditingController(text: 'http://192.168.100.6:5000/upload');

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: TextFormField(
              controller: rtspStreamingUrlController,
              decoration: const InputDecoration(labelText: 'RTSP Streaming URL'),
            ),
          ),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: TextFormField(
              controller: apiEndpointController,
              decoration: const InputDecoration(labelText: 'API Endpoint URL'),
            ),
          ),
          const SizedBox(height: 30.0),
          OutlinedButton(
            onPressed: isLoading
                ? null
                : () async {
                    setState(() {
                      isLoading = true;
                    });

                    await captureAndProcessRTSP(rtspStreamingUrlController.text, apiEndpointController.text);

                    setState(() {
                      isLoading = false;
                    });
                  },
            child: const Text("Manual Capture"),
          ),
          if (isLoading) const SizedBox(height: 10.0),
          if (isLoading) const CircularProgressIndicator(),
        ],
      ),
    );
  }
}

Future<void> captureAndProcessRTSP(String rtspUrl, String uploadUrl) async {
  const String basePath = '/storage/emulated/0/Download/';
  const String rtspStreamingUrl =
      'rtsp://192.168.100.6:8554/cam'; // Replace this with your RTSP streaming URL

  if (await Permission.storage.request().isGranted) {
    // Get the current timestamp as a string in the specified format
    String timestamp = DateFormat('yyyy-MM-dd-HH-mm-ss').format(DateTime.now());

    String filename = '$timestamp.png';
    String filePath = '$basePath$filename';

    String commandToExecute =
        '-rtsp_transport tcp -i $rtspUrl -r 1 -f image2 $filePath';
    await FFmpegKit.execute(commandToExecute).then((session) async {
      print('done');
      // Call the upload function with the image file
      await uploadImage(File(filePath), uploadUrl);
    });
  } else if (await Permission.storage.isPermanentlyDenied) {
    openAppSettings();
  }
}

Future<void> uploadImage(File imageFile, String uploadUrl) async {
  try {
    final dio = Dio();

    // Prepare the form data
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(imageFile.path),
    });

    // Make the request
    final response = await dio.post(
      uploadUrl, // Replace with your actual API endpoint
      data: formData,
    );

    // Status & message response
    print('status : ${response.statusCode} ${response.statusMessage}');
  } catch (e) {
    print('Failed to upload image: $e');
  }
}
