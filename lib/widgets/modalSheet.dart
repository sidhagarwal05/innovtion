import 'package:flutter/material.dart';

class ModalSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
      //   decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //     colors: [
      //       Color(0xFF10EEEE),
      //       Color(0xFF02EE97),
      //     ],
      //   ),
      // ),
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
              Navigator.of(context).pop();
              },
              padding: EdgeInsets.all(5),
              alignment: Alignment.topRight,
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                'Complaint Filed Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.check_circle,
                size: 80,
              ),
            ),
          ],
          // TO BE DONE: Render custom designed Ad
        ),
      ),
    );
  }
}
