import 'dart:async';
import 'dart:convert';

import 'package:cstechassignment/screens/landing.dart';
import 'package:cstechassignment/screens/otpVerification.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String? userID = '';
String? deviceID = '';
String finalEmail = '';

class HomeScreen extends StatefulWidget {
  final String deviceId;
  const HomeScreen({super.key, required this.deviceId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController mobile = TextEditingController();
  String mobileNo = '';
  String id = '';
  bool pageInit = false;

  final _formKey = GlobalKey<FormState>();

  Future getValidation() async {
    setState(() {
      pageInit = true;
    });
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    var email = sharedPreferences.getString("email");
    setState(() {
      if (email != null) {
        finalEmail = email;
      }
    });
  }

  Future<void> sendOTP() async {
    mobileNo = mobile.text.trim();
    id = widget.deviceId.trim();

    var headers = {'Content-Type': 'application/json'};

    var request = http.Request(
        'POST', Uri.parse('http://devapiv4.dealsdray.com/api/v2/user/otp'));
    request.body =
        json.encode({"mobileNumber": "$mobileNo", "deviceId": "$id"});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> responseData = jsonDecode(responseBody);
      print(responseData);
      userID = responseData['data']['userId'];
      deviceID = responseData['data']['deviceId'];
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    getValidation().whenComplete(() async {
      if (finalEmail != '') {
        Timer(
            Duration(seconds: 2),
            () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LandingPage(
                    email: finalEmail,
                    //!!!!!!!!!! pass email here
                  ),
                )));
      }
      setState(() {
        pageInit = false;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(''),
        centerTitle: true,
      ),
      body: pageInit
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Hero(
                        tag: 'splash',
                        child: Image.asset('assets/deck.png')),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Color(0xFFD71A21)),
                      minimumSize: WidgetStateProperty.all<Size>(Size(130, 45)),
                    ),
                    child: Text(
                      "Phone",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Glad to see you!",
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 30),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0, bottom: 40),
                          child: Text(
                            "Please provide your phone number",
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 18),
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: mobile,
                                decoration: InputDecoration(
                                  labelText: "Phone",
                                  // border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a phone number';
                                  }
                                  if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                                    return 'Please enter a valid 10-digit phone number';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      sendOTP();
                                      setState(() {
                                        pageInit = true;
                                      });
                                      Future.delayed(Duration(seconds: 3), () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OtpVerificationScreen(
                                                mobilenumber: mobileNo,
                                                did: id,
                                                userId: userID!,
                                                deviceId: deviceID!,
                                              ),
                                            ));
                                        setState(() {
                                          pageInit = false;
                                        });
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content: Text(
                                                  "Please enter correct number!")));
                                    }
                                  },
                                  style: ButtonStyle(
                                    shape:
                                        WidgetStateProperty.all<OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            10), // Rounded corners
                                      ),
                                    ),
                                    backgroundColor:
                                        WidgetStateProperty.all<Color>(
                                            Color(0xFFD71A21)),
                                    minimumSize: WidgetStateProperty.all<Size>(
                                        Size(330, 62)),
                                  ),
                                  child: Text(
                                    "SEND CODE",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
