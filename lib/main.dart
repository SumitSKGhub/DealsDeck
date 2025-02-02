import 'dart:convert';

import 'package:cstechassignment/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

String? osV = '';
String? name = '';
String ip = '';
String id = '';
String rcvdID = '';

Future<void> getinfo() async {
  final deviceInfoPlugin = DeviceInfoPlugin();

  final deviceInfo = await deviceInfoPlugin.androidInfo;
  osV = deviceInfo.version.baseOS;
  name = deviceInfo.manufacturer + ' ' + deviceInfo.model;
  id = deviceInfo.id;
  final response =
  await http.get(Uri.parse('https://api64.ipify.org?format=json'));
  final data = jsonDecode(response.body);
  ip = data['ip'];
}

void deviceInfoAPI() async {
  var request = http.Request('POST',
      Uri.parse('http://devapiv4.dealsdray.com/api/v2/user/device/add'));
  request.body = '''{\r\n    "deviceType": "andriod",\r\n    
      "deviceId": "$id",\r\n    
      "deviceName": "$name",\r\n    
      "deviceOSVersion": "$osV",\r\n    
      "deviceIPAddress": "$ip",\r\n 
      "buyer_gcmid": "",\r\n    
      "buyer_pemid": "",\r\n    
        }''';

  http.StreamedResponse response = await request.send();
  String responsebody = await response.stream.bytesToString();
  final Map<String, dynamic> responseData = jsonDecode(responsebody);
  rcvdID = responseData['data']['deviceId'];
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  getinfo();
  deviceInfoAPI();
  Future.delayed(Duration(seconds: 3),(){
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  static late _MyAppState instance;

  const MyApp({super.key});

  static void restartApp(){
    instance.restartApp();
  }

  @override
  State<MyApp> createState() {
    instance = _MyAppState();
    return instance;
  }
}

class _MyAppState extends State<MyApp> {
  Key _key = UniqueKey();

  void restartApp(){
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 1000);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      key: _key,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:
      SplashScreen()
      ,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>
            HomeScreen(
            deviceId: rcvdID,
        )),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child:
      Stack(
        children: [
          Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/bg.png'), // Replace with your image path
                  fit: BoxFit.cover, // Stretches and fills the screen
                ),
              ),
            ),
          Hero(
            tag: 'splash',
            child: Center(
              child: Image.asset(
                "assets/logo_foreground.png",
                width: 200,
                height: 200,
              ),
            ),
          )
        ],
      ),
    );
  }
}
