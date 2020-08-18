import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:innovtion/screens/base.dart';
import 'package:innovtion/screens/inventory.dart';
import 'package:innovtion/screens/previousOrders.dart';
import 'package:innovtion/screens/user_info.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

PageController pageController;
int page = 0;

class Page1 extends StatefulWidget {
  static const routeName = '/page1';
  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page1> {
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit the App'),
            actions: <Widget>[
              new FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new FlatButton(
                onPressed: () => SystemNavigator.pop(),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          color: Colors.teal,
          backgroundColor: Colors.white,
          buttonBackgroundColor: Colors.teal,
          height: 60,
          items: <Widget>[
            Icon(
              Icons.new_releases,
              color: Colors.white,
              size: 30,
            ),
            Icon(
              Icons.access_time,
              color: Colors.white,
              size: 30,
            ),
            Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 30,
            ),
            Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ],
          onTap: (index) {
            page = index;
            pageController.jumpToPage(
              page,
            );
          },
        ),
        body: PageView(
          children: <Widget>[
            Base(),
            PreviousOrder(),
            Inventory(),
            UserInfoScreen(true),
          ],
          controller: pageController,
          physics: NeverScrollableScrollPhysics(),
        ),
      ),
    );
  }
}
