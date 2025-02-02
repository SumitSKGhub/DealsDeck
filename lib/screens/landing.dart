import 'dart:convert';

import 'package:cstechassignment/main.dart';
import 'package:cstechassignment/screens/home.dart';
import 'package:cstechassignment/screens/register.dart';
import 'package:cstechassignment/widgets/customappbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatefulWidget {
  final String email;
  const LandingPage({super.key, required this.email});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isLoading = true;
  String banner_one = '', banner_two = '', banner_three = '';
  String itemName = 'Item Name';
  List icons = [];
  List labels = [];
  List exclusiveIcon = [];
  List exclusiveLabel = [];
  List exclusiveOffer = [];
  int navIndex = 0;

  List<Widget> body = const [
    Icon(Icons.home),
    Icon(Icons.menu),
    Icon(Icons.person),
  ];

  void getProducts() async {
    setState(() {
      _isLoading = true;
    });
    var request = http.Request(
        'GET',
        Uri.parse(
            'http://devapiv4.dealsdray.com/api/v2/user/home/withoutPrice'));
    request.body = '''''';

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> responseData = jsonDecode(responseBody);

      if (responseData['data']['banner_one'][0] != null) {
        final b_one = responseData['data']['banner_one'][0]['banner'];
        final b_two = responseData['data']['banner_two'][0]['banner'];
        final b_three = responseData['data']['banner_three'][0]['banner'];

        setState(() {
          banner_one = b_one.toString();
          banner_two = b_two.toString();
          banner_three = b_three.toString();
        });
      }

      if (responseData['data']['category'] != null) {
        final cat = responseData['data']['category'];
        cat.forEach((element) {
          icons.add(element["icon"]);
          labels.add(element["label"]);
        });
      }

      if (responseData['data']['categories_listing'] != null) {
        final catListing = responseData['data']['categories_listing'];
        catListing.forEach((element) {
          exclusiveIcon.add(element["icon"]);
          exclusiveLabel.add(element["label"]);
          exclusiveOffer.add(element["offer"]);
        });
      }
    } else {
      print(response.reasonPhrase);
    }
    setState(() {
      _isLoading = false;
    });
  }

  String user = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProducts();

    if (widget.email != '') {
      user = widget.email.split('@')[0];
    }
  }

  double heightContainer = 335;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            shadowColor: Colors.black26,
            title: CustomAppBar()),
        bottomNavigationBar: NavigationBar(
            backgroundColor: Colors.white54,
            indicatorColor: Colors.white,
            selectedIndex: navIndex,
            onDestinationSelected: (index) =>
                setState(() => this.navIndex = index),
            destinations: [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined,
                      color: navIndex == 0 ? Colors.redAccent : Colors.grey),
                  label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.category_outlined,
                      color: navIndex == 1 ? Colors.redAccent : Colors.grey),
                  label: 'Categories'),
              NavigationDestination(
                  icon: Icon(Icons.deck_outlined,
                      color: navIndex == 2 ? Colors.redAccent : Colors.grey),
                  label: 'Deals'),
              NavigationDestination(
                  icon: Icon(Icons.shopping_cart_outlined,
                      color: navIndex == 3 ? Colors.redAccent : Colors.grey),
                  label: 'Cart'),
              NavigationDestination(
                  icon: Icon(Icons.person_outline,
                      color: navIndex == 4 ? Colors.redAccent : Colors.grey),
                  label: 'Profile'),
            ]),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            getProducts();
          },
          icon: Icon(
            Icons.message_outlined,
            color: Colors.white,
          ),
          label:
              Text("Chat", style: TextStyle(fontSize: 20, color: Colors.white)),
          backgroundColor: Colors.redAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          extendedPadding: EdgeInsets.symmetric(horizontal: 24),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    // colors: [Colors.teal, Colors.greenAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Deals ',
                        style: TextStyle(
                          // color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Times new roman',
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        'Deck',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Times new roman',
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: Row(
                  spacing: 10,
                  children: [
                    Icon(Icons.info_outline),
                    Text(
                      "App by Sumit Kamble",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        body: navIndex == 4
            ? widget.email != ''
                ? Center(
                    child: Column(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Wrap(
                          children: [ Text(
                            "Hello, you've logged in as $user",
                            style: TextStyle(fontSize: 22),
                          ),
                          ]
                        ),
                        Icon(Icons.face),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: InkWell(onTap: () async{
                            SharedPreferences shared = await SharedPreferences.getInstance();
                            shared.remove("email");
                            MyApp.restartApp();
                            // Navigator.push(context,
                            //     MaterialPageRoute(builder: (context) =>
                            //     ));
                          },
                              child: Text(
                            "Logout",
                            style:
                                TextStyle(decoration: TextDecoration.underline,fontSize: 14),
                          )
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: Column(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("You may not be logged in.."),
                        Icon(Icons.face)
                      ],
                    ),
                  )
            : _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                padding: EdgeInsets.all(20),
                                child: banner_one != ''
                                    ? Image.network(banner_one)
                                    : Text("No Image"),
                              ),
                              Container(
                                padding: EdgeInsets.all(20),
                                child: banner_two != ''
                                    ? Image.network(banner_two)
                                    : Text("No Image"),
                              ),
                              Container(
                                padding: EdgeInsets.all(20),
                                child: banner_three != ''
                                    ? Image.network(banner_three)
                                    : Text("No Image"),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(colors: [
                                Color(0xFF8186EA),
                                Color(0xFF555BCD)
                              ]),
                            ),
                            height: 150,
                            width: MediaQuery.sizeOf(context).width,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "KYC Pending",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                    "You need to provide the required"
                                    " documents for your account activation.",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Click Here",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        // false
                        //     ? Center(
                        //         child: CircularProgressIndicator(),
                        //       )
                        //     :
                        Row(
                          // mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Column(children: [
                                  Image.network(icons[0]),
                                  Text(labels[0])
                                ])),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Column(children: [
                                  Image.network(icons[1]),
                                  Text(labels[1])
                                ])),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Column(children: [
                                  Image.network(icons[2]),
                                  Text(labels[2])
                                ])),
                            Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Column(children: [
                                  Image.network(icons[3]),
                                  Text(labels[3])
                                ])),
                          ],
                        ),
                        Container(
                          height: 450,
                          color: Color(0xFF53AEC3),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22.0,
                                  vertical: 30,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                      "EXCLUSIVE FOR YOU",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white),
                                    )),
                                    Icon(
                                      Icons.arrow_forward_outlined,
                                      color: Colors.white,
                                      size: 30,
                                    )
                                  ],
                                ),
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: heightContainer,
                                            width: 200,
                                            color: Colors.white,
                                          ),
                                          Positioned(
                                            left: 75,
                                            top: heightContainer / 11,
                                            child: Container(
                                              child: Image.network(
                                                  exclusiveIcon[0]),
                                            ),
                                          ),
                                          Positioned(
                                            top: 14,
                                            right: 14,
                                            child: Container(
                                              color: Colors.green,
                                              height: 20,
                                              width: 53,
                                              child: Text(
                                                exclusiveOffer[0] + " off",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                              bottom: 8,
                                              left: 8,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text("₹"),
                                                  Text(
                                                    exclusiveLabel[0] ??
                                                        "Item Name",
                                                  ),
                                                ],
                                              )),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: heightContainer,
                                            width: 200,
                                            color: Colors.white,
                                          ),
                                          Positioned(
                                            left: 75,
                                            top: heightContainer / 11,
                                            child: Container(
                                              child: Image.network(
                                                  exclusiveIcon[1]),
                                            ),
                                          ),
                                          Positioned(
                                            top: 14,
                                            right: 14,
                                            child: Container(
                                              color: Colors.green,
                                              height: 20,
                                              width: 53,
                                              child: Text(
                                                exclusiveOffer[1] + " off",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                              bottom: 8,
                                              left: 8,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text("₹"),
                                                  Text(exclusiveLabel[1] ??
                                                      "Item Name"),
                                                ],
                                              )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
      ),
    );
  }
}
