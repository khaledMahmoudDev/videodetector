import 'package:http/http.dart' as http;

class NetworkService{

  sendVideo(String kMainUrl)async{

    var response = await http.post(Uri.parse('$kMainUrl'),);
    if (response.statusCode == 200) {
      return true;
    } else {
      return null;
    }


  }
}