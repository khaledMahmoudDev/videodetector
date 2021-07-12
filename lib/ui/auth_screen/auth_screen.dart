import 'package:flutter/material.dart';
import 'package:videodetector/constant/Constant.dart';
import 'package:videodetector/ui/login/login_screen.dart';

class AuthScreen extends StatelessWidget {
  TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.3),
        ),
        Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 50),
              ),
              GestureDetector(
                  onTap: () {
                    if(_textFieldController.text.isNotEmpty){
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              HomeScreen(_textFieldController.text)));
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Please enter Server URL"),
                      ));
                    }

                  },
                  child: roundedRectButton(
                      "Let's get Started", signInGradients, false)),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_textFieldController.text),
              ),
              GestureDetector(
                  onTap: () {
                    _displayTextInputDialog(context);
                  },
                  child: Text('Add server Url',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)))

              // GestureDetector(
              //     onTap: () {
              //       Navigator.of(context).pushNamed(SIGNUP_SCREEN);
              //     },
              //     child: roundedRectButton(
              //         "Create an Account", signUpGradients, false)),
            ],
          ),
        )
      ],
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Server Url'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "https://www.helloworld.com"),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                print(_textFieldController.text);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}

Widget roundedRectButton(
    String title, List<Color> gradient, bool isEndIconVisible) {
  return Builder(builder: (BuildContext mContext) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Stack(
        alignment: Alignment(1.0, 0.0),
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(mContext).size.width / 1.7,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: Text(title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500)),
            padding: EdgeInsets.only(top: 16, bottom: 16),
          ),
          Visibility(
            visible: isEndIconVisible,
            child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: ImageIcon(
                  AssetImage("assets/ic_forward.png"),
                  size: 30,
                  color: Colors.white,
                )),
          ),
        ],
      ),
    );
  });
}

const List<Color> signInGradients = [
  Color(0xFF0EDED2),
  Color(0xFF03A0FE),
];

const List<Color> signUpGradients = [
  Color(0xFFFF9945),
  Color(0xFFFc6076),
];
