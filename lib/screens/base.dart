import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:innovtion/data/constants.dart';
import 'package:innovtion/providers/auth.dart';
import 'package:innovtion/screens/inventory.dart';
import 'package:innovtion/screens/user_info.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class Base extends StatefulWidget {
  static const routeName = '/base-screen';

  @override
  _BaseState createState() => _BaseState();
}

class _BaseState extends State<Base> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;
  var username;
  var city;
  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInCirc);
    _animation.addListener(() => this.setState(() {}));
    _animationController.forward();
    fetchNameAndCity();
  }

  String dropdownValue = '';
  var _items = ['userprofile', 'logout', 'Inventory'];

  void fetchNameAndCity() async {
    final pref = await SharedPreferences.getInstance();
    final dname = await FirebaseAuth.instance
        .currentUser()
        .then((value) => value.displayName);
    print('name $dname');
    city = pref.getString('city');
    username = dname;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  DropdownButton(
                    underline: Container(),
                    onChanged: (value) async {
                      setState(() {
                        dropdownValue = value;
                      });
                      if (dropdownValue == 'logout') {
                        final signoutResult = await Auth().signOut();
                        if (signoutResult) {
                          Navigator.of(context)
                              .pushReplacementNamed(HomeScreen.routeName);
                        }
                      }
                      if (dropdownValue == 'userprofile') {
                        Navigator.of(context).pushNamed(
                            UserInfoScreen.routeName,
                            arguments: true);
                      }
                      if (dropdownValue == 'Inventory') {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Inventory()));
                      }
                    },
                    icon: Icon(
                      Icons.access_alarm,
                    ),
                    items: _items.map((e) {
                      return DropdownMenuItem(
                        child: Text(e),
                        value: e,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
