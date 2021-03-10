const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.myFunction = functions.firestore
  .document('Order/{Message}')
  .onCreate((snapshot, context) => {
  return admin.messaging().sendAll({notification : {title: "New Order", body: "Open the link for the order details"}});

  });