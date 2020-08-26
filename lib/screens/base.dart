import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:innovtion/screens/page.dart';
import 'package:innovtion/screens/splash_screen.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;
String userId;
final _auth = FirebaseAuth.instance;
var reference;
TextEditingController _phoneController = new TextEditingController();
// GlobalKey<FormState> _formkey = GlobalKey<FormState>();
// final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

class Base extends StatefulWidget {
  static const routeName = '/base-screen';

  @override
  _BaseState createState() => _BaseState();
}

class _BaseState extends State<Base> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

//  @override
//  void dispose() {
//    _phoneController.dispose();
//    super.dispose();
//  }

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
            Text(
              "New Orders",
              style: TextStyle(
                  color: Colors.teal,
                  fontSize: 50,
                  fontWeight: FontWeight.bold),
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
          .orderBy('Order Time')
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
          if (message.data['New'] == true) {
            var order = message.data['order'];
            order = order.substring(0, order.length - 2);
            final price = message.data['Price'];
            final time = message.data['Order Time'];
            final reference = message.data['reference'];
            final user = message.data['user'];
            final document = message.documentID;
            print(" hi $order");
            final messageBubble = MessageBubble(
              price: price,
              order: order,
              time: time,
              user: user,
              reference: reference,
              document: document,
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
  MessageBubble(
      {this.order,
      this.price,
      this.time,
      this.reference,
      this.user,
      this.document});

  final price;
  final order;
  final time;
  final user;
  final reference;
  final document;
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
                            Container(
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
                                          ),
                                        ),
                                        Text(
                                          userDocument["Price"].toString(),
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8, left: 8, top: 8),
                                    child: userDocument["Place"] != null
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                "Location: ",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                              Text(
                                                userDocument["Place"],
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            "Order PickUp",
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () async {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Select the Time'),
                                  content: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      autocorrect: false,
                                      controller: _phoneController,
                                      maxLines: 1,
                                      decoration: InputDecoration(
                                          icon: Icon(
                                            Icons.access_time,
                                            size: 40,
                                            color: Colors.black,
                                          ),
                                          enabledBorder: InputBorder.none,
                                          labelText: 'Time',
                                          hintText: "Enter the time",
                                          labelStyle: TextStyle(
                                              decorationStyle:
                                                  TextDecorationStyle.solid)),
                                    ),
                                  ),
                                  actions: <Widget>[
                                    RaisedButton(
                                      color: Colors.teal,
                                      onPressed: () async {
                                        final userinforesult =
                                            await widget.reference.updateData({
                                          'Accepted': true,
                                          'deliveryTime': _phoneController.text,
                                        }).then((value) {
                                          print("Success");
                                          return true;
                                        });
                                        final userinforesult1 = await Firestore
                                            .instance
                                            .collection("Outlet/$userId/orders")
                                            .document(widget.document)
                                            .updateData({
                                          'New': false,
                                        }).then((value) {
                                          print("Success");
                                          return true;
                                        });
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SplashScreen()));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Done',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              });
                        },
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Accept Order',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        color: Colors.blue,
                      ),
                      RaisedButton(
                        onPressed: () async {
                          final userinforesult3 = await Firestore.instance
                              .collection("Outlet/$userId/orders")
                              .document(widget.document)
                              .updateData({
                            'New': false,
                          }).then((value) {
                            print("Success");
                            return true;
                          });
                          final userinforesult2 =
                              await widget.reference.updateData({
                            'Cancelled': true,
                          }).then((value) {
                            print("Success");
                            return true;
                          });
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SplashScreen()));
                        },
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Cancel Order',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        color: Colors.red,
                      ),
                    ],
                  ),
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

//
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
