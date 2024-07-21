import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_to_do_list/auth/main_page.dart';

Future<void> logout(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) => Main_Page()), // Navigate to Main_Page
      (Route<dynamic> route) => false,
    );
  } catch (e) {
    print('Error logging out: $e');
  }
}
