//import 'package:cdbs_admin/subpages/admission_overview_page.dart';
import 'package:cdbs_admin/bloc/admission_bloc/admission_bloc.dart';
import 'package:cdbs_admin/bloc/auth/auth_bloc.dart';
import 'package:cdbs_admin/subpages/landing_page.dart';
import 'package:cdbs_admin/subpages/login_page.dart';
/*import 'package:cdbs_admin/subpages/page1.dart';
import 'package:cdbs_admin/subpages/s1.dart';*/
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;
/*import 'subpages/home_page.dart';
import 'subpages/login_page.dart';
import 'subpages/forgot_password.dart';
import 'subpages/reset_password.dart';
import 'subpages/admission_applications_page2.dart';*/

// void main() => runApp(const MaterialApp(
//       debugShowCheckedModeBanner: false,
// //HomePage is the name of the class you're about to run
//       home: LoginPage(),
//     ));

void clearWebCache() {
  try {
    // Clear browser's localStorage
    html.window.localStorage.clear();
    print("Browser cache cleared successfully.");
  } catch (e) {
    print("Failed to clear browser cache: $e");
  }
}

void main() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    // Your app initialization logic
    runApp(const MyApp());
  } catch (e) {
    print("Error initializing preferences: $e");
    // Attempt to clear cache and reload the app
    clearWebCache(); // Call this if using Flutter Web
    await Future.delayed(const Duration(seconds: 1)); // Give some time to clear
    runApp(const MyApp());
  }
  
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()),
        BlocProvider(create: (context) => AdmissionBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Don Bosco Admin',
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: const Color.fromARGB(255, 249, 249, 252),
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 1), // Default border color
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0XFF012169), width: 2), // Focused (active) border color
              borderRadius: BorderRadius.circular(8),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black, width: 1), // Disabled border color (set to red)
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Color(0XFF012169), // Cursor color
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginPage(),
        },
      ),
    );
  }
}
