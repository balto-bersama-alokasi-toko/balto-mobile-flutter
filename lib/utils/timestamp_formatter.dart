import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

/// To change timestamp format from firestore that look like
/// this 2024-07-10 10:31:18.510 .
/// to become like this
/// 10 Jul 2024 10:31
///

class TimestampFormatter extends StatelessWidget {
  final Timestamp firestoreTimestamp;
  // final String firestoreTimestamp;

  const TimestampFormatter({
    super.key,
    required this.firestoreTimestamp
  });


  @override
  Widget build(BuildContext context) {

    // Firestore timestamp to Date Time Conversion
    DateTime dateTime = firestoreTimestamp.toDate();
    // DateTime dateTime = DateTime.parse(firestoreTimestamp);

    // Format datetime
    String formattedDate = DateFormat('dd MMM yyyy HH:mm').format(dateTime);

    return Text(
      formattedDate,
      style: const TextStyle(
            fontSize: 14,
            color: Color(0xff94a3b8)
        ),
    );

  }

}