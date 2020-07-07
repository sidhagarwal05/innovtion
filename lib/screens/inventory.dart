import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lite_rolling_switch/lite_rolling_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;
String email;
int sort = 0;
String uid;
bool loading = false;

class Inventory extends StatefulWidget {
  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  final _auth = FirebaseAuth.instance;
  TextEditingController _dishController = new TextEditingController();
  TextEditingController _priceController = new TextEditingController();
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  String messageText;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  void dispose() {
    _dishController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        email = loggedInUser.email;
        setState(() {
          uid = loggedInUser.uid;
        });

        print(loggedInUser.uid);
        print("Outlet/$uid/Menu");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 4,
        title: FittedBox(
          fit: BoxFit.contain,
          child: RichText(
            text: TextSpan(
                text: "Inven",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    letterSpacing: 1,
                    color: Colors.black),
                children: <TextSpan>[
                  TextSpan(
                      text: "tory",
                      style: TextStyle(
                          letterSpacing: 1,
                          fontSize: 35,
                          color: Colors.grey[500],
                          fontFamily: "Sans Serif"))
                ]),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessagesStream(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Column(
                  children: <Widget>[
                    Form(
                      key: _formkey,
                      child: Container(
                        padding: EdgeInsets.all(25),
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20)),
                              child: TextFormField(
                                keyboardType: TextInputType.text,
                                autocorrect: false,
                                controller: _dishController,
                                maxLines: 1,
                                validator: (value) {
                                  if (value.isEmpty || value.length < 1) {
                                    return 'Please enter the dish name';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    icon: Icon(
                                      Icons.fastfood,
                                      size: 40,
                                      color: Colors.black,
                                    ),
                                    enabledBorder: InputBorder.none,
                                    labelText: 'Dish',
                                    hintText: "Enter the dish name",
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
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20)),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                autocorrect: false,
                                controller: _priceController,
                                maxLines: 1,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter a price';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    icon: Icon(
                                      Icons.local_convenience_store,
                                      size: 40,
                                      color: Colors.black,
                                    ),
                                    enabledBorder: InputBorder.none,
                                    labelText: 'Price',
                                    hintText: "Enter the price",
                                    labelStyle: TextStyle(
                                        decorationStyle:
                                            TextDecorationStyle.solid)),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RaisedButton(
                              child: loading == false
                                  ? Text('Submit')
                                  : CircularProgressIndicator(
                                      backgroundColor: Colors.yellow,
                                    ),
                              color: Colors.blue,
                              // ignore: missing_return
                              onPressed: () async {
                                if (!_formkey.currentState.validate()) {
                                  print('tap');
                                } else {
                                  print('tap');
                                  setState(() {
                                    loading = true;
                                  });
                                  final userinforesult = await Firestore
                                      .instance
                                      .collection("Outlet/$uid/Menu")
                                      .document()
                                      .setData({
                                    'Available': true,
                                    'Name': _dishController.text,
                                    'imageurl': null,
                                    'Price': int.parse(_priceController.text),
                                  }).then((value) {
                                    print("Success");
                                    return true;
                                  });
                                  setState(() {
                                    loading = false;
                                  });
                                  Navigator.of(context).pop();
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection("Outlet/$uid/Menu").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        print("snapshot $snapshot");
        final messages = snapshot.data.documents;
        print('messages $messages');
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final available = message.data['Available'];
          final name = message.data['Name'];
          final price = message.data['Price'];
          final imageurl = message.data['imageurl'];
          final documentId = message.documentID;

          print('status $available');
          // print(imageUrl);
          final currentUser = loggedInUser.email;
          print('user = $currentUser');
          print('uid==' + loggedInUser.uid);
          final messageBubble = MessageBubble(
            imageurl: imageurl,
            name: name,
            price: price,
            available: available,
            documentid: documentId,
          );
          messageBubbles.add(messageBubble);
        }

        return Expanded(
          flex: 1,
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
  MessageBubble({
    this.available,
    this.price,
    this.imageurl,
    this.name,
    this.documentid,
  });

  final bool available;
  final int price;
  final String imageurl;
  final String name;
  final String documentid;

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(widget.name),
                  Text('₹ ' + widget.price.toString()),
                ],
              ),
              Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () async {
                      final userinforesult = await Firestore.instance
                          .collection("Outlet/$uid/Menu")
                          .document(widget.documentid)
                          .delete();
                    },
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                  LiteRollingSwitch(
                    //initial value
                    value: widget.available,
                    textOn: 'Available',
                    textOff: 'Finished',
                    colorOn: Colors.greenAccent[700],
                    colorOff: Colors.redAccent[700],
                    iconOn: Icons.done,
                    iconOff: Icons.remove_circle_outline,
                    textSize: 12.0,
                    onChanged: (bool state) async {
                      //Use it to manage the different states
                      final userinforesult = await Firestore.instance
                          .collection("Outlet/$uid/Menu")
                          .document(widget.documentid)
                          .updateData({
                        'Available': state,
                      }).then((value) {
                        print("Success");
                        return true;
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }
}
