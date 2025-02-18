import 'package:cdbs_admin/bloc/admission_bloc/admission_bloc.dart';
import 'package:cdbs_admin/bloc/auth/auth_bloc.dart';
import 'package:cdbs_admin/class/admission_forms.dart';
import 'package:cdbs_admin/shared/api.dart';
import 'package:cdbs_admin/subpages/admissions/admission_payments_page2.dart';
import 'package:cdbs_admin/subpages/admissions/admission_requirements_page2.dart';
import 'package:cdbs_admin/subpages/landing_page.dart';
import 'package:cdbs_admin/subpages/s1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'package:excel/excel.dart' hide Border;

class AdmissionPaymentsPage extends StatefulWidget {
  const AdmissionPaymentsPage({super.key});

  @override
  State<AdmissionPaymentsPage> createState() => _AdmissionPaymentsPageState();
}

class _AdmissionPaymentsPageState extends State<AdmissionPaymentsPage> {
//List<bool> checkboxStates = List.generate(10, (_) => false);

  int _selectedAction = 0; // 0: Default, 1: View, 2: Reminder, 3: Deactivate
  late Stream<List<Map<String, dynamic>>> admissionForms;
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> filteredRequest = [];
  late ApiService _apiService;
  List<Map<String, dynamic>>? formDetails;
  String statusFilter = '';
  int activeButtonIndex = -1;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  Future<void> fetchFormDetails(int id) async {
    try {
      // Perform the async operation to get the data
      List<Map<String, dynamic>> details = await ApiService(apiUrl).getDetailsById(
        id,
        supabaseUrl,
        supabaseKey,
      );

      // Once data is fetched, call setState to update the UI
      if (mounted) {
        setState(() {
          formDetails = details;
        });
      }
    } catch (e) {
      print("Error fetching form details: $e");
    }
  }

  void filterByStatus(String status) {
    setState(() {
      statusFilter = status; // Update the filter
    });
  }

  void _onSearchChanged(String value) {
    /*setState(() {
      searchQuery = value.toLowerCase();
    });*/
    if (value.isEmpty) {
       _apiService.startPaymentStreaming(supabaseUrl, supabaseKey); // Restart normal streaming
      admissionForms = _apiService.admissionFormsStream;
    } else {
      
      _apiService.searchPaymentAdmissionForms(supabaseUrl,supabaseKey,value); // Perform search
      admissionForms = _apiService.admissionFormsStream;
    }
  }

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(apiUrl); // Replace with your actual API URL
    //admissionForms = _apiService.streamPaymentForms(supabaseUrl, supabaseKey);
    // Initialize the service with your endpoint
    _onSearchChanged('');
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

List<Map<String, dynamic>> sortRequests(List<Map<String, dynamic>> requests, String adminType) {

    if (adminType == 'Center for Learner Wellness') {
    requests = requests.where((request) {
      return request['db_admission_table']['is_paid'] == true;
    }).toList();
  }


  requests.sort((a, b) {
    // Extract the is_complete_view flag
    bool isCompleteA = a['db_admission_table']['is_paid'];
    bool isCompleteB = b['db_admission_table']['is_paid'];

    // 4. Now, use _getSortOrder to compare other statuses based on is_complete_view
    // This will be applied to statuses that are neither 'pending' nor 'in review'.
    int sortOrderA = _getSortOrder(isCompleteA);
    int sortOrderB = _getSortOrder(isCompleteB);

    // 5. If both are neither 'pending' nor 'in review', compare them using _getSortOrder.
    return sortOrderA.compareTo(sortOrderB);
  });

  return requests;
}


  Color _getStatusColor(String status) {
      if (status.contains('complete') || status.contains('passed')) {
        return const Color(0xFF007A33); // Green for complete
      } else if (status.contains('in review')) {
        return const Color(0xFFFFA500); // Yellow for in-review
      } else if (status.contains('pending')) {
        return const Color(0xFFB6B6B6); // Orange for pending
      }else if (status.contains('rejected')) {
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
                filteredRequest = sortRequests(requests, authState.adminType);
                filteredRequest = statusFilter.isEmpty
                                            ? sortRequests(requests, authState.adminType)
                                            : sortRequests(requests, authState.adminType)
                                                .where((request) =>
                                                    request['db_admission_table']['db_payment_method_table']['payment_method'] ==
                                                    statusFilter)
                                                .toList();

                /*filteredRequest = filteredRequest.where((request) {
                        final formId = request['db_admission_table']['admission_form_id']?.toLowerCase() ?? '';
                        return formId.contains(searchQuery);
                      
                    }).toList();*/

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
      if (_selectedAction == 1) _buildViewContent(scale, formDetails!, authState.uid, authState.adminType), // View content
      if (_selectedAction == 2) _buildReminderContent(scale), // Reminder content
      if (_selectedAction == 3) _buildDeactivateContent(scale),
      if (_selectedAction == 4) _buildDeactivateContent(scale),
      if (_selectedAction == 5) _buildDeactivateContent(scale),
      if (_selectedAction == 0) ...[



Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    Text(
      'Payments',
      style: TextStyle(
        color: const Color(0xff222222),
        fontFamily: "Roboto-L",
        fontSize: 22 * scale,
      ),
    ),
    const Spacer(),
    ElevatedButton(
                    onPressed: ()=> _saveExcel(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff012169),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: const Text(
                      'Export to Sheets',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Roboto-R',
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 15),
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

// Add Cards Here
SizedBox(
  width: 800,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: GestureDetector(
          onTap: () {
                                    setState(() {
                                      if (activeButtonIndex == 0) {
                                        // If the button is already active, show all requests
                                        activeButtonIndex =
                                            -1; // Reset to inactive state
                                        statusFilter = '';
                                        filteredRequest = statusFilter.isEmpty
                                            ? requests
                                            : requests
                                                .where((request) =>
                                                    request['db_admission_table']['db_payment_method_table']['payment_method'] ==
                                                    statusFilter)
                                                .toList();
                                      } else {
                                        // Set active button index to the first button and filter by approved status
                                        activeButtonIndex = 0;
                                        filterByStatus('UnionBank');
                                      }
                                    });
                                  },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "UnionBank",
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      "UnionBank Bills Payment",
                      style: TextStyle(fontSize: 16 * scale),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: GestureDetector(
          onTap: () {
                                    setState(() {
                                      if (activeButtonIndex == 0) {
                                        // If the button is already active, show all requests
                                        activeButtonIndex =
                                            -1; // Reset to inactive state
                                        statusFilter = '';
                                        filteredRequest = statusFilter.isEmpty
                                            ? requests
                                            : requests
                                                .where((request) =>
                                                    request['db_admission_table']['db_payment_method_table']['payment_method'] ==
                                                    statusFilter)
                                                .toList();
                                      } else {
                                        // Set active button index to the first button and filter by approved status
                                        activeButtonIndex = 0;
                                        filterByStatus('Cash');
                                      }
                                    });
                                  },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Cash",
                      style: TextStyle(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      "Over the counter payment",
                      style: TextStyle(fontSize: 16 * scale),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ),
),
const SizedBox(height: 40),

      const Divider(color: Colors.grey, thickness: 3),

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
            flex: 3,
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
              'Payment Method',
              style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
            ),
          ),
         /* Expanded(
            flex: 2,
            child: Text(
              'Reference No',
              style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
            ),
          ),*/
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
                  final fullName = '${capitalizeEachWord(request['db_admission_table']['last_name'])}, ${capitalizeEachWord(request['db_admission_table']['first_name'])} ${capitalizeEachWord(request['db_admission_table']['middle_name'])}';
                  final processBy = request['db_admission_table']['db_admission_form_handler_table'].isNotEmpty
    ? '${request['db_admission_table']['db_admission_form_handler_table'][0]['db_admin_table']['first_name']} ${request['db_admission_table']['db_admission_form_handler_table'][0]['db_admin_table']['last_name']}'
    : '---';
                  List<bool> checkboxStates = List.generate(filteredRequest.length, (_) => false);
                  String dateCreatedString = request['db_admission_table']['created_at'];
                  DateTime dateCreated = DateTime.parse(dateCreatedString);
                  String formattedDate = formatDate(dateCreated);

                  String stat= request['db_admission_table']['admission_status'];
                  bool isRequired= request['db_admission_table']['is_all_required_file_uploaded'];
                  bool isPaid= request['db_admission_table']['is_paid'] ?? false;
                  String paymethod='---';
                  if(request['db_admission_table']['db_payment_method_table'] != null){
                     paymethod =request['db_admission_table']['db_payment_method_table']['payment_method'];
                  }
                  
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                // Checkbox(
                                //   value: checkboxStates[index],
                                //   onChanged: (value) {
                                //     setState(() {
                                //       checkboxStates[index] = value ?? false;
                                //     });
                                //   },
                                //   activeColor: const Color(0XFF012169), // Set the active color to pink
                                // ),
                                SelectableText(
                                  request['db_admission_table']['admission_form_id'].toString(),
                                  style: TextStyle(fontSize: 16 * scale),
                                ),
                              ],
                            ),
                          ),
                  //  Expanded(
                  //   flex: 3,
                  //   child: Tooltip(
                  //     message: fullName, // Full name shown on hover
                  //     padding: const EdgeInsets.all(8.0),
                  //     decoration: BoxDecoration(
                  //       color: const Color(0xff012169),
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //     textStyle: const TextStyle(
                  //       color: Colors.white,
                  //       fontSize: 14,
                  //     ),
                  //     child: Text(
                  //       fullName,
                  //       style: TextStyle(
                  //         fontFamily: 'Roboto-R',
                  //         fontSize: 16 * scale,
                  //       ),
                  //       overflow: TextOverflow.ellipsis,
                  //       maxLines: 1,
                  //     ),
                  //   ),
                  // ),
                  Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                SelectableText(
                                  fullName,
                                  style: TextStyle(fontSize: 16 * scale),
                                ),
                              ],
                            ),
                          ),
                    Expanded(
                      flex: 2,
                      child: SelectableText(
                        processBy,
                        style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: SelectableText( paymethod,
                        style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                      ),
                    ),
                   /* Expanded(
                      flex: 2,
                      child: Text( request['reference_no'] ?? '',
                        style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                      ),
                    ),*/
                    Expanded(
                      flex: 2,
                      child: SelectableText(!isPaid?stat=='complete' && isRequired?'PENDING':stat.toUpperCase():'COMPLETE',
                        style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale,
                        color: isPaid?const Color(0xFF007A33):_getStatusColor(request['db_admission_table']['admission_status'])),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: SelectableText(
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
                            List<Map<String, dynamic>> members = await ApiService(apiUrl).getDetailsById(request['admission_id'], supabaseUrl, supabaseKey);
                                     if(members.isNotEmpty){
                                        setState(()  {
                                          formDetails=members;
                                          _selectedAction = value; // Change the selected action
                                        });
                                        bool isPaid = request['db_admission_table']['is_paid']??false;
                                        if(!isPaid){
                                          try {
                                            final response = await http.post(
                                              Uri.parse('$apiUrl/api/admin/update_admission'),
                                              headers: {
                                                'Content-Type': 'application/json',
                                                'supabase-url': supabaseUrl,
                                                'supabase-key': supabaseKey,
                                              },
                                              body: json.encode({
                                                'admission_id': request['admission_id'],
                                                'admission_status':'in review',  // Send customer_id in the request body
                                                'user_id':authState.uid
                                              }),
                                            );

                                            if (response.statusCode == 200) {
                                              final responseBody = jsonDecode(response.body);
                                            } else {
                                              // Handle failure
                                              final responseBody = jsonDecode(response.body);
                                              print('Error: ${responseBody['error']}');
                                            }
                                          } catch (error) {
                                            // Handle error (e.g., network error)
                                            print('Error: $error');
                                          }
                                        }
                                     }
                          },
                          itemBuilder: (context) => [
                                if(authState.adminType!='Registrar')
                                  PopupMenuItem(
                                    value: 1,
                                    child:  Row(
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
  Widget _buildViewContent(double scale, List<Map<String, dynamic>> details, int userId, String adminType) {
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
       AdmissionPaymentsPage2(formDetails: details, onNextPressed: (bool isClicked) {
         context.read<AdmissionBloc>().add(MarkAsCompleteClicked(isClicked));
       },userId: userId, adminType:adminType),
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

  

// Helper function to calculate sort order based on boolean flags (this can be expanded for more flags)
int _getSortOrder(bool isComplete) {
  if (!isComplete) {
    return 0; // First group: incomplete statuses will come first.
  } else {
    return 1; // Second group: complete statuses will come later.
  }
}



Future<void> _saveExcel(BuildContext context) async {
  var excel = Excel.createExcel();  // Create a new Excel file
  Sheet sheetObject = excel['Sheet1'];  // Get the first sheet

  // Add header row (ensure you're using CellValue for each string)
  sheetObject.appendRow([
    'Applicant ID',
    'Applicant Name (Last Name, First Name, Middle Name)',
    'Handled By',
    'Payment Method',
    'Status',
    'Date Created',
  ]);

  // Add sample data to Excel (populate from your `filteredRequest`)
  for (var trackingData in filteredRequest) {
    final fullName = '${capitalizeEachWord(trackingData['db_admission_table']['last_name'])}, ${capitalizeEachWord(trackingData['db_admission_table']['first_name'])} ${capitalizeEachWord(trackingData['db_admission_table']['middle_name'])}';
    final processBy = trackingData['db_admission_table']['db_admission_form_handler_table'].isNotEmpty
        ? '${trackingData['db_admission_table']['db_admission_form_handler_table'][0]['db_admin_table']['first_name']} ${trackingData['db_admission_table']['db_admission_form_handler_table'][0]['db_admin_table']['last_name']}'
        : '---';

    String dateCreatedString = trackingData['db_admission_table']['created_at'];
    DateTime dateCreated = DateTime.parse(dateCreatedString);
    String formattedDate = formatDate(dateCreated);

    sheetObject.appendRow([
      trackingData['db_admission_table']['admission_form_id'].toString() ?? '',
      fullName ?? '',
      processBy ?? '',
      trackingData['db_admission_table']['db_payment_method_table']['payment_method'] ?? '',
      !trackingData['db_admission_table']['is_complete_view']
          ? trackingData['db_admission_table']['admission_status'].toString().toUpperCase()
          : "COMPLETE",
      formattedDate ?? ''
    ]);
  }

  // Convert the Excel file to bytes
  final excelBytes = excel.save()!;

  // Create a Blob from the byte array
  final blob = html.Blob([excelBytes]);

  // Create an anchor element to initiate the download
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..target = 'blank'
    ..download = 'payment.xlsx'; // Set the default file name

  // Trigger the click event to start the download
  anchor.click();

  // Revoke the object URL after download
  html.Url.revokeObjectUrl(url);

  // Show a SnackBar or a message that the file is saved
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Excel file downloaded successfully!')),
  );
}
 
}

