import 'package:flutter/material.dart';
import 'package:innovtion/providers/auth.dart';
import 'package:innovtion/screens/inventory.dart';
import 'package:innovtion/screens/user_info.dart';
import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;
String userId;
final _auth = FirebaseAuth.instance;
var reference;

class PreviousOrder extends StatefulWidget {
  static const routeName = '/previousOrders';

  @override
  _PreviousOrderState createState() => _PreviousOrderState();
}

class _PreviousOrderState extends State<PreviousOrder>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        setState(() {
          userId = user.uid;
        });
        print('user:' + userId);
      }
    } catch (e) {
      print(e);
    }
  }

  String dropdownValue = '';
  var _items = ['userprofile', 'logout', 'Inventory'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    "Previous Orders",
                    style: TextStyle(
                        color: Colors.teal,
                        fontSize: 45,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            MessagesStream(),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Outlet/$userId/orders')
          .orderBy('Order Time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          if (message.data['New'] == false) {
            var order = message.data['order'];
            order = order.substring(0, order.length - 2);
            final price = message.data['Price'];
            final time = message.data['Order Time'];
            final reference = message.data['reference'];
            final user = message.data['user'];
            print(" hi $order");
            final messageBubble = MessageBubble(
              price: price,
              order: order,
              time: time,
              user: user,
              reference: reference,
            );
            messageBubbles.add(messageBubble);
          }
        }
        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatefulWidget {
  MessageBubble({this.order, this.price, this.time, this.reference, this.user});

  final price;
  final order;
  final time;
  final user;
  final reference;
  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          reference = widget.reference;
        });
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return Column(
                children: <Widget>[
                  widget.user != null
                      ? StreamBuilder(
                          stream: widget.user.snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return new Text("Loading");
                            }
                            var userDocument = snapshot.data;

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    userDocument["name"],
                                    style: TextStyle(
                                        fontSize: 40,
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    userDocument["phone"],
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.teal,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          })
                      : Container(),
                  MessagesStream1(),
                  StreamBuilder(
                      stream: widget.reference.snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return new Text("Loading");
                        }
                        var userDocument = snapshot.data;

                        return Column(
                          children: <Widget>[
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              userDocument["Accepted"] == false ||
                                      userDocument["Accepted"] == null
                                  ? userDocument["Cancelled"] == false ||
                                          userDocument["Cancelled"] == null
                                      ? 'Waiting for the Restaurant to Accept the Order'
                                      : "Order has been cancelled due to unavailability of item/ Restaurant has been closed"
                                  : 'Order Accepted',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue[700],
                                  backgroundColor: Colors.grey[200]),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              height: 10,
                            ),
//                            userDocument['deliveryTime'] == null ||
//                                    userDocument['deliveryTime'] == ""
//                                ? Container()
//                                : Text(
//                                    'Order will reach you in ${userDocument['deliveryTime']} minutes',
//                                    style: TextStyle(
//                                        fontSize: 18,
//                                        backgroundColor: Colors.grey[200]),
//                                  ),
                            Card(
                              elevation: 3,
                              child: Container(
                                color: Colors.teal,
                                child: Column(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "Total Price:  ₹",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                          Text(
                                            userDocument["Price"].toString(),
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 8, left: 8, top: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "Location: ",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                          Text(
                                            userDocument["Place"],
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                ],
              );
            });
      },
      child: Card(
          color: Colors.white,
          child: Padding(
            padding:
                const EdgeInsets.only(top: 8, left: 8, bottom: 15, right: 8),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      child: Text(
                        widget.order,
                        style: TextStyle(fontSize: 20),
                      ),
                      width: MediaQuery.of(context).size.width * 0.5,
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    child: Text(
                      'Price ₹' + widget.price.toString(),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class MessagesStream1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: reference.collection("Item").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data.documents;
        List<MessageBubble1> messageBubbles1 = [];
        for (var message in messages) {
          final name = message.data['Name'];
          final price = message.data['Price'];
          final imageurl = message.data['image'];
          final quantity = message.data['Quantity'];
          final messageBubble1 = MessageBubble1(
            name: name,
            price: price,
            image: imageurl,
            quantity: quantity,
          );
          messageBubbles1.add(messageBubble1);
        }
        return Expanded(
          child: ListView(
            padding: EdgeInsets.only(top: 20, bottom: 10, left: 10, right: 10),
            children: messageBubbles1,
          ),
        );
      },
    );
  }
}

class MessageBubble1 extends StatefulWidget {
  MessageBubble1({this.name, this.image, this.price, this.quantity});

  final String name;
  final price;
  final String image;
  final quantity;
  @override
  _MessageBubbleState1 createState() => _MessageBubbleState1();
}

class _MessageBubbleState1 extends State<MessageBubble1> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: widget.image == null
                        ? Padding(
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.005),
                            child: Container(
                              color: Colors.teal,
                              child: Image(
                                image: AssetImage('images/newlogo.png'),
                              ),
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.width * 0.005),
                            child: Image(
                              image: NetworkImage(widget.image),
                            ),
                          ),
                    color: Color.fromRGBO(255, 255, 255, 0.1),
                    width: MediaQuery.of(context).size.width * 0.15,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.03),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          child: Text(widget.name),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.01,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Text(
                  'x' + widget.quantity.toString(),
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                ),
                Text(
                  '₹ ' + (widget.price * widget.quantity).toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
