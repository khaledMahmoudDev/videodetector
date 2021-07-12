import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as fileUtil;
import 'package:video_compress/video_compress.dart';


class NetworkService {
  static bool trustSelfSigned = true;
  static HttpClient getHttpClient() {
    HttpClient httpClient = new HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..badCertificateCallback = ((X509Certificate cert, String host, int port) => trustSelfSigned);

    return httpClient;
  }
  fileUpload(String kMainUrl, XFile file) async {
    print("Video uploadoading");
    assert(file != null);

    var url = Uri.parse(kMainUrl);

    final fileStream = file.openRead();

    int totalByteLength =await file.length();
    print('video total length $totalByteLength');

    final httpClient = getHttpClient();

    final request = await httpClient.postUrl(url);

    // request.headers.set(HttpHeaders.contentTypeHeader, ContentType.binary);

    request.headers.add("filename", fileUtil.basename(file.path));

    request.contentLength = totalByteLength;

    int byteCount = 0;
    Stream<List<int>> streamUpload = fileStream.transform(
      new StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          byteCount += data.length;

          // if (onUploadProgress != null) {
          //   onUploadProgress(byteCount, totalByteLength);
          //   // CALL STATUS CALLBACK;
          // }

          sink.add(data);
        },
        handleError: (error, stack, sink) {
          print(error.toString());
        },
        handleDone: (sink) {
          sink.close();
          // UPLOAD DONE;
        },
      ),
    );

    await request.addStream(streamUpload);

    final httpResponse = await request.close();

    if (httpResponse.statusCode != 200) {
      throw Exception('Error uploading file');
    } else {
      print("Video uploaded");
    }
  }



  sendVideoSinglePart(String kMainUrl, XFile file) async {
    print("Video uploadoading");
    var url = Uri.parse(kMainUrl);
    final httpClient = getHttpClient();
    final request = await httpClient.postUrl(url);
    int byteCount = 0;
    var multipart = await http.MultipartFile.fromPath(fileUtil.basename(file.path), file.path);
    var requestMultipart = http.MultipartRequest('POST', Uri.parse("uri"));
    requestMultipart.files.add(multipart);
    var msStream = requestMultipart.finalize();
    var totalByteLength = requestMultipart.contentLength;
    request.contentLength = totalByteLength;
    // request.headers.set(
    //     HttpHeaders.contentTypeHeader, requestMultipart.headers[HttpHeaders.contentTypeHeader]);
    Stream<List<int>> streamUpload = msStream.transform(
      new StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(data);

          byteCount += data.length;
          //
          // if (onUploadProgress != null) {
          //   onUploadProgress(byteCount, totalByteLength);
          //   // CALL STATUS CALLBACK;
          // }
        },
        handleError: (error, stack, sink) {
          throw error;
        },
        handleDone: (sink) {
          sink.close();
          // UPLOAD DONE;
        },
      ),
    );
    await request.addStream(streamUpload);

    final httpResponse = await request.close();
//
    var statusCode = httpResponse.statusCode;

    if (statusCode ~/ 100 != 2) {
      throw Exception('Error uploading file, Status code: ${httpResponse.statusCode}');
    } else {
      print("Video uploaded");
    }

  }
  sendVideo(String kMainUrl, XFile video) async {
    int totalByteLength1 =await video.length();
    print('video total length before $totalByteLength1');

    MediaInfo mediaInfo = await VideoCompress.compressVideo(
      video.path,
      quality: VideoQuality.DefaultQuality,
      deleteOrigin: false, // It's false by default
    );
    var videoUrl = mediaInfo.path;
    var uri = Uri.parse(kMainUrl);
    print("Video uploadoading");
    int totalByteLength = mediaInfo.filesize;
    print('video total length $totalByteLength');
    var request = http.MultipartRequest('POST', uri);
    var multipartFile = await http.MultipartFile.fromPath("file", videoUrl);
    request.files.add(multipartFile);
    http.StreamedResponse response = await request.send();
    print(
        'video request files ${request.files}\n url ${request.url}\n fields ${request.fields}\n headers ${request.headers}\n method ${request.method}\n');
    response.stream.transform(utf8.decoder).listen((value) {
      print('video val val');
      print(value);
    });
    if (response.statusCode == 200) {
      print("Video uploaded");
    } else {
      print("Video upload failed");
    }
  }
  sendVideoDio(String kMainUrl, XFile video) async {
    print("Video uploadoading");
    String fileName = video.path;
    print("File base name: $fileName");

    try {
      FormData formData = FormData.fromMap({
        "file":
        await MultipartFile.fromFile(fileName, filename:fileName),
      });

      Response response =
      await Dio().post(kMainUrl, data: formData);
      print("File upload response: $response");

      // Show the incoming message in snakbar
      print(response.data['message']);
    } catch (e) {
      print("Exception Caught: $e");
    }
  }
}
