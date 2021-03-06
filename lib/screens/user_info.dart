import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';

import 'package:innovtion/data/constants.dart';
import 'package:innovtion/providers/auth.dart';
import 'package:innovtion/screens/page.dart';
import 'home.dart';

bool isupdate = false;
bool status = true;

class UserInfoScreen extends StatefulWidget {
  static const routeName = '/user-info';
  UserInfoScreen(bool value) {
    isupdate = value;
  }
  @override
  _UserInfoScreenState createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen>
    with SingleTickerProviderStateMixin {
  final databaseReference = Firestore.instance;
  final _auth = FirebaseAuth.instance;

  AnimationController _animationController;
  Animation<double> _animation;
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _phoneController = new TextEditingController();
  bool _init = true;
  var uid;
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  // PersistentBottomSheetController _controller;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool loading = false;

  callback(bool value) {
    setState(() {
      loading = value;
    });
  }

  @override
  void initState() {
    super.initState();
    checkInternet();
    fetchData2();
    _animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 600));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInCirc);
    _animation.addListener(() => this.setState(() {}));
    _animationController.forward();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_init) {
      setState(() {
        loading = true;
      });

      if (isupdate) {
        final result = await fetchData();
        if (result) {}
      }
      setState(() {
        loading = false;
      });
      _init = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  loading
                      ? CircularProgressIndicator()
                      : Form(
                          key: _formkey,
                          child: Container(
                            padding: EdgeInsets.all(25),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                userInfoText,
                                SizedBox(
                                  height: 25,
                                ),
                                LiteRollingSwitch(
                                  //initial value
                                  value: status,
                                  textOn: 'OPEN',
                                  textOff: 'CLOSED',
                                  colorOn: Colors.greenAccent[700],
                                  colorOff: Colors.redAccent[700],
                                  iconOn: Icons.done,
                                  iconOff: Icons.remove_circle_outline,
                                  textSize: 17.0,
                                  onChanged: (bool state) async {
                                    final uid = await _auth
                                        .currentUser()
                                        .then((value) => value.uid);
                                    final userinforesult =
                                        await Firestore.instance
                                            .collection("Outlet")
                                            .document(uid
//                                            "JTDWiaeze2QR2CLmt3a5qR1yief2"
                                                )
                                            .updateData({
                                      'status': state,
                                    }).then((value) {
                                      print("Success");
                                      return true;
                                    });
                                  },
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey[300],
                                      borderRadius: BorderRadius.circular(20)),
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    autocorrect: false,
                                    controller: _nameController,
                                    maxLines: 1,
                                    validator: (value) {
                                      if (value.isEmpty || value.length < 1) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        icon: Icon(
                                          Icons.person,
                                          size: 40,
                                          color: Colors.black,
                                        ),
                                        enabledBorder: InputBorder.none,
                                        labelText: 'Name',
                                        hintText: "Enter your name",
                                        labelStyle: TextStyle(
                                            decorationStyle:
                                                TextDecorationStyle.solid)),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey[300],
                                      borderRadius: BorderRadius.circular(20)),
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    autocorrect: false,
                                    controller: _phoneController,
                                    maxLines: 1,
                                    validator: (value) {
                                      if (value.isEmpty ||
                                          value.length < 1 &&
                                              value.length > 10 ||
                                          int.parse(value) < 5555555555) {
                                        return 'Please enter a valid phone number';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        icon: Icon(
                                          Icons.phone,
                                          size: 40,
                                          color: Colors.black,
                                        ),
                                        enabledBorder: InputBorder.none,
                                        labelText: 'Phone',
                                        hintText: "Enter your phone number",
                                        labelStyle: TextStyle(
                                            decorationStyle:
                                                TextDecorationStyle.solid)),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                MaterialButton(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 38),
                                  color: Colors.teal,
                                  textColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  child: loading
                                      ? Center(
                                          child: CircularProgressIndicator(
                                            backgroundColor: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          "SUBMIT",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                  onPressed: () async {
                                    if ((_nameController == null ||
                                        _phoneController == null)) {
                                      showDialog(
                                          context: context,
                                          child: AlertDialog(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            title: Text(
                                              "TRY AGAIN",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            content: Text(
                                                "Name and Phone Number are mandatory"),
                                            actions: <Widget>[
                                              MaterialButton(
                                                child: Text(
                                                  "RETRY",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          ));
                                    } else if (!(_formkey.currentState
                                        .validate())) {
                                      showDialog(
                                          context: context,
                                          child: AlertDialog(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            title: Text(
                                              "TRY AGAIN",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            content: Text(
                                                "Please Check Your Detials"),
                                            actions: <Widget>[
                                              MaterialButton(
                                                child: Text(
                                                  "RETRY",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              )
                                            ],
                                          ));
                                    } else {
                                      setState(() {
                                        loading = true;
                                      });
                                      // responeTimer();
                                      bool result = await checkInternet();
                                      if (!result) {
                                        print('result checked $result');
                                        setState(() {
                                          loading = false;
                                        });

                                        showDialog(
                                            context: context,
                                            child: AlertDialog(
                                              backgroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              title: Text(
                                                "TRY AGAIN",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              content: Text(
                                                  "Please Check Your Internet Connection"),
                                              actions: <Widget>[
                                                MaterialButton(
                                                  child: Text(
                                                    "RETRY",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                )
                                              ],
                                            ));
                                      } else {
                                        final userinforesult =
                                            await sendData(isupdate);
                                        print(userinforesult);
                                        if (userinforesult) {
                                          setState(() {
                                            _nameController.clear();
                                            _phoneController.clear();
                                          });
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                                  Page1.routeName);
                                        } else {
                                          print('not done');
                                        }
                                      }
                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                isupdate == true
                                    ? RaisedButton(
                                        elevation: 4,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16, horizontal: 38),
                                        color: Colors.teal,
                                        textColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Text(
                                          "LOGOUT",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        onPressed: () async {
                                          final signoutResult =
                                              await Auth().signOut();
                                          if (signoutResult) {
                                            Navigator.of(context)
                                                .pushReplacementNamed(
                                                    HomeScreen.routeName);
                                          }
                                        })
                                    : Container()
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ));
  }

  void responeTimer() async {
    print('timer fired');
    await Future.delayed(Duration(seconds: 10))
        .then((value) => callback(false));
  }

  Future<bool> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      }
    } on SocketException catch (_) {
      print('not connected');
      return false;
    }
    return false;
  }

  Future<bool> fetchData() async {
    final uid = await _auth.currentUser().then((value) => value.uid);
    final data = Firestore.instance.collection('Outlet').document(uid);
    final result = await data.get();
    _nameController.text = result['name'];
    _phoneController.text = (result['phone']);

    return true;
  }

  Future<bool> fetchData2() async {
    final uid = await _auth.currentUser().then((value) => value.uid);
    final data = Firestore.instance.collection('Outlet').document(uid);
    final result = await data.get();
    setState(() {
      status = result["status"];
    });

    return true;
  }

  Future<bool> sendData(bool isupdate) async {
    try {
      final uid = await _auth.currentUser().then((value) => value.uid);

      if (isupdate) {
        await databaseReference.collection("Outlet").document(uid).updateData({
          'name': _nameController.text,
          'phone': _phoneController.text,
        }).then((value) {
          print("Success");
          return true;
        });
        return true;
      } else {
        await databaseReference.collection("Outlet").document(uid).setData({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'status': false,
          'image': null,
          'Paytm': true,
          'Discount': 0,
          'MinOrder': 0,
          'Discount': 0,
          'DeliveryCharge': 0,
          'Tax': 0,
        }).then((value) {
          print("Success");
          return true;
        });
        return true;
      }
    } catch (e) {
      print(e);
      print('please try again');
      return false;
    }
  }
}
