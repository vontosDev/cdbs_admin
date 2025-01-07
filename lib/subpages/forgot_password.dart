import 'package:cdbs_admin/subpages/login_page.dart';
import 'package:cdbs_admin/subpages/reset_password.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailIncorrect = false;
  bool _isPasswordIncorrect = false;


  void _validateCredentials() {
    setState(() {
      // Replace with actual credential validation logic
      _isEmailIncorrect = _emailController.text != 'correct@example.com';
      _isPasswordIncorrect = _passwordController.text != 'correctpassword';
    });

    if (!_isEmailIncorrect && !_isPasswordIncorrect) {
      // Proceed with login logic
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double baseWidth = 400;
    double baseHeight = 800;
    double widthScale = screenWidth / baseWidth;
    double heightScale = screenHeight / baseHeight;
    double scale = widthScale < heightScale ? widthScale : heightScale;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with 80% opacity
          Opacity(
            opacity: 0.2,
            child: Image.asset(
              'assets/background.jpg', // Replace with your image asset path
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Image
                  Image.asset(
                    'assets/logo.png', // Replace with your logo asset path
                    width: 293 * scale,
                    height: 293 * scale,
                  ),
                  SizedBox(height: 70 * scale),











//EMAIL
                  SizedBox(
  width: 388 * scale,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Forgot Password',
        style: TextStyle(
          fontFamily: 'Roboto-R',
          fontSize: 20 * scale,
          color: const Color(0XFF222222),
        ),
      ),
      Text(
        'Please enter the email address linked to your account.',
        style: TextStyle(
          fontFamily: 'Roboto-R',
          fontSize: 13 * scale,
          color: const Color(0XFF909590),
        ),
      ),
      SizedBox(height: 20 * scale),
      Text(
        'Email Address',
        style: TextStyle(
          fontFamily: 'Roboto-R',
          fontSize: 11 * scale,
          color: const Color(0XFF909590),
        ),
      ),
      SizedBox(height: 5 * scale),
      SizedBox(
        height: 35 * scale,
        child: TextFormField(
          controller: _emailController,
          style: TextStyle(
            fontFamily: 'Roboto-R',
            fontSize: 11 * scale,
            color: Colors.black, // Set the input text color to black
          ),
          decoration: InputDecoration(
            hintText: 'Email address',
            hintStyle: TextStyle(
              fontFamily: 'Roboto-R',
              fontSize: 11 * scale,
              color: const Color(0XFF909590), // Hint text color
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6 * scale),
            ),
            contentPadding: EdgeInsets.only(left: 10 * scale),
          ),
        ),
      ),
      SizedBox(height: 5 * scale),
      SizedBox(
        height: 15 * scale,
        child: _isEmailIncorrect
            ? Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: const Color(0XFFC8102E),
                    size: 16 * scale,
                  ),
                  SizedBox(width: 4 * scale),
                  Text(
                    'Incorrect Email',
                    style: TextStyle(
                      color: const Color(0XFFC8102E),
                      fontFamily: 'Roboto-R',
                      fontSize: 11 * scale,
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    ],
  ),
),

                  SizedBox(height: 10 * scale),





















                  // Login Button
                  SizedBox(
                    width: 388 * scale,
                    height: 35 * scale,
                    child: ElevatedButton(
                      onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation,
                                      secondaryAnimation) =>
                                  const ResetPasswordPage(),
                              transitionDuration:
                                  Duration.zero, // No animation
                              reverseTransitionDuration: Duration
                                  .zero, // No animation on back
                            ),
                          );
                        },


                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff012169),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6 * scale),
                        ),
                      ),
                      child: Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontFamily: 'Roboto-R',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10 * scale),

                  // Sign Up Button
                  SizedBox(
                    width: 388 * scale,
                    height: 35 * scale,
                    child: ElevatedButton(
                      onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation,
                                      secondaryAnimation) =>
                                  const LoginPage(),
                              transitionDuration:
                                  Duration.zero, // No animation
                              reverseTransitionDuration: Duration
                                  .zero, // No animation on back
                            ),
                          );
                        },


                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFFD3D3D3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6 * scale),
                        ),
                      ),
                      child: Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontFamily: 'Roboto-R',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
