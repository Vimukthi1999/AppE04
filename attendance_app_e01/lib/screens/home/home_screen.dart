import 'dart:async';
import 'package:attendance_app_e01/screens/login/login_screen.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/sharedPref.dart';
import '../attendance/attendance_screen.dart';
import '../instruction/instruction_screen.dart';
import '../leave/leave_screen.dart';
import '../market execution/market_execution.dart';

class HomePage extends StatefulWidget {
  late String userName;
  HomePage({Key? key, required this.userName}) : super(key: key);

  //HomePage(this.userName);

  @override
  State<HomePage> createState() => _HomePageState(userName);
}

class _HomePageState extends State<HomePage> {
  String userName;

  bool activeInternet = true;
  // internet avative
  late StreamSubscription _streamSubscriptionInternetActiviteInHomeScreen;

  _HomePageState(this.userName);

  // methods
  @override
  void initState() {
    super.initState();

    //check user online
    // call ckeck internet active
    _streamSubscriptionInternetActiviteInHomeScreen =
        InternetConnectionChecker().onStatusChange.listen((event) {
      final activeInternet = event == InternetConnectionStatus.connected;

      setState(() {
        this.activeInternet = activeInternet;
        //text = activeInternet ? 'Online' : 'Offline';
      });
    });
  }

  @override
  void dispose() {
    _streamSubscriptionInternetActiviteInHomeScreen.cancel();
    super.dispose();
  }

  // logout
  void logout() {
    SharedPref sharedPref = SharedPref();
    sharedPref.removeToken();

    // show toast
    Fluttertoast.showToast(
      msg: 'You have logged out successfully',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );

    //navigate to home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text('Tap back again to leave'),
        ),
        child: Stack(
          //overflow: Overflow.visible,
          fit: StackFit.loose,
          children: <Widget>[
            ClipPath(
              //clipper: ClippingClass(),
              child: Container(
                width: double.infinity,
                //height: MediaQuery.of(context).size.height * 4 / 7,
                height: double.infinity,
                decoration: const BoxDecoration(
                  // borderRadius: BorderRadius.horizontal(
                  //   left: Radius.circular(30), right: Radius.circular(30)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xff043776), Color(0xff174378)],
                  ),
                ),
              ),
            ),

            // welcome part
            _buildwelcomeText(),

            // cards part
            Positioned(
              left: 20,
              top: 200,
              right: 20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // top
                  GestureDetector(
                    child: Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: _buildCustomCard(
                              imageUrl: "assets/image/fingerprint.png",
                              item: "Attendance",
                              nav: "attendance",
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: _buildCustomCard(
                              imageUrl: "assets/image/leave.png",
                              item: "Leave",
                              nav: "leave",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10.0),
                  // bottom
                  GestureDetector(
                    child: Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: _buildCustomCard(
                              imageUrl: "assets/image/manual.png",
                              item: "Instructions",
                              nav: "instructions",
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: _buildCustomCard(
                              imageUrl: "assets/image/market.png",
                              item: "Market Execution",
                              nav: "market",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),

            _buildLogoutBtn(),
          ],
        ),
      ),
    );
  }

  // Widgets

  // internet alert dialog
  Future buildCustomDialog() {
    return showDialog(
        context: context,
        builder: (newNotification) {
          return AlertDialog(
            title: const Text('Network Alert'),
            content: const Text(
                'Your are currently offline.\nPlease check your internet connection'),
            actions: [
              TextButton(
                  onPressed: () {
                    //
                    if (activeInternet) {
                      Navigator.of(newNotification).pop();
                    } else {
                      setState(() {});
                    }
                  },
                  child: const Text('Check Connection'))
            ],
          );
        });
  }

  // welcome Part
  Widget _buildwelcomeText() {
    return Positioned(
      left: 20,
      top: 100,
      child: FutureBuilder<String>(
        //future: userName, // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Hi,$userName',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                "Attendance & Leave Management App",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // custom card
  Widget _buildCustomCard({String? imageUrl, String? item, String? nav}) {
    return GestureDetector(
      onTap: () {
        if (nav == "leave") {
          if (activeInternet) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LeaveScreen()),
            );
          } else {
            print(activeInternet);
            buildCustomDialog();
          }
        } else if (nav == "attendance") {
          if (activeInternet) {
            print(activeInternet);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AttendanceScreen(),
              ),
            );
          } else {
            print(activeInternet);
            buildCustomDialog();
          }
        } else if (nav == "instructions") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InstructionScreen(),
            ),
          );
        } else if (nav == "market") {
          // if (activeInternet) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MarketExecution(),
              ),
            );
        }
      },
      child: Container(
        height: 200,
        width: 250, // 150
        child: Card(
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image.asset(imageUrl!),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {},
                        child: Text(
                          item!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // logout button
  Widget _buildLogoutBtn() {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: RaisedButton(
              padding: const EdgeInsets.all(5),
              //color: Color(0xff043776),
              // color: Colors.amberAccent,
              color: const Color(0xFFee3a43),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              onPressed: () {
                // logout
                logout();
              },
              child: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
