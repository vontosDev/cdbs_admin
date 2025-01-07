//RESULTS PAGE1

import 'package:cdbs_admin/bloc/admission_bloc/admission_bloc.dart';
import 'package:cdbs_admin/bloc/auth/auth_bloc.dart';
import 'package:cdbs_admin/class/admission_forms.dart';
import 'package:cdbs_admin/shared/api.dart';
import 'package:cdbs_admin/subpages/admissions/admission_requirements_page2.dart';
import 'package:cdbs_admin/subpages/admissions/admission_results_page2.dart';
import 'package:cdbs_admin/subpages/landing_page.dart';
import 'package:cdbs_admin/subpages/s1.dart';
import 'package:cdbs_admin/subpages/s2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdmissionResultsPage extends StatefulWidget {
  const AdmissionResultsPage({super.key});

  @override
  State<AdmissionResultsPage> createState() => _AdmissionResultsPageState();
}

class _AdmissionResultsPageState extends State<AdmissionResultsPage> {
//List<bool> checkboxStates = List.generate(10, (_) => false);

  int _selectedAction = 0; // 0: Default, 1: View, 2: Reminder, 3: Deactivate
  late Stream<List<Map<String, dynamic>>> admissionForms;
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> filteredRequest = [];
  late ApiService _apiService;
  List<Map<String, dynamic>>? formDetails;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(apiUrl); // Replace with your actual API URL
    admissionForms = _apiService.streamAdmissionResult(supabaseUrl, supabaseKey);
    // Initialize the service with your endpoint
  }

  
String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');
    return formatter.format(date);
  }


  String capitalizeEachWord(String input) {
    if (input.isEmpty) return input; // Check if the input is empty
    
    // Split the input into words, capitalize each word, and join them back
    return input
        .split(' ') // Split the input string into a list of words
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase() // Capitalize each word
            : word) // Handle empty words
        .join(' '); // Join the words back into a single string with spaces
  }

  Color _getStatusColor(String status) {
      if (status.contains('complete') || status.contains('passed')) {
        return const Color(0xFF007A33); // Green for complete
      } else if (status.contains('in review')) {
        return const Color(0xFFFFA500); // Yellow for in-review
      } else if (status.contains('pending')) {
        return const Color(0xFFB6B6B6); // Orange for pending
      }else if (status.contains('failed')) {
        return const Color(0xFFE15252); // Orange for pending
      } else {
        return Colors.black; // Default color
      }
    }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value.toLowerCase();
    });
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
          if (state is AuthInitial) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const LandingPage(),
              ),
              (route) => false,
            );
          }
        },
        builder: (context, authState) {
          if (authState is AuthLoading) {
            return const Center(
              // Center the spinner when loading
              child: SpinKitCircle(
                color: Color(0xff012169), // Change the color as needed
                size: 50.0, // Adjust size as needed
              ),
            );
          } else if (authState is AuthSuccess) {
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: admissionForms,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
              // Center the spinner when loading
                    child: SpinKitCircle(
                      color: Color(0xff012169), // Change the color as needed
                      size: 50.0, // Adjust size as needed
                    ),
                  );
                }
                requests = snapshot.data ?? []; // Use the data from the snapshot
                filteredRequest = sortRequests(requests);

                filteredRequest = filteredRequest.where((request) {
                        final formId = request['db_admission_table']['admission_form_id']?.toLowerCase() ?? '';
                        return formId.contains(searchQuery);
                      
                    }).toList();

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 40),
  child: Column(
    children: [
      // Check if _selectedAction == 0 to show the default content

        // Header and Search Bar
        Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Admissions',
            style: TextStyle(
              color: const Color(0xff222222),
              fontFamily: "Roboto-R",
              fontSize: 34 * scale,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      const Divider(
        thickness: 2,
        color: Color(0XFF222222),
      ),

      if (_selectedAction == 0) _buildDefaultContent(scale), // Default content
      if (_selectedAction == 1) _buildViewContent(scale, formDetails!, authState.uid), // View content
      if (_selectedAction == 2) _buildReminderContent(scale), // Reminder content
      if (_selectedAction == 3) _buildDeactivateContent(scale),
      if (_selectedAction == 4) _buildDeactivateContent(scale),
      if (_selectedAction == 5) _buildDeactivateContent(scale),
      if (_selectedAction == 0) ...[



      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Results',
            style: TextStyle(
              color: const Color(0xff222222),
              fontFamily: "Roboto-L",
              fontSize: 22 * scale,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 226 * scale,
            height: 32 * scale,
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: '',
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: Colors.blue, width: 1),
                ),
                prefixIcon: InkWell(
                  onTap: () {
                    print("Search icon tapped");
                  },
                  child: Icon(
                    Icons.search,
                    size: 20 * scale,
                    color: Colors.grey,
                  ),
                ),
              ),
              onChanged: _onSearchChanged,
              style: TextStyle(fontSize: 16 * scale),
            ),
          ),
        ],
      ),
      const SizedBox(height: 40),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Application ID',
              style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Applicant Name',
              style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Handled By',
              style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Date Created',
              style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
            ),
          ),
          const Expanded(flex: 1, child: SizedBox.shrink()),
        ],
      ),
      const Divider(color: Colors.grey, thickness: 1),
      Expanded(
        child: ListView.builder(
                itemCount: filteredRequest.length,
                itemBuilder: (context, index) {
                  final request = filteredRequest[index];
                  final fullName = '${capitalizeEachWord(request['db_admission_table']['first_name'])} ${capitalizeEachWord(request['db_admission_table']['last_name'])}';
                  final processBy = request['db_admission_table']['db_admission_form_handler_table'].isNotEmpty
    ? '${request['db_admission_table']['db_admission_form_handler_table'][0]['db_admin_table']['first_name']} ${request['db_admission_table']['db_admission_form_handler_table'][0]['db_admin_table']['last_name']}'
    : '---';
                  List<bool> checkboxStates = List.generate(filteredRequest.length, (_) => false);
                  String dateCreatedString = request['db_admission_table']['created_at'];
                  DateTime dateCreated = DateTime.parse(dateCreatedString);
                  String formattedDate = formatDate(dateCreated);
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: checkboxStates[index],
                                  onChanged: (value) {
                                    setState(() {
                                      checkboxStates[index] = value ?? false;
                                    });
                                  },
                                  activeColor: const Color(0XFF012169), // Set the active color to pink
                                ),
                                Text(
                                  request['db_admission_table']['admission_form_id'].toString(),
                                  style: TextStyle(fontSize: 16 * scale),
                                ),
                              ],
                            ),
                          ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        fullName,
                        style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        processBy,
                        style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        request['db_admission_table']['is_final_result']?'COMPLETE':request['db_admission_table']['admission_status'],
                        style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale,
                        color: request['db_admission_table']['is_final_result']?const Color(0xFF007A33):_getStatusColor(request['db_admission_table']['admission_status']),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        formattedDate,
                        style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                      ),
                    ),
                      // Other table cells...
                      Expanded(
                        flex: 1,
                        child: PopupMenuButton<int>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) async {
                            List<Map<String, dynamic>> members = await ApiService(apiUrl).getFormsDetailsById(request['admission_id'], supabaseUrl, supabaseKey);
                            if(members.isNotEmpty){
                              setState(() {
                                formDetails=members;
                              _selectedAction = value; // Change the selected action
                            });
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                                    value: 1,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.visibility, color: Colors.black),
                                        SizedBox(width: 8 * scale),
                                        Text("VIEW", style: TextStyle(fontSize: 16 * scale)),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    // value: 2,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.notifications, color: Color(0xff909590)),
                                        SizedBox(width: 8 * scale),
                                        Text("REMINDER", style: TextStyle(fontSize: 16 * scale, color: const Color(0xff909590))),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    // value: 3,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.block, color: Color(0xff909590)),
                                        SizedBox(width: 8 * scale),
                                        Text("CANCEL", style: TextStyle(fontSize: 16 * scale, color: const Color(0xff909590))),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey, thickness: 1),
                ],
              );
            },
          ),
        ),
      ],
    ],
  ),
);
              }
            );
          }
          return Container();
        }
      )
    );
  }

  // Build content for each action (VIEW, REMINDER, DEACTIVATE)
  Widget _buildViewContent(double scale, List<Map<String, dynamic>> details, int userId) {
    return BlocConsumer<AdmissionBloc, AdmissionState>(
      listener: (context, state) {},
      builder: (context, state) {
              bool isButtonEnabled = false;
              bool isResult = false;
              bool isPassed = false;
              // Enable button based on the state
              if (state is AdmissionResultUpdated) {
                isButtonEnabled = state.isComplete;
                isResult = state.isResult;
                isPassed = state.isPassed;
              }
        return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Back button with left arrow and "Back" text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedAction = 0; // Go back to default content
                            });
                          },
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          label: Text(
                            "Back",
                            style: TextStyle(color: Colors.black, fontFamily: 'Roboto-R', fontSize: 14 * scale),
                          ),
                        ),
                        
                        // Two buttons on the right
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF012169), // Blue color
                                fixedSize: Size(178 * scale, 37 * scale), // Button size
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5), // Border radius
                                ),
                              ),
                              onPressed: () {
                                // Action for first button
                              },
                              child: Text(
                                "Download PDF",
                                style: TextStyle(color: Colors.white, fontFamily: 'Roboto-R', fontSize: 14 * scale),
                              ),
                            ),
                            const SizedBox(width: 8), // Spacing between buttons
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF007A33), // Green color
                                fixedSize: Size(178 * scale, 37 * scale), // Button size
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5), // Border radius
                                ),
                              ),
                              onPressed: isButtonEnabled?() async {
                                try {
                                    final response = await http.post(
                                      Uri.parse('$apiUrl/api/admin/update_admission'),
                                      headers: {
                                        'Content-Type': 'application/json',
                                        'supabase-url': supabaseUrl,
                                        'supabase-key': supabaseKey,
                                      },
                                      body: json.encode({
                                        'admission_id': details[0]['admission_id'], // Send admission_id in the request body
                                        'admission_status': "complete",
                                        'is_result': isResult,
                                        'is_passed':isPassed,
                                        'user_id': userId,
                                        'is_done': true,
                                      }),
                                    );

                                    if (response.statusCode == 200) {
                                      final responseBody = jsonDecode(response.body);

                                      // Show success modal
                                      showDialog(
  context: context,
  builder: (context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    child: SizedBox(
      width: 349.0,
      height: 272.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text(
              "Confirmation",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Content
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              "Are you sure you want to confirm?",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16.0),
          // Divider
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Divider(thickness: 1),
          ),
          const SizedBox(height: 16.0),
          // No Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: SizedBox(
              width: 289,
              height: 35,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xffD3D3D3), // No button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                },
                child: const Text(
                  "No",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12.0), // Spacing between buttons
          // Yes Button
          Padding(
  padding: const EdgeInsets.symmetric(horizontal: 30.0),
  child: SizedBox(
    width: 289,
    height: 35,
    child: TextButton(
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xff012169), // Amber button color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {},
      child: const Text(
        "Yes",
        style: TextStyle(color: Colors.white),
      ),
    ),
  ),
),

        ],
      ),
    ),
  ),
);
                                    } else {
                                      // Handle failure
                                      final responseBody = jsonDecode(response.body);
                                      print('Error: ${responseBody['error']}');

                                      // Show failure modal
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Error"),
                                          content: Text("Failed to complete review: ${responseBody['error']}"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close the dialog
                                              },
                                              child: const Text("OK"),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  } catch (error) {
                                    // Handle error (e.g., network error)
                                    print('Error: $error');

                                    // Show error modal
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Error"),
                                        content: const Text("An unexpected error occurred. Please try again later."),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(); // Close the dialog
                                            },
                                            child: const Text("OK"),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                              }:null,
                              child: Text(
                                "Mark as Complete",
                                style: TextStyle(color: Colors.white, fontFamily: 'Roboto-R', fontSize: 14 * scale),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // Adding AdmissionApplicationsPage2 below the buttons
                    AdmissionResultsPage2(formDetails: details, onNextPressed: (bool isClicked, bool isResult, bool isPassed) {
                      context.read<AdmissionBloc>().add(MarkAsResultPassedClicked(isResult: isResult, isPassed: isPassed, isComplete: isClicked));
                    },userId: userId,),
                  ],
                ),
              );
      }
    );



  }



  

  Widget _buildReminderContent(double scale) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'REMINDER content goes here.',
            style: TextStyle(fontSize: 20 * scale),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedAction = 0; // Go back to default content
              });
            },
            child: const Text("Go Back"),
          ),
        ],
      ),
    );
  }

  Widget _buildDeactivateContent(double scale) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'DEACTIVATE content goes here.',
            style: TextStyle(fontSize: 20 * scale),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedAction = 0; // Go back to default content
              });
            },
            child: const Text("Go Back"),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultContent(double scale) {
    return Container(
      // padding: const EdgeInsets.all(16),
      // child: Text(
      //   '',
      //   style: TextStyle(fontSize: 20 * scale),
      // ),
    );
  }


  List<Map<String, dynamic>> sortRequests(List<Map<String, dynamic>> requests) {
  requests.sort((a, b) {
    // Extract the admission statuses
    String admissionStatusA = a['db_admission_table']['admission_status'] ?? '';
    String admissionStatusB = b['db_admission_table']['admission_status'] ?? '';

    // Extract the is_complete_view flag
    bool isCompleteA = a['db_admission_table']['is_final_result'];
    bool isCompleteB = b['db_admission_table']['is_final_result'];

    // 1. First, check for 'pending' - it should come first.
    if (admissionStatusA == 'pending' && admissionStatusB != 'pending' && !isCompleteA) {
      return -1; // 'a' (pending) should come before 'b'
    } else if (admissionStatusB == 'pending' && admissionStatusA != 'pending' && !isCompleteB) {
      return 1; // 'b' (pending) should come before 'a'
    }

    // 2. Next, check for 'in review' - it should come after 'pending', but before other statuses.
    if (admissionStatusA == 'in review' && admissionStatusB != 'pending' && admissionStatusB != 'in review') {
      return -1; // 'a' (in review) should come before 'b'
    } else if (admissionStatusB == 'in review' && admissionStatusA != 'pending' && admissionStatusA != 'in review') {
      return 1; // 'b' (in review) should come before 'a'
    }

    // 3. If one of the statuses is 'pending' or 'in review' and its is_complete_view is true, push it to the end.
    // However, we only do this after sorting 'pending' and 'in review'.
    if ((admissionStatusA == 'pending' || admissionStatusA == 'in review') && isCompleteA) {
      return 1; // 'a' (pending/in review with complete) should go after 'b'
    } else if ((admissionStatusB == 'pending' || admissionStatusB == 'in review') && isCompleteB) {
      return -1; // 'b' (pending/in review with complete) should go after 'a'
    }

    // 4. Now, use _getSortOrder to compare other statuses based on is_complete_view
    // This will be applied to statuses that are neither 'pending' nor 'in review'.
    int sortOrderA = _getSortOrder(isCompleteA);
    int sortOrderB = _getSortOrder(isCompleteB);

    // 5. If both are neither 'pending' nor 'in review', compare them using _getSortOrder.
    return sortOrderA.compareTo(sortOrderB);
  });

  return requests;
}

// Helper function to calculate sort order based on boolean flags (this can be expanded for more flags)
int _getSortOrder(bool isComplete) {
  if (!isComplete) {
    return 0; // First group: incomplete statuses will come first.
  } else {
    return 1; // Second group: complete statuses will come later.
  }
}
}

