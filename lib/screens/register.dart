import 'dart:convert';
import 'package:cstechassignment/screens/landing.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget {
  final String userID;
  const RegistrationScreen({super.key, required this.userID});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController emailControl = TextEditingController();
  TextEditingController passwordControl = TextEditingController();
  TextEditingController referralControl = TextEditingController();

  bool _isPasswordVisible = false;

  String error = '';
  String finalEmail = '';
  bool registering = false;

  void register() async {
    print("Trying to register!");

    final uid = widget.userID;
    final email = emailControl.text.trim();
    final password = passwordControl.text.trim();
    final referral = '';

    String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(emailPattern);

    setState(() {
      error = '';
    });

    if (email == null || email.isEmpty) {
      setState(() {
        error = 'Please enter an email';
      });
      return;
    }

    if (!regex.hasMatch(email)) {
      setState(() {
        error = 'Enter a valid email';
      });
      return;
    }

    if (password == null || password.isEmpty) {
      setState(() {
        error = 'Please enter a password';
      });
      return;
    }

    setState(() {
      registering = true;
    });

    finalEmail = email;
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST',
        Uri.parse('http://devapiv4.dealsdray.com/api/v2/user/email/referral'));
    request.body = json.encode({
      "email": "$email",
      "password": "$password",
      "referralCode": "$referral",
      "userId": "$uid"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(""),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFFD71A21),
          onPressed: () async {
            register();

            if (error == '' && error.isEmpty) {
              final SharedPreferences shared =
                  await SharedPreferences.getInstance();
              shared.setString("email", emailControl.text);

              Future.delayed(Duration(seconds: 2), () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LandingPage(
                        email: finalEmail,
                      ),
                    ));
                setState(() {
                  registering = false;
                });
              });
            }
          },
          child: Icon(
            Icons.arrow_forward_sharp,
            color: Colors.white,
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset('assets/deck.png'),
                ),
                registering
                    ? Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                  "Please wait, while we register you in.."),
                            ),
                            CircularProgressIndicator(),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 45,
                          ),
                          Text(
                            "Let's Begin!",
                            style: TextStyle(
                                fontSize: 44, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 18.0, bottom: 38),
                            child: Text(
                              "Please enter your credentials to proceed",
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                          TextFormField(
                            controller: emailControl,
                            decoration: InputDecoration(labelText: "You Email"),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: TextFormField(
                              controller: passwordControl,
                              obscureText: _isPasswordVisible,
                              decoration: InputDecoration(
                                  labelText: "Create Password",
                                  suffixIcon: IconButton(
                                    icon: Icon(_isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  )),
                            ),
                          ),
                          TextFormField(
                            controller: referralControl,
                            decoration: InputDecoration(
                                labelText: "Referral Code (Optional)"),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "$error",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),

                          // ElevatedButton(
                          //     onPressed: () {
                          //       register();
                          //       Navigator.push(
                          //           context,
                          //           MaterialPageRoute(
                          //             builder: (context) => LandingPage(
                          //               email: '',
                          //             ),
                          //           ));
                          //     },
                          //     child: Text("Register"))
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
