import 'package:flutter/material.dart';

class S2Page extends StatelessWidget {
  const S2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Optional: Set background color
      child: const Center(
        child: Text(
          'This page is currently under development. We appreciate your patience as we work to bring you this new feature. ',
          style: TextStyle(fontSize: 14, fontFamily: "Roboto-R", color: Color.fromARGB(255, 115, 123, 131)), // Optional: Adjust the font size
        ),
      ),
    );
  }
}
