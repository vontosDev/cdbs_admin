import 'package:cdbs_admin/subpages/forgot_password.dart';
import 'package:cdbs_admin/subpages/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../bloc/auth/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailIncorrect = false;
  bool _isPasswordIncorrect = false;
  bool _isPasswordVisible = false; // Add this at the beginning of your stateful widget


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
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // TODO: implement listener
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
              ),
            );
          }

          if (state is AuthSuccess) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>  const LandingPage(),
                ),
                (route) => false);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return  const Center(
              // Center the spinner when loading
                    child: SpinKitCircle(
                      color: Color(0xff012169), // Change the color as needed
                      size: 50.0, // Adjust size as needed
                    ),
                  );
          }
          return Stack(
        fit: StackFit.expand,
        children: [
          // Background image with 80% opacity
          Opacity(
            opacity: 0.2,
            child: Image.asset(
              'assets/Background.jpg', // Replace with your image asset path
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
                    'assets/Logo.png', // Replace with your logo asset path
                    width: 293 * scale,
                    height: 293 * scale,
                  ),
                  SizedBox(height: 30 * scale),











//EMAIL
                  SizedBox(
                    width: 388 * scale,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
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
                            decoration: InputDecoration(
                              hintText: 'Email address',
                              hintStyle: TextStyle(
                                fontFamily: 'Roboto-R',
                                fontSize: 11 * scale,
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








//PASSWORD
                  SizedBox(
                    width: 388 * scale,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(
                                fontFamily: 'Roboto-R',
                                fontSize: 11 * scale, // Scaled font size
                                color: const Color(0XFF909590),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation,
                                      secondaryAnimation) =>
                                  const ForgotPasswordPage(),
                              transitionDuration:
                                  Duration.zero, // No animation
                              reverseTransitionDuration: Duration
                                  .zero, // No animation on back
                            ),
                          );
                        },

                              child: Text(
                                'Forgot Password',
                                style: TextStyle(
                                  fontFamily: 'Roboto-R',
                                  fontSize: 11 * scale, // Scaled font size
                                  color: const Color(0XFF909590),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 5 * scale),
// Inside your widget build method:
SizedBox(
  height: 35 * scale,
  child: TextFormField(
    controller: _passwordController,
    obscureText: !_isPasswordVisible, // Control visibility with this variable
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
            _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility
          });
        },
      ),
    ),
  ),
),
                        SizedBox(height: 5 * scale),
                        SizedBox(
                          height: 15 * scale,
                          child: _isPasswordIncorrect
                              ? Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: const Color(0XFFC8102E),
                                      size: 16 * scale,
                                    ),
                                    SizedBox(width: 4 * scale),
                                    Text(
                                      'Incorrect Password',
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
                  SizedBox(height: 20 * scale),












                  // Login Button
                  SizedBox(
                    width: 388 * scale,
                    height: 35 * scale,
                    child: ElevatedButton(
                      onPressed: (){
                        //_validateCredentials();
                        context.read<AuthBloc>().add(
                              AuthLoginRequested(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              ),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFF012169),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6 * scale),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontFamily: 'Roboto-R',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  /*SizedBox(
                    width: 388 * scale,
                    height: 35 * scale,
                    child: ElevatedButton(
                      onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation,
                                      secondaryAnimation) =>
                                  const LandingPage(),
                              transitionDuration:
                                  Duration.zero, // No animation
                              reverseTransitionDuration: Duration
                                  .zero, // No animation on back
                            ),
                          );
                        },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFF012169),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6 * scale),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontFamily: 'Roboto-R',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),*/
                  SizedBox(height: 10 * scale),

                  // Sign Up Button
                 /* SizedBox(
                    width: 388 * scale,
                    height: 35 * scale,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFFD3D3D3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6 * scale),
                        ),
                      ),
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontFamily: 'Roboto-R',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),*/
                ],
              ),
            ),
          ),
        ],
      );
        }
      )
        
      
    );
  }
}
