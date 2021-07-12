import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';


class NetworkService {
  Future<String?> sendVideoDio(String kMainUrl, String  video) async {
    print("Video uploadoading");
    String filePath = video;
    print("File base name: $filePath");

    try {
      FormData formData = FormData.fromMap({
        "file":
        await MultipartFile.fromFile(filePath, filename:filePath),
      });

      Response response =
      await Dio().post(kMainUrl, data: formData);
      print("File upload response: $response");
      print(response.data['prediction']);


      return '${response.data['prediction']}';

    } catch (e) {
      print("Exception Caught: $e");
      return 'Error try again';
    }
  }
}
