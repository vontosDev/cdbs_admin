import 'dart:async';

import 'package:cdbs_admin/bloc/auth/auth_bloc.dart';
import 'package:cdbs_admin/subpages/page1.dart';
import 'package:cdbs_admin/subpages/page2.dart';
import 'package:cdbs_admin/subpages/page3.dart';
import 'package:cdbs_admin/subpages/page4.dart';
import 'package:cdbs_admin/subpages/page5.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget currentPage = const Page1(); // Default page
  int selectedCardIndex = -1; // Track selected card index
  List<bool> isHovered = List.generate(7, (_) => false);
  int pendingCount = 0; // To hold the pending count
  bool isLoading = true; // To manage loading state
  Timer? _timer;

  void changePage(int pageIndex) {
    setState(() {
      selectedCardIndex = pageIndex; // Update selected index
      switch (pageIndex) {
        case 0:
          currentPage = const Page1();
          break;
        case 1:
          currentPage = const Page2();
          break;
        case 2:
          currentPage = const Page3();
          break;
        case 3:
          currentPage = const Page4();
          break;
        case 4:
          currentPage = const Page5();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Define scale factors based on the screen size
    double baseWidth = 400; // Change based on your design
    double baseHeight = 800; // Change based on your design
    double widthScale = screenWidth / baseWidth;
    double heightScale = screenHeight / baseHeight;

    double scale = widthScale < heightScale ? widthScale : heightScale;

    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 243, 0, 0),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(
                'assets/BG5.png'), // Replace with your image path
            fit: BoxFit.cover, // Ensures the image covers the screen
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5), // Adjust opacity to 20% (1 - 0.2)
              BlendMode.dstATop, // Applying opacity filter over the image
            ),
          ),
        ),
        height: MediaQuery.of(context).size.height *
            10, // Adjust height to 80% of screen height
        width: MediaQuery.of(context).size.width *
            10, // Adjust width to 80% of screen width

        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10 * scale),
              child: SizedBox(
                width: screenWidth * .18,
                child: Column(
                  children: [
                    // Image and dashboard title
                    Expanded(
                      flex: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/Logo.png',
                            height: 70 * scale,
                          ),
                          SizedBox(width: 10 * scale),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Welcome back!',
                                style: TextStyle(
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Roboto-L",
                                  color: const Color(0XFF13322B),
                                ),
                              ),
                              Text(
                                'Good morning wonderful person!',
                                style: TextStyle(
                                  fontSize: 12 * scale,
                                  fontFamily: "Roboto-L",
                                  color: const Color(0XFF13322B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 16.0 * scale),
                          child: Text(
                            'ADMIN MANAGEMENT',
                            style: TextStyle(
                              fontSize: 14 * scale,
                              fontFamily: "Roboto-L",
                              color: const Color(0XFF13322B),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Cards with icons
                    Expanded(
                      flex: 80,
                      child: Column(
                        children: List.generate(4, (index) {
                          final cardTitles = [
                            'Dashboard',
                            'Inquiry Forms',
                            'User Overview',
                            'Admissions',
                          ];

                          // Track if the panel is expanded (move this outside of List.generate)
                          List<bool> isExpanded = [false, false, false, false];

                          // Check if the card is "Admissions" and turn it into an ExpansionPanelList
                          if (cardTitles[index] == 'Admissions') {
                            return Padding(
                              padding: EdgeInsets.all(2.0 * scale),
                              child: ExpansionPanelList(
                                elevation: 1,
                                expandedHeaderPadding: const EdgeInsets.all(0),
                                children: [
                                  ExpansionPanel(
                                    headerBuilder: (context, isExpanded) {
                                      return ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 20 * scale),
                                        leading: Icon(
                                          Icons.dashboard,
                                          color: const Color(0XFF13322B),
                                          size: 24 * scale,
                                        ),
                                        title: Text(
                                          cardTitles[index],
                                          style: TextStyle(
                                            color: const Color(0XFF13322B),
                                            fontSize: 20 * scale,
                                            fontFamily: "Roboto-M",
                                          ),
                                        ),
                                      );
                                    },
                                    body: Padding(
                                      padding: EdgeInsets.all(16.0 * scale),
                                      child: const Column(
                                        children: [
                                          Text(
                                              "Your expanded content goes here."),
                                          // Add additional widgets or content here that should appear when expanded
                                        ],
                                      ),
                                    ),
                                    isExpanded: isExpanded[index], // Use this for expansion state
                                  ),
                                ],
                                // Remove the onExpansionChanged callback
                              ),
                            );
                          } else {
                            // Keep the rest of the items as normal cards
                            return MouseRegion(
                              onEnter: (_) {
                                setState(() {
                                  isHovered[index] = false; // Disable hover effect
                                });
                              },
                              onExit: (_) {
                                setState(() {
                                  isHovered[index] = false; // Disable hover effect
                                });
                              },
                              child: GestureDetector(
                                onTap: () => changePage(index),
                                child: Padding(
                                  padding: EdgeInsets.all(2.0 * scale),
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 40 * scale,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20 * scale),
                                        decoration: BoxDecoration(
                                          color: Colors
                                              .white, // Keep background white
                                          borderRadius:
                                              BorderRadius.circular(10 * scale),
                                          border: Border.all(
                                            color: selectedCardIndex == index
                                                ? const Color(0xFF13322B)
                                                : Colors
                                                    .transparent, // No border for hover effect
                                            width: 1.0 * scale,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.dashboard,
                                              color: const Color(0XFF13322B),
                                              size: 24 * scale,
                                            ),
                                            SizedBox(width: 10 * scale),
                                            Text(
                                              cardTitles[index],
                                              style: TextStyle(
                                                color: const Color(0XFF13322B),
                                                fontSize: 20 * scale,
                                                fontFamily: "Roboto-M",
                                                backgroundColor: Colors
                                                    .transparent, // Remove background color
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 40 * scale,
                                          decoration: BoxDecoration(
                                            color: Colors
                                                .transparent, // Remove hover background color
                                            borderRadius: BorderRadius.only(
                                              topRight:
                                                  Radius.circular(10 * scale),
                                              bottomRight:
                                                  Radius.circular(10 * scale),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                      ),
                    ),

                    // Logout button
                    SizedBox(
                      height: screenHeight * .05,
                      child: Center(
                        child: SizedBox(
                          height: 40 * scale,
                          width: 300 * scale,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff13322B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10 * scale),
                              ),
                            ),
                            onPressed: () async {
                              bool? confirmLogout = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: const Color(0xFFFFFFFF),
                                    title: Text('Confirm Logout',
                                        style: TextStyle(
                                            color: const Color(0xFF13322B),
                                            fontSize: 16 * scale)),
                                    content: Text(
                                        'Are you sure you want to logout?',
                                        style: TextStyle(
                                            color: const Color(0xFF13322B),
                                            fontSize: 14 * scale)),
                                    actions: <Widget>[
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              const Color(0xFF990000),
                                          backgroundColor: Colors.white,
                                        ),
                                        onPressed: (){
                                          Navigator.of(context).pop(false);
                                        },
                                        child: Text('Cancel',
                                            style: TextStyle(
                                                fontSize: 14 * scale)),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor:
                                              const Color(0xFF990000),
                                          backgroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          context.read<AuthBloc>().add(AuthLogoutRequested());
                                          Navigator.of(context).pop(true);
                                        },
                                        child: Text('Logout',
                                            style: TextStyle(
                                                fontSize: 14 * scale)),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text('Logout',
                                style: TextStyle(
                                    fontSize: 14 * scale,
                                    color: const Color(0xFFFFFFFF))),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: currentPage,
            ),
          ],
        ),
      ),
    );
  }
}
