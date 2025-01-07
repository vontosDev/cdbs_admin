import 'package:flutter/material.dart';

// Name of your class is like a variable || to run in main file
class S1Page extends StatelessWidget {
  const S1Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'This page is currently under development. We appreciate your patience as we work to bring you this new feature. ',
          style: TextStyle(fontSize: 14, fontFamily: "Roboto-R", color: Color.fromARGB(255, 115, 123, 131)), // Optional: Adjust the font size
        ),
      ),
    );
  }
}
