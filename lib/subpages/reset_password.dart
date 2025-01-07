import 'package:cdbs_admin/subpages/login_page.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;  // For Password visibility toggle
  bool _isConfirmPasswordVisible = false;  // For Confirm Password visibility toggle
  final bool _isPasswordIncorrect = false;
  bool toShowError=false;

  // Function to validate password match
  bool _isPasswordMatch() {
    
    
    return _passwordController.text == _confirmPasswordController.text;
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
              'assets/background.jpg',
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
                    'assets/logo.png',
                    width: 293 * scale,
                    height: 293 * scale,
                  ),
                  SizedBox(height: 70 * scale),
                  SizedBox(
                    width: 388 * scale,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reset Password',
                          style: TextStyle(
                            fontFamily: 'Roboto-R',
                            fontSize: 20 * scale,
                            color: const Color(0XFF222222),
                          ),
                        ),
                        Text(
                          'Enter a new password for parentapp@cdbs.com',
                          style: TextStyle(
                            fontFamily: 'Roboto-R',
                            fontSize: 13 * scale,
                            color: const Color(0XFF909590),
                          ),
                        ),
                        SizedBox(height: 20 * scale),
                      ],
                    ),
                  ),
                  
                  // Password Field
                  SizedBox(
                    width: 388 * scale,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password',
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
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(
                                fontFamily: 'Roboto-R',
                                fontSize: 11 * scale,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6 * scale),
                              ),
                              contentPadding: EdgeInsets.only(left: 10 * scale),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  size: 20 * scale,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10 * scale),

                  // Confirm Password Field
                  SizedBox(
                    width: 388 * scale,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confirm Password',
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
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              hintStyle: TextStyle(
                                fontFamily: 'Roboto-R',
                                fontSize: 11 * scale,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6 * scale),
                              ),
                              contentPadding: EdgeInsets.only(left: 10 * scale),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  size: 20 * scale,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5 * scale),
                        SizedBox(
                          height: 15 * scale,
                          child: toShowError
                              ? Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: const Color(0XFFC8102E),
                                      size: 16 * scale,
                                    ),
                                    SizedBox(width: 4 * scale),
                                    Text(
                                      'Password did not match',
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

                  // Reset Password Button
                  SizedBox(
                    width: 388 * scale,
                    height: 35 * scale,
                    child: ElevatedButton(
                      onPressed:  () {
                              // Only navigate to next page if passwords match
                              if(_isPasswordMatch()){
                                 setState(() {
                                  toShowError=false;
                                });
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
                                  transitionDuration: Duration.zero, // No animation
                                  reverseTransitionDuration: Duration.zero, // No animation on back
                                ),
                              );
                              }else{
                                setState(() {
                                  toShowError=true;
                                });
                              }
                            }, // Button will be functional only if passwords match
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFF012169),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6 * scale),
                        ),
                      ),
                      child: Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontFamily: 'Roboto-R',
                          color: Colors.white,
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
