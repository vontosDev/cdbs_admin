import 'dart:async';
import 'package:cdbs_admin/subpages/s2.dart';
import 'package:intl/intl.dart';
import 'package:cdbs_admin/bloc/auth/auth_bloc.dart';
import 'package:cdbs_admin/class/admission_forms.dart';
import 'package:cdbs_admin/shared/api.dart';
import 'package:cdbs_admin/subpages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AdmissionOverviewPage extends StatefulWidget {
  const AdmissionOverviewPage({super.key});

  @override
  State<AdmissionOverviewPage> createState() => _AdmissionOverviewPageState();
}



class _AdmissionOverviewPageState extends State<AdmissionOverviewPage> {
  
  late ApiService _apiService;
  // Variable to track current action
  int _selectedAction = 0; // 0: Default, 1: View, 2: Reminder, 3: Deactivate
  late Stream<List<Map<String, dynamic>>> admissionForms;
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> filteredRequest = [];
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  
  Color statusColor = Colors.black;
  @override
  void initState() {
    super.initState();
    _apiService = ApiService(apiUrl); // Replace with your actual API URL
    admissionForms = _apiService.streamAdmissionForms(supabaseUrl, supabaseKey);
    // Initialize the service with your endpoint
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value.toLowerCase();
    });
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



  String formatDate(DateTime date) {
  // Convert the UTC date to local time
  DateTime localDate = date.toLocal();

  // Create a DateFormat object to format the date
  final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');

  // Return the formatted date in local time
  return formatter.format(localDate);
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
                builder: (context) => const LoginPage(),
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
            if (_selectedAction == 0) _buildDefaultContent(scale), // Default content
            if (_selectedAction == 1) _buildViewContent(scale), // View content
            if (_selectedAction == 2) _buildReminderContent(scale), // Reminder content
            if (_selectedAction == 3) _buildDeactivateContent(scale),
            if (_selectedAction == 0) ...[
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Overview',
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
                  flex: 1,
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
                  flex: 1,
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
                  final fullName = '${capitalizeEachWord(request['db_admission_table']['last_name'])}, ${capitalizeEachWord(request['db_admission_table']['first_name'])} ${capitalizeEachWord(request['db_admission_table']['middle_name'])}';
                  final processBy = request['db_admission_table']['db_admission_form_handler_table'].isNotEmpty
    ? '${request['db_admission_table']['db_admission_form_handler_table'][0]['db_admin_table']['first_name']} ${request['db_admission_table']['db_admission_form_handler_table'][0]['db_admin_table']['last_name']}'
    : '---';
                  bool isComplete = request['db_admission_table']['is_complete_view'];
                  bool isRequired = request['db_admission_table']['is_all_required_file_uploaded'];
                  bool isPaid = request['db_admission_table']['is_paid'] ?? false;
                  bool isAssess = request['db_admission_table']['is_for_assessment'];
                  bool isResult = request['db_admission_table']['is_final_result'];
                  List<bool> checkboxStates = List.generate(filteredRequest.length, (_) => false);
                  String dateCreatedString='';
                  DateTime dateCreated;
                  String formattedDate='';
                  if(request['db_admission_table']['created_at']!=null){
                     dateCreatedString = request['db_admission_table']['created_at'];
                     dateCreated = DateTime.parse(dateCreatedString);
                     formattedDate= formatDate(dateCreated);
                  }
                  String statusText;
                  if(isResult){
                   statusText = request['db_admission_table']['admission_status'];
                  }else{
                    statusText = request['db_admission_table']['admission_status']=='complete'?'pending':request['db_admission_table']['admission_status'];
                  }
                  String titleText = '';

                  if (isResult) {
                        titleText = 'RESULTS - ';
                        statusColor = _getStatusColor(statusText);
                      } else {
                        // Start checking other conditions based on is_final_result being false
                        if (!isAssess) {
                          if (isPaid) {
                            titleText = 'ASSESSMENT - ';
                            statusColor = _getStatusColor(statusText);
                          } else if (isRequired) {
                            titleText = 'PAYMENTS - ';
                            statusColor = _getStatusColor(statusText);
                          } else if (isComplete) {
                            titleText = 'REQUIREMENTS - ';
                            statusColor = _getStatusColor(statusText);
                          } else {
                            titleText = 'APPLICATION - ';
                            statusColor = _getStatusColor(statusText);
                          }
                        } else {
                          titleText = 'RESULTS - ';
                          statusColor = _getStatusColor(statusText);
                        }
                      }
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
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
                            child: Text(fullName,
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(processBy ?? '---',
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Text(titleText,
                                  style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                                ),
                                Text(statusText.toUpperCase(),
                                  style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale, color: statusColor),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(formattedDate,
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                            ),
                          ),
                            // Other table cells...
                            Expanded(
                              flex: 1,
                              child: PopupMenuButton<int>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  setState(() {
                                    _selectedAction = value; // Change the selected action
                                  });
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    // value: 1,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.visibility, color: Color(0xff909590)),
                                        SizedBox(width: 8 * scale),
                                        Text("VIEW", style: TextStyle(fontSize: 18 * scale, color: const Color(0xff909590))),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    // value: 2,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.notifications, color: Color(0xff909590)),
                                        SizedBox(width: 8 * scale),
                                        Text("REMINDER", style: TextStyle(fontSize: 18 * scale, color: const Color(0xff909590))),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    // value: 3,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.block, color: Color(0xff909590)),
                                        SizedBox(width: 8 * scale),
                                        Text("CANCEL", style: TextStyle(fontSize: 18 * scale, color: const Color(0xff909590))),
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
  Widget _buildViewContent(double scale) {
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
        ],
      ),
      
      // Adding AdmissionApplicationsPage2 below the buttons
      const S2Page(),
    ],
  ),
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
  // Sort based on the conditions you outlined
  requests.sort((a, b) {
    // Check for pending admission status
    String admissionStatusA = a['db_admission_table']['admission_status'] ?? '';
    String admissionStatusB = b['db_admission_table']['admission_status'] ?? '';

    // If admission status is 'pending', it should come first
    if (admissionStatusA == 'pending' && admissionStatusB != 'pending') {
      return -1; // 'a' should come before 'b'
    } else if (admissionStatusB == 'pending' && admissionStatusA != 'pending') {
      return 1; // 'b' should come before 'a'
    }

    // Extracting other flags from the nested db_admission_table structure
    bool isCompleteA = a['db_admission_table']['is_complete_view'];
    bool isRequiredA = a['db_admission_table']['is_all_required_file_uploaded'];
    bool isPaidA = a['db_admission_table']['is_paid'] ?? false;
    bool isAssessA = a['db_admission_table']['is_for_assessment'];
    bool isResultA = a['db_admission_table']['is_final_result'];

    bool isCompleteB = b['db_admission_table']['is_complete_view'];
    bool isRequiredB = b['db_admission_table']['is_all_required_file_uploaded'];
    bool isPaidB = b['db_admission_table']['is_paid'] ?? false;
    bool isAssessB = b['db_admission_table']['is_for_assessment'];
    bool isResultB = b['db_admission_table']['is_final_result'];

    // Custom sorting order based on the conditions
    int sortOrderA = _getSortOrder(isCompleteA, isRequiredA, isPaidA, isAssessA, isResultA);
    int sortOrderB = _getSortOrder(isCompleteB, isRequiredB, isPaidB, isAssessB, isResultB);

    // Return comparison based on the custom sort order
    return sortOrderA.compareTo(sortOrderB);  // Ascending order based on the calculated sort order
  });

  return requests;
}

// Helper function to calculate sort order based on boolean flags
int _getSortOrder(bool isComplete, bool isRequired, bool isPaid, bool isAssess, bool isResult) {
  if (!isComplete) {
    return 1; // First group: !isComplete
  } else if (isComplete && !isRequired) {
    return 2; // Second group: isComplete && !isRequired
  } else if (isComplete && isRequired && !isPaid) {
    return 3; // Third group: isComplete && isRequired && !isPaid
  } else if (isComplete && isRequired && isPaid && !isAssess) {
    return 4; // Fourth group: isComplete && isRequired && isPaid && !isAssess
  } else if (isComplete && isRequired && isPaid && isAssess && !isResult) {
    return 5; // Fifth group: isComplete && isRequired && isPaid && isAssess && !isResult
  } else if (isResult) {
    return 6; // Last group: isResult
  } else {
    return 0; // Default case, in case all conditions are met
  }
}

}

