//LANDING PAGE

import 'package:cdbs_admin/bloc/auth/auth_bloc.dart';
import 'package:cdbs_admin/subpages/admissions/admission_applications_page.dart';
import 'package:cdbs_admin/subpages/admissions/admission_overview_page.dart';
import 'package:cdbs_admin/subpages/admissions/admission_payments_page.dart';
import 'package:cdbs_admin/subpages/admissions/admission_requirements_page.dart';
import 'package:cdbs_admin/subpages/admissions/admission_results_page.dart';
import 'package:cdbs_admin/subpages/admissions/admission_schedules_page.dart';
import 'package:cdbs_admin/subpages/admissions/admission_slots_page1.dart';
import 'package:cdbs_admin/subpages/login_page.dart';
import 'package:cdbs_admin/subpages/page6.dart';
import 'package:cdbs_admin/subpages/s1.dart';
import 'package:cdbs_admin/subpages/s2.dart';
import 'package:cdbs_admin/subpages/s3.dart';
import 'package:cdbs_admin/subpages/s4.dart';
import 'package:cdbs_admin/subpages/user%20overview/user_admin_accounts_page1.dart';
import 'package:cdbs_admin/subpages/user%20overview/user_guest_accounts_page1.dart';
import 'package:cdbs_admin/subpages/user%20overview/user_learner_accounts_page1.dart';
import 'package:cdbs_admin/subpages/user%20overview/user_parent_accounts_page1.dart';
import 'package:cdbs_admin/subpages/user%20overview/user_teacher_accounts_page1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'page1.dart'; // Import each page file
import 'page2.dart';
import 'page3.dart';
import 'page4.dart';
import 'page5.dart';
import 'page6.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _selectedPage = 0;
  final bool _isDropdownOpen = false; // Controls dropdown visibility
  final bool _isAdmissionDropdownOpen = false;
  final bool _isPreEnrollmentDropdownOpen = false;
  
  int _selectedDropdownOption = 0; // Tracks selected option in dropdown
  int _selectedAdmissionDropdownOption = 0; // Tracks selected option in dropdown
  int _selectedPreEnrollmentDropdownOption = 0; 
   int _openDropdownIndex = -1;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double baseWidth = 400; // Change based on your design
    double baseHeight = 800; // Change based on your design
    double widthScale = screenWidth / baseWidth;
    double heightScale = screenHeight / baseHeight;
    double scale = widthScale < heightScale ? widthScale : heightScale;
    

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
              (route) => false,
            );
          }
        },
        builder: (context, authState) {
          if (authState is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          } else if (authState is AuthSuccess) {
            return Row(
        children: [
          // Sidebar with 20% width and background image
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage('assets/Background.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.dstATop,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo section
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 10, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/Logo.png',
                        height: 50 * scale,
                      ),
                      SizedBox(width: 10 * scale),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              fontSize: 20 * scale,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Roboto-B",
                              color: const Color(0XFF13322B),
                            ),
                          ),
                          Text(
                            'Good morning wonderful person!',
                            style: TextStyle(
                              fontSize: 12 * scale,
                              fontFamily: "Varela-R",
                              color: const Color(0XFF13322B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.0 * scale),
                    child: Text(
                      'ADMIN MANAGEMENT',
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontFamily: "Poppins-L",
                        color: const Color(0XFF13322B),
                      ),
                    ),
                  ),
                ),
                // Sidebar Categories


//SIDEBAR CATEGORIES
Expanded(
  child: ListView(
    children: [
      SizedBox(height: 40 * scale), // Scalable height
      _buildMenuItem(0, 'Dashboard', Icons.dashboard, scale),
      SizedBox(height: 20 * scale), // Scalable height
      _buildMenuItem(1, 'Inquiry Forms', Icons.note_alt_rounded, scale),
      SizedBox(height: 20 * scale), // Scalable height
      _buildDropdownMenuItem(2, 'User Overview', Icons.group, scale), // Example icon
      SizedBox(height: 20 * scale), // Scalable height
      _buildAdmissionDropdownMenu(3, 'Admissions', Icons.school, scale),
      SizedBox(height: 20 * scale), // Scalable height
      _buildPreEnrollmentDropdownMenu(4, 'Pre-Enrollment', Icons.school, scale),
    ],
  ),
),




//LOGOUT BUTTON
Padding(
  padding: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
  child: ElevatedButton(
    onPressed: () {
      // Show the modal dialog when the button is clicked
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              width: 349 * scale,  // Scalable width
              height: 272 * scale, // Scalable height
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Confirmation',
                    style: TextStyle(
                      fontFamily: "Roboto-R",
                      fontSize: 20 * scale,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    'Are you sure you want to Logout?',
                    style: TextStyle(
                      fontFamily: "Roboto-L",
                      fontSize: 13 * scale,
                    ),
                  ),
                  SizedBox(height: 40 * scale),
                  Divider(
                    color: const Color(0xff909590),
                    thickness: 1 * scale,
                    indent: 20 * scale,
                    endIndent: 20 * scale,
                  ),
                  SizedBox(height: 30 * scale),
                  SizedBox(
                    width: 289 * scale,
                    height: 35 * scale,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the modal
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffD3D3D3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'No',
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontFamily: "Roboto-R",
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10 * scale), // Space between buttons
                  // Yes button
                  SizedBox(
                    width: 289 * scale,
                    height: 35 * scale,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the modal
                        // Add your "Yes" action here
                        context
                                      .read<AuthBloc>()
                                      .add(AuthLogoutRequested());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff012169),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 13 * scale,
                          fontFamily: "Roboto-R",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xff012169), // Set background color to 0xff012169
      minimumSize: Size(double.infinity, 47 * scale), // Scalable height
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Set border radius to 8
      ),
      padding: EdgeInsets.symmetric(horizontal: 24 * scale), // Adjust horizontal padding
    ),
    child: Text(
      'Logout',
      style: TextStyle(
        fontSize: 13 * scale,
        fontFamily: "Roboto-R",
        color: Colors.white,
      ),
    ),
  ),
),

              ],
            ),
          ),

          // Main content area
                    Expanded(
            child: _getPageContent(authState.adminType),
          ),
        ],
      );
      
  }
   return Container();
        }
  )
    );
  }

  // SIDEBAR CONTENTS
Widget _buildMenuItem(int index, String text, IconData icon, double scale) {
  bool isSelected  = _selectedPage == index;
  bool isDropdownOpen = _openDropdownIndex == index;
    return GestureDetector(
    onTap: () {
      setState(() {
        _selectedPage = index;
       _openDropdownIndex = (isDropdownOpen) ? -1 : index;
        
      });
    },
    child: Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff012169) : Colors.transparent,
          borderRadius: isSelected ? BorderRadius.circular(8) : BorderRadius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black,
                size: 24 * scale, // Make the icon size scalable
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Roboto-R',
                  fontSize: 16 * scale, // Make text size scalable
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


//DROPWDOWN MENU OVERVIEW
  Widget _buildDropdownMenuItem(int index, String text, IconData icon, double scale) {
  bool isSelected = _selectedPage == index;
  bool isDropdownOpen = _openDropdownIndex == index;
  List<String> dropdownOptions = ["Guest Accounts", "Learner Accounts", "Teacher Accounts", "Parent Accounts", "Admin Accounts"];
return Column(
    children: [
      GestureDetector(
        onTap: () {
          setState(() {
            _selectedPage = index;
            _openDropdownIndex = isDropdownOpen ? -1 : index;// Toggle dropdown visibility
          });
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.2,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xff012169) : Colors.transparent,
              borderRadius: isSelected ? BorderRadius.circular(8) : BorderRadius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black,
                size: 24 * scale, // Make the icon size scalable
              ),
                  const SizedBox(width: 8), 
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontFamily: 'Roboto-R', // Main item font
                        fontSize: 16 * scale,
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // Dropdown options
      if (isDropdownOpen)
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Column(
            children: List.generate(dropdownOptions.length, (i) {
              return GestureDetector(
  onTap: () {
    setState(() {
      _selectedDropdownOption = i;
    });
  },
  child: Padding(
    padding: const EdgeInsets.only(left: 30, right: 30),
    child: Container(
      width: MediaQuery.of(context).size.width * 0.2,
      padding: const EdgeInsets.only(left: 40, top: 10, bottom: 10),
      child: Text(
        dropdownOptions[i],
        style: TextStyle(
          fontFamily: 'Roboto-R', // Dropdown options font
          fontSize: 16 * scale,
          color: _selectedDropdownOption == i
              ? const Color(0xff012169)
              : const Color.fromARGB(118, 0, 0, 0),
          fontWeight: _selectedDropdownOption == i
              ? FontWeight.bold
              : FontWeight.normal, // Set to bold if selected
        ),
      ),
    ),
  ),
);

            }),
          ),
        ),
    ],
  );
}



//DROPWDOWN MENU ADMISSION
 Widget _buildAdmissionDropdownMenu(int index, String text, IconData icon, double scale) {
  bool isSelected = _selectedPage == index;
  bool isDropdownOpen = _openDropdownIndex == index;
   List<String> dropdownOptions = [];
  return BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
              (route) => false,
            );
          }
        },
        builder: (context, authState) {
          if (authState is AuthSuccess) {
            if(authState.adminType=='Admin' || authState.adminType=='Principal' || authState.adminType=='IT' || authState.adminType=='Sisters'){
              dropdownOptions = ["Slots", "Overview", "Applications", "Requirements", "Payments", "Schedules", "Results"];
            }else if(authState.adminType=='Cashier'){
              dropdownOptions = ["Payments"];
            }else if(authState.adminType=='Registrar'){
              dropdownOptions = ["Overview", "Applications", "Requirements", "Payments", "Schedules"];
            }else if(authState.adminType=='Admission' || authState.adminType=='Center for Learner Wellness'){
              dropdownOptions = ["Slots", "Overview", "Applications", "Requirements", "Schedules", "Results"];
            }
            return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPage = index;
                            _openDropdownIndex  = _isAdmissionDropdownOpen ? -1: index; // Toggle dropdown visibility
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xff012169) : Colors.transparent,
                              borderRadius: isSelected ? BorderRadius.circular(8) : BorderRadius.zero,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                icon,
                                color: isSelected ? Colors.white : Colors.black,
                                size: 24 * scale, // Make the icon size scalable
                              ),
                                  const SizedBox(width: 8), 
                                  Expanded(
                                    child: Text(
                                      text,
                                      style: TextStyle(
                                        fontFamily: 'Roboto-R', // Main item font
                                        fontSize: 16 * scale,
                                        color: isSelected ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Icon(
                                      _isAdmissionDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                      color: isSelected ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Dropdown options
                      if (isDropdownOpen)
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: Column(
                            children: List.generate(dropdownOptions.length, (i) {
                              return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAdmissionDropdownOption = i;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      padding: const EdgeInsets.only(left: 40, top: 10, bottom: 10),
                      child: Text(
                        dropdownOptions[i],
                        style: TextStyle(
                          fontFamily: 'Roboto-R', // Dropdown options font
                          fontSize: 16 * scale,
                          color: _selectedAdmissionDropdownOption == i
                              ? const Color(0xff012169)
                              : const Color.fromARGB(118, 0, 0, 0),
                          fontWeight: _selectedAdmissionDropdownOption == i
                              ? FontWeight.bold
                              : FontWeight.normal, // Set to bold if selected
                        ),
                      ),
                    ),
                  ),
                );
            }),
          ),
        ),
    ],
  );
          }
          return Container();
        }
  );
}



//DROPWDOWN MENU PRE ENROLLMENT
 Widget _buildPreEnrollmentDropdownMenu(int index, String text, IconData icon, double scale) {
  bool isSelected = _selectedPage == index;
  bool isDropdownOpen = _openDropdownIndex == index;
  List<String> dropdownOptions = ["Reservation", "Requirements"];

  return Column(
    children: [
      GestureDetector(
        onTap: () {
          setState(() {
            _selectedPage = index;
            _openDropdownIndex = _isPreEnrollmentDropdownOpen ? -1:index ; // Toggle dropdown visibility
          });
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.2,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xff012169) : Colors.transparent,
              borderRadius: isSelected ? BorderRadius.circular(8) : BorderRadius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                icon,
                color: isSelected ? Colors.white : Colors.black,
                size: 24 * scale, // Make the icon size scalable
              ),
                  const SizedBox(width: 8), 
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontFamily: 'Roboto-R', // Main item font
                        fontSize: 16 * scale,
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      _isPreEnrollmentDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // Dropdown options
      if (isDropdownOpen)
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Column(
            children: List.generate(dropdownOptions.length, (i) {
              return GestureDetector(
  onTap: () {
    setState(() {
      _selectedPreEnrollmentDropdownOption = i;
    });
  },
  child: Padding(
    padding: const EdgeInsets.only(left: 30, right: 30),
    child: Container(
      width: MediaQuery.of(context).size.width * 0.2,
      padding: const EdgeInsets.only(left: 40, top: 10, bottom: 10),
      child: Text(
        dropdownOptions[i],
        style: TextStyle(
          fontFamily: 'Roboto-R', // Dropdown options font
          fontSize: 16 * scale,
          color: _selectedPreEnrollmentDropdownOption == i
              ? const Color(0xff012169)
              : const Color.fromARGB(118, 0, 0, 0),
          fontWeight: _selectedPreEnrollmentDropdownOption == i
              ? FontWeight.bold
              : FontWeight.normal, // Set to bold if selected
        ),
      ),
    ),
  ),
);

            }),
          ),
        ),
    ],
  );
}











    // Function to return the selected page or dropdown option content
  Widget _getPageContent(String adminType) {
    if (_selectedPage == 2) {
      // Show content based on selected dropdown option for Page 5
      switch (_selectedDropdownOption) {
        case 0:
          return const UserGuestAccountsPage1();
        case 1:
          return const S1Page();
        case 2:
          return const S1Page();
        case 3:
          return const S1Page();
        case 4:
          return const UserAdminAccountsPage1();
        default:
          return const UserGuestAccountsPage1();
      }
    }



    if (_selectedPage == 3) {
      // Show content based on selected dropdown option for Page 5
      if(adminType !='Admission' && adminType !='Center for Learner Wellness'){
        switch (_selectedAdmissionDropdownOption) {
          case 0:
            return const AdmissionSlotsPage1();
          case 1:
            return const AdmissionOverviewPage();
          case 2:
            return const AdmissionApplicationsPage();
          case 3:
            return const AdmissionRequirementsPage();
          case 4:
            return const AdmissionPaymentsPage();
          case 5:
            return const AdmissionSchedulesPage();
          default:
            return const AdmissionResultsPage();
        }
      }else{
        switch (_selectedAdmissionDropdownOption) {
          case 0:
            return const AdmissionSlotsPage1();
          case 1:
            return const AdmissionOverviewPage();
          case 2:
            return const AdmissionApplicationsPage();
          case 3:
            return const AdmissionRequirementsPage();
          case 4:
            return const AdmissionSchedulesPage();
          case 5:
            return const AdmissionResultsPage();
          default:
            return const AdmissionResultsPage();
        }
      }
    }






    if (_selectedPage == 4) {
      // Show content based on selected dropdown option for Page 5
      switch (_selectedPreEnrollmentDropdownOption) {
        case 0:
          return const S1Page();
        case 1:
          return const S1Page();
        default:
          return const Page6();
      }
    }



    // Show the main page content for other pages
    switch (_selectedPage) {
      case 0:
        return const S1Page();
      case 1:
        return const S1Page();
      case 2:
        return const Page3();
      case 3:
        return const Page4();
      default:
        return const Page1();
    }
  }




}
