// return a formatted data as a string

import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(Timestamp timestamp) {
  // Timestamp is the object from firebase
  // let convert to string
  DateTime dateTime = timestamp.toDate();

  // get year
  String year = dateTime.year.toString().padLeft(2, '0');

  // get month
  String month = dateTime.month.toString().padLeft(2, '0');

  // get day
  String day = dateTime.day.toString().padLeft(2, '0');

  // get hour
  String hour = dateTime.hour.toString().padLeft(2, '0');

  // get mintues
  String minute = dateTime.minute.toString().padLeft(2, '0');

  // final formatted date
  String formattedDate = '$day/$month/$year $hour:$minute';

  return formattedDate;
}
