import 'package:cdbs_admin/bloc/admission_bloc/admission_bloc.dart';
import 'package:cdbs_admin/class/admission_forms.dart';
import 'package:cdbs_admin/shared/api.dart';
import 'package:cdbs_admin/widget/custom_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;

class PreEnrollmentPage2 extends StatefulWidget {

  List<Map<String, dynamic>>? formDetails;
  final Function(bool isClicked) onNextPressed;
  final int userId;
  final String adminType;
  PreEnrollmentPage2({super.key, required this.formDetails, required this.onNextPressed, required this.userId, required this.adminType});

  @override
  State<PreEnrollmentPage2> createState() => _PreEnrollmentPage2State();
}

class _PreEnrollmentPage2State extends State<PreEnrollmentPage2> {
  // List of states for green and red buttons per container
  final List<bool> _isGreenExpanded = List.generate(2, (_) => false);
  final List<bool> _isRedExpanded = List.generate(2, (_) => false);
  final List<bool> _isInvoiceDisabled = List.generate(2, (_) => false);

  bool isGreenExpanded=false;
  bool isRedExpanded=false;

  String? applicationId;
  String? fullName;
  String? status;
  String? dateCreatedString;
  String? formattedDate;
  String? docStatus;
  String? refNo;
  String encodedUrl = '';
  List<Map<String, dynamic>> myformDetails=[];

  @override
  void initState() {
    super.initState();
    myformDetails=widget.formDetails!;
    String originalUrl = '';
                  if (myformDetails[0]['db_admission_table']['db_payments_table'][0]['proof_of_payment'] != null) {
                    originalUrl = myformDetails[0]['db_admission_table']['db_payments_table'][0]['proof_of_payment'].substring(
                        2, myformDetails[0]['db_admission_table']['db_payments_table'][0]['proof_of_payment'].length - 2);
                  }
    encodedUrl = Uri.encodeFull(originalUrl);
    refNo= myformDetails[0]['db_admission_table']['db_payments_table'][0]['reference_number'] ?? '';
    applicationId = myformDetails[0]['db_admission_table']['admission_form_id'];
    fullName='${capitalizeEachWord(myformDetails[0]['db_admission_table']['first_name'])} ${capitalizeEachWord(myformDetails[0]['db_admission_table']['last_name'])}';
    status=myformDetails[0]['db_admission_table']['db_payments_table'][0]['status'];
    bool isPaid=false;
    if(status=='paid'){
      isPaid=true;
    }
    if(myformDetails[0]['db_admission_table']['db_payments_table'][0]['accepted_date']!=null){
      dateCreatedString = myformDetails[0]['db_admission_table']['db_payments_table'][0]['accepted_date'];
      DateTime dateCreated = DateTime.parse(dateCreatedString!);
      formattedDate = formatDate(dateCreated);
    }else{
      formattedDate='---';
    }

    if(isPaid){
      isGreenExpanded=true;
    }else{
      if(status=='rejected'){
        isRedExpanded=true;
      }else{
        isGreenExpanded=false;
        isRedExpanded=false;
      }
    }
  }

  Future<void> updateData(int admissionId) async {
      myformDetails = await ApiService(apiUrl).getReservationDetailsById(admissionId, supabaseUrl, supabaseKey);
      setState(() {
        status=myformDetails[0]['db_admission_table']['db_payments_table'][0]['status'];
        bool isPaid=false;
        if(status=='paid'){
          isPaid=true;
        }
        if(myformDetails[0]['db_admission_table']['db_payments_table'][0]['accepted_date']!=null){
          dateCreatedString = myformDetails[0]['db_admission_table']['db_payments_table'][0]['accepted_date'];
          DateTime dateCreated = DateTime.parse(dateCreatedString!);
          formattedDate = formatDate(dateCreated);
        }else{
          formattedDate='---';
        }

        if(isPaid){
          isGreenExpanded=true;
        }else{
          if(status=='rejected'){
            isRedExpanded=true;
          }else{
            isGreenExpanded=false;
            isRedExpanded=false;
          }
        }
      });
  }

  String formatDate(DateTime date) {
  // Convert the UTC date to local time
  DateTime localDate = date.toLocal();

  // Create a DateFormat object to format the date
  final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');

  // Return the formatted date in local time
  return formatter.format(localDate);
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double baseWidth = 400;
    double baseHeight = 800;
    double widthScale = screenWidth / baseWidth;
    double heightScale = screenHeight / baseHeight;
    double scale = widthScale < heightScale ? widthScale : heightScale;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Dynamic list of containers
          for (int i = 0; i < myformDetails.length; i++)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Second Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildInfoColumn(
                          label: 'Application ID',
                          value: applicationId!,
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 5,
                        child: _buildInfoColumn(
                          label: 'Applicant Name',
                          value: fullName!,
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildInfoColumn(
                          label: 'Grade Level',
                          value: myformDetails[0]['db_admission_table']['level_applying_for'],
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildInfoColumn(
                          label: 'Application Status',
                          value: status!.toUpperCase(),
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Green Check Button
                          if (!isRedExpanded)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: isGreenExpanded ? 99 : 47,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: widget.adminType=='Admin' || widget.adminType=='Principal' || widget.adminType=='Cashier' || widget.adminType=='IT' || widget.adminType=='Sisters'?() async {
                                  bool _isLoading=false;
                                  showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                  child: BlocConsumer<AdmissionBloc, AdmissionState>(
                                    listener: (context, state) {},
                                    builder: (context, state) {
                                       // Enable button based on the state
                                              if (state is AdmissionIsLoading) {
                                                _isLoading = state.isLoading;
                                              }
                                      return SizedBox(
                                                                      width: 349.0,
                                                                      height: 272.0,
                                                                      child: _isLoading
                                                              ? const CustomSpinner(
                                                                  color:
                                                                      Color(0xff13322b), // Change the spinner color if needed
                                                                  size: 60.0, // Change the size of the spinner if needed
                                                                ): Column(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          // Title
                                                                          const Padding(
                                                                            padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                                                                            child: Text(
                                                                              "Confirmation",
                                                                              style: TextStyle(
                                                                                fontFamily: 'Roboto',
                                                                                fontSize: 20,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                          ),
                                                                          // Content
                                                                          const Padding(
                                                                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                                                                            child: Text(
                                                                              "Are you sure you want to mark as complete?",
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
                                                                      onPressed: () async {
                                                                        if(status != 'paid'){
                                                                          context.read<AdmissionBloc>().add(IsLoadingClicked(true));
                                                                        try {
                                                                              final response = await http.post(
                                                                                Uri.parse('$apiUrl/api/admin/update_admission'),
                                                                                headers: {
                                                                                  'Content-Type': 'application/json',
                                                                                  'supabase-url': supabaseUrl,
                                                                                  'supabase-key': supabaseKey,
                                                                                },
                                                                                body: json.encode({
                                                                                  'admission_id': myformDetails[0]['db_admission_table']['admission_id'],
                                                                                  'user_id':widget.userId,
                                                                                  'is_done':true
                                                                                }),
                                                                              );
                                                                              
                                                                              
                                  
                                                                              if (response.statusCode == 200) {
                                                                                final responseBody = jsonDecode(response.body);
                                                                                context.read<AdmissionBloc>().add(IsLoadingClicked(false));
                                                                                updateData(myformDetails[0]['db_admission_table']['admission_id']);
                                                                                await http.post(
                                                                                    Uri.parse('$apiUrl/api/admin/update_payments'),
                                                                                    headers: {
                                                                                      'Content-Type': 'application/json',
                                                                                      'supabase-url': supabaseUrl,
                                                                                      'supabase-key': supabaseKey,
                                                                                    },
                                                                                    body: json.encode({
                                                                                      'admission_id': myformDetails[0]['db_admission_table']['admission_id'],
                                                                                      'status':'paid'
                                                                                    }),
                                                                                  );
                                                                                  setState(() {
                                                                                    isGreenExpanded = true;
                                                                                    isRedExpanded = false;
                                                                                    _isInvoiceDisabled[i] = false; // Enable invoice button
                                                                                  });
                                                                                showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) {
                                                                                    return Dialog(
                                                                                      shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                      ),
                                                                                      child: Container(
                                                                                        width: 349,
                                                                                        height: 272,
                                                                                        padding: const EdgeInsets.all(16),
                                                                                        child: Column(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                          children: [
                                                                                            Column(
                                                                                              children: [
                                                                                                Container(
                                                                                                  width: 90,
                                                                                                  height: 90,
                                                                                                  decoration: BoxDecoration(
                                                                                                    shape: BoxShape.circle,
                                                                                                    border: Border.all(color: const Color(0XFF012169), width: 2),
                                                                                                  ),
                                                                                                  child: const Center(
                                                                                                    child: Icon(
                                                                                                      Icons.check,
                                                                                                      color: Color(0XFF012169),
                                                                                                      size: 40,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                const SizedBox(height: 20),
                                                                                                // No Form Submitted Text
                                                                                                const Text(
                                                                                                  "Application Completed",
                                                                                                  style: TextStyle(
                                                                                                    fontSize: 20,
                                                                                                    fontWeight: FontWeight.bold,
                                                                                                  ),
                                                                                                  textAlign: TextAlign.center,
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                            // Divider
                                                                                            const Divider(
                                                                                              thickness: 1,
                                                                                              color: Colors.grey,
                                                                                            ),
                                                                                            // Close Button
                                                                                            Align(
                                                                                              alignment: Alignment.bottomCenter,
                                                                                              child: ElevatedButton(
                                                                                                onPressed: () {
                                                                                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                                                                                },
                                                                                                style: ElevatedButton.styleFrom(
                                                                                                  backgroundColor: const Color(0xff012169), // Button color
                                                                                                  shape: RoundedRectangleBorder(
                                                                                                    borderRadius: BorderRadius.circular(8),
                                                                                                  ),
                                                                                                  minimumSize: const Size(double.infinity, 50), // Expand width and set height
                                                                                                ),
                                                                                                child: const Text(
                                                                                                  "Close",
                                                                                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
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
                                                                        }else{
                                                                          showDialog(
                                                                                context: context,
                                                                                builder: (context) => AlertDialog(
                                                                                  title: const Text("Reminder"),
                                                                                  content: const Text("Payment already accepted."),
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
                                                                      },
                                                                      child: const Text(
                                                                        "Yes",
                                                                        style: TextStyle(color: Colors.white),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                  
                                                            ],
                                                          ),
                                                        );
                                    },
                                  ),
                    ),
                  );
                                }:null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                          // Space between buttons
                          if (!isGreenExpanded)
                            const SizedBox(width: 2),

                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Third Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildInfoColumn(
                          label: 'Reference No: ',
                          value: refNo!,
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildInfoColumn(
                          label: 'Payment Type',
                          value: 'Reservation Fee',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Total Amount',
                          value: '3,000.00',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildInfoColumn(
                          label: 'Payment Method',
                          value: myformDetails[0]['db_admission_table']['db_payments_table'][0]['pay_method_id']==1?'Over the Counter':'Online Payment',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildInfoColumn(
                          label: 'Date Paid',
                          value: formattedDate!,
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const SizedBox(
                        width: 50,
                        height: 37),
                     
                    ],
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                              onPressed: encodedUrl.isNotEmpty
                                  ? () async {
                                      // Ensure imagePath is a valid URL

                                      // Use the browser's built-in window.open method
                                      try {
                                        html.window.open(encodedUrl,
                                            '_blank'); // Open URL in a new tab
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Could not open the link')),
                                        );
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff012169),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: const Text(
                                "View proof of payment",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn({
    required String label,
    required String value,
    required double scale,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11 * scale,
                fontFamily: 'Roboto-R',
              ),
            ),
            const SizedBox(width: 30),
            Text(
              value,
              style: TextStyle(
                fontSize: 12 * scale,
                fontFamily: 'Roboto-B',
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 1,
          color: const Color(0xFF909590),
        ),
      ],
    );
  }
}
