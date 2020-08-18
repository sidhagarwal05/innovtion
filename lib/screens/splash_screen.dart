import 'dart:async';
import 'package:flutter/material.dart';
import 'package:innovtion/providers/auth.dart';
import 'package:innovtion/screens/page.dart';
import 'package:innovtion/screens/user_info.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'base.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void movetoHome() async {
    await Future.delayed(Duration(milliseconds: 2000));
    final result = await Auth().autoLogin();
    print('result $result');
    if (result) {
      final check = await Auth().checkuserInfo();
      print('check $check');
      if (check) {
        Navigator.of(context).pushReplacementNamed(Page1.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(UserInfoScreen.routeName);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    }
  }

  @override
  void initState() {
    movetoHome();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Image(
              image: AssetImage('images/newlogo.png'),
            ),
          ),
          SpinKitWave(
            color: Colors.white,
            size: 50.0,
          ),
        ],
      ),
    );
  }
}
