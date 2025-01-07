import 'package:cdbs_admin/shared/api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdmissionSchedulesPage2 extends StatefulWidget {
  List<Map<String, dynamic>>? formDetails;
  final Function(bool isClicked) onNextPressed;
  int userId;

  AdmissionSchedulesPage2({super.key, required this.formDetails, required this.onNextPressed, required this.userId});

  @override
  State<AdmissionSchedulesPage2> createState() => _AdmissionSchedulesPage2State();
}

class _AdmissionSchedulesPage2State extends State<AdmissionSchedulesPage2> {

  String? dateCreatedString;
  DateTime? dateCreated;
  String? formattedDate;

  String? examDate;
  DateTime? dateExam;
  String? formattedExamDate;



  @override
  void initState() {
    super.initState();
    // Initialize the service with your endpoint
     dateCreatedString = widget.formDetails![0]['create_at'];
     dateCreated = DateTime.parse(dateCreatedString!);
     formattedDate = formatDate(dateCreated!);

     examDate = widget.formDetails![0]['exam_date'];
     dateExam = DateTime.parse(examDate!);
     formattedExamDate = formatDate(dateExam!);
  }


  String formatDate(DateTime date) {
    final DateTime localDate = date.toLocal(); // Converts to local time zone

  final DateFormat formatter = DateFormat('dd-MM-yyyy');
  return formatter.format(localDate);
  }

  bool isExamToday(String dateExam) {
    // Get today's date and format it
    final String today = formatDate(DateTime.now());
    // Compare if today is the same as the exam date
    return today == dateExam;
  }


  String formatTime(String time) {
  // Parse the time string into a DateTime object. 
  // For example, "8:00" should be parsed into a DateTime object with 12:00 AM
  final DateTime parsedTime = DateFormat('HH:mm').parse(time);

  // Format the DateTime object into a 12-hour format with AM/PM
  final DateFormat formatter = DateFormat('hh a'); // 'hh' for 12-hour format, 'a' for AM/PM
  
  // Return formatted time
  return formatter.format(parsedTime);  // Format the DateTime object to time only
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

      final List<bool> isGreenExpanded = List.generate(widget.formDetails![0]['db_exam_admission_schedule'].length, (_) => false);
      final List<bool> isRedExpanded = List.generate(widget.formDetails![0]['db_exam_admission_schedule'].length, (_) => false);
    final List<bool> isInvoiceDisabled = List.generate(widget.formDetails![0]['db_exam_admission_schedule'].length, (_) => false);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 60),

          Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // Second Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Exam Date',
                          value: formattedExamDate!,
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Exam Time',
                          value: '${formatTime(widget.formDetails![0]['start_time'])} - ${formatTime(widget.formDetails![0]['end_time'])}',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Meeting Place',
                          value: widget.formDetails![0]['location'],
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Grade Level',
                          value: widget.formDetails![0]['grade_level'],
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: _buildInfoColumn(
                          label: 'Slots',
                          value: '2/10',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Date Created',
                          value: formattedDate!,
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 99,
                        height: 37,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle button press
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff012169),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text(
                            'View',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),







            const SizedBox(height: 40),

          // Three Copies of Rows in Containers
          /*for (int i = 0; i < 2; i++) 
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // Second Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Application ID',
                          value: '9741',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildInfoColumn(
                          label: 'Applicant Name',
                          value: 'Lazarus Ains',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: _buildInfoColumn(
                          label: 'Grade Level',
                          value: '11',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: _buildInfoColumn(
                          label: 'Application Status',
                          value: 'REQUIREMENTS - IN REVIEW',
                          scale: scale,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const SizedBox(
                        width: 99,),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Third Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 220,
                        child: _buildInfoColumn(
                          label: 'Date Created',
                          value: '2024-11-20',
                          scale: scale,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),*/


            SizedBox(
              height: 500,
              width: 1500,
              child: ListView.builder(
                itemCount: widget.formDetails![0]['db_exam_admission_schedule'].length,
                itemBuilder: (context, i) {
                  // You can access your data here like this:
                  var admissionSchedule = widget.formDetails![0]['db_exam_admission_schedule'][i];
                  String admissionCreated = admissionSchedule['db_admission_table']['created_at'];
                  DateTime admissionDate = DateTime.parse(admissionCreated);
                  String formattedAdmissionDate = formatDate(admissionDate);
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        // Second Row
                        Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 4,
                  child: _buildInfoColumn(
                    label: 'Application ID',
                    value: admissionSchedule['admission_id'].toString() ?? 'N/A', // Example, adjust according to your data
                    scale: scale,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 10,
                  child: _buildInfoColumn(
                    label: 'Applicant Name',
                    value: '${admissionSchedule['db_admission_table']['first_name']} ${admissionSchedule['db_admission_table']['last_name']}', // Example, adjust according to your data
                    scale: scale,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: _buildInfoColumn(
                    label: 'Grade Level',
                    value: admissionSchedule['db_admission_table']['level_applying_for'] ?? 'N/A', // Example, adjust according to your data
                    scale: scale,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 6,
                  child: _buildInfoColumn(
                    label: 'Application Status',
                    value: admissionSchedule['db_admission_table']['admission_status'].toUpperCase() ?? 'N/A', // Example, adjust according to your data
                    scale: scale,
                  ),
                ),
                const SizedBox(width: 16),
                                        Expanded(
                          flex: 6,
                          child: _buildInfoColumn(
                            label: 'Date Created',
                            value: formattedAdmissionDate ?? 'N/A', // Example, adjust according to your data
                            scale: scale,
                          ),
                        ),
                const SizedBox(width: 16),
                 if(isExamToday(formattedExamDate!))
                 Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Green Check Button
                          if (!isRedExpanded[i])
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: isGreenExpanded[i] ? 99 : 44,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                            final response = await http.post(
                                              Uri.parse('$apiUrl/api/admin/update_admission'),
                                              headers: {
                                                'Content-Type': 'application/json',
                                                'supabase-url': supabaseUrl,
                                                'supabase-key': supabaseKey,
                                              },
                                              body: json.encode({
                                                'admission_id': admissionSchedule['db_admission_table']['admission_id'],  
                                                'user_id':widget.userId,
                                                'is_assessment':true,
                                                'is_attended':true
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
                                },
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
                          if (!isGreenExpanded[i])
                            const SizedBox(width: 2),

                          // Red X Button
                          if (!isGreenExpanded[i])
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: isRedExpanded[i] ? 99 : 44,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: ()async {
                                  try {
                                            final response = await http.post(
                                              Uri.parse('$apiUrl/api/admin/update_admission'),
                                              headers: {
                                                'Content-Type': 'application/json',
                                                'supabase-url': supabaseUrl,
                                                'supabase-key': supabaseKey,
                                              },
                                              body: json.encode({
                                                'admission_id': admissionSchedule['db_admission_table']['admission_id'],  
                                                'user_id':widget.userId,
                                                'is_assessment':false,
                                                'is_attended':false,
                                                'admission_status':'pending'
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

                                  setState(() {
                                    isRedExpanded[i] = true;
                                    isGreenExpanded[i] = false;
                                    isInvoiceDisabled[i] = true; // Disable invoice button
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ), // This could still be removed if unnecessary
              ],
                        ),
                        const SizedBox(height: 16),
              
                        // Third Row (Date Created)

                      ],
                    ),
                  );
                },
              ),
            ),

             Row(
  mainAxisAlignment: MainAxisAlignment.start, // Aligns the content to the left
  crossAxisAlignment: CrossAxisAlignment.center, // Aligns text and icon vertically
  children: [
    const Text(
      'Reschedule ',
      style: TextStyle(
        fontSize: 14, // Adjust the font size as needed
        fontWeight: FontWeight.bold,
      ),
    ),
    Text(
      widget.formDetails![0]['db_exam_admission_schedule'].length.toString(), // Display the number of applications
      style: const TextStyle(
        fontSize: 14,
      ),
    ),
    const SizedBox(width: 4), // Space between text and icon
    const Icon(
      Icons.keyboard_arrow_down, // Down arrow icon
      size: 20, // Adjust size as needed
    ),
  ],
)


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
