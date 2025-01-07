import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Don't forget to add the spin kit dependency in your pubspec.yaml

class CustomSpinner extends StatelessWidget {
  const CustomSpinner({
    super.key,
    this.color = const Color(0xff012169), // Default color for the spinner
    this.size = 50.0, // Default size for the spinner
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitCircle(
        color: color, // Spinner color
        size: size, // Spinner size
      ),
    );
  }
}
