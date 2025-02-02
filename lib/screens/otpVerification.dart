import 'dart:async';
import 'dart:convert';

import 'package:cstechassignment/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OtpVerificationScreen extends StatefulWidget {
  final String did;
  final String deviceId;
  final String userId;
  final String mobilenumber;
  const OtpVerificationScreen(
      {super.key,
      required this.deviceId,
      required this.userId,
      required this.mobilenumber,
      required this.did});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController1 = TextEditingController();
  final TextEditingController _otpController2 = TextEditingController();
  final TextEditingController _otpController3 = TextEditingController();
  final TextEditingController _otpController4 = TextEditingController();

  bool isDisabled = false;
  int timerCountdown = 20;
  late Timer? countdownTimer;

  String enteredOtp = "";

  String userID = "";
  String deviceID = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    countdownTimer = null;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    countdownTimer?.cancel();
    super.dispose();
  }

  void disableOtp() {
    setState(() {
      isDisabled = true;
    });

    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timerCountdown == 0) {
        setState(() {
          isDisabled = false;
          timerCountdown = 20;
        });
        countdownTimer?.cancel();
      } else {
        setState(() {
          timerCountdown--;
        });
      }
    });
  }

  void verify() async {

    final uid = widget.userId;
    final did = widget.deviceId;

    enteredOtp = _otpController1.text.trim() +
        _otpController2.text.trim() +
        _otpController3.text.trim() +
        _otpController4.text.trim();

    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST',
        Uri.parse(
            'http://devapiv4.dealsdray.com/api/v2/user/otp/verification'));
    request.body = json
        .encode({"otp": "$enteredOtp", "deviceId": "$did", "userId": "$uid"});
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> responseData = jsonDecode(responseBody);
      final result = responseData['status'].toString();
      if (result == "1") {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('OTP Verified Successfully')));
        Future.delayed(
          Duration(seconds: 2),
          () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegistrationScreen(
                    userID: uid,
                  ),
                ));
          },
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Invalid OTP')));
      }
    } else {
    }
  }

  Future<void> sendOTPAgain(mobileNo, id) async {
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
      userID = responseData['data']['userId'];
      deviceID = responseData['data']['deviceId'];
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: Image.asset('assets/otp.png'),
              ),
              SizedBox(
                height: 40,
              ),
              Text(
                'OTP Verification',
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "We have sent a unique OTP number to your mobile +91-${widget.mobilenumber}",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 30),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _OtpField(_otpController1),
                      _OtpField(_otpController2),
                      _OtpField(_otpController3),
                      _OtpField(_otpController4),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: timerCountdown != 20
                              ? Text("$timerCountdown")
                              : Text("")),
                      isDisabled
                          ? Text("Wait before making another request.")
                          : InkWell(
                              onTap: isDisabled
                                  ? null
                                  : () {
                                      disableOtp();
                                      print("Send Again!");
                                      sendOTPAgain(
                                          {widget.mobilenumber}, {widget.did});
                                    },
                              child: Text(
                                "SEND AGAIN",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline),
                              ),
                            )
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30),
              Center(
                child: TextButton(
                  onPressed: () {
                    print("Button pressed!");
                    verify();
                  },
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10), // Rounded corners
                      ),
                    ),
                    backgroundColor:
                        WidgetStateProperty.all<Color>(Color(0xFFD71A21)),
                    minimumSize: WidgetStateProperty.all<Size>(Size(330, 62)),
                  ),
                  child: Text(
                    "Verify OTP",
                    style: TextStyle(
                        fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _OtpField(TextEditingController controller) {
    return SizedBox(
      width: 60,
      height: 70,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        maxLength: 1,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}
