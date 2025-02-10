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


  List<Map<String, dynamic>> cancelledSchedules = [];
  List<Map<String, dynamic>> activeSchedules = [];



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

     for (var schedule in widget.formDetails![0]['db_exam_admission_schedule']) {
      if (schedule['schedule_status'] == 'cancelled') {
        cancelledSchedules.add(schedule);
      } else {
        activeSchedules.add(schedule);
        
      }
    }


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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),

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
                        child: _buildInfoColumn2(
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







            const SizedBox(height: 15),

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

            Text(
              'APPLICANT (${activeSchedules.length}) ',
              style: const TextStyle(
                fontSize: 14, // Adjust the font size as needed
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 300,
              width: 1500,
              child: ListView.builder(
                itemCount: activeSchedules.length,
                itemBuilder: (context, i) {
                  // You can access your data here like this:
                  activeSchedules.sort((a, b) {
                    // If schedule_status is null, prioritize it to the top
                    if (a['schedule_status'] == null && b['schedule_status'] != null) {
                      return -1; // a comes before b
                    }
                    if (a['schedule_status'] != null && b['schedule_status'] == null) {
                      return 1; // b comes before a
                    }

                    // If schedule_status is "cancelled", prioritize it to the bottom
                    if (a['schedule_status'] == 'cancelled' && b['schedule_status'] != 'cancelled') {
                      return 1; // a comes after b
                    }
                    if (a['schedule_status'] != 'cancelled' && b['schedule_status'] == 'cancelled') {
                      return -1; // b comes after a
                    }

                    // If both are the same (either both null or both "cancelled"), keep original order
                    return 0;
                  });
                  var admissionSchedule = activeSchedules[i];
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
                  flex: 8,
                  child: _buildInfoColumn(
                    label: 'Applicant Name',
                    value: '${admissionSchedule['db_admission_table']['first_name']} ${admissionSchedule['db_admission_table']['last_name']}', // Example, adjust according to your data
                    scale: scale,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: _buildInfoColumn(
                    label: 'Grade Level',
                    value: admissionSchedule['db_admission_table']['level_applying_for'] ?? 'N/A', // Example, adjust according to your data
                    scale: scale,
                  ),
                ),
                const SizedBox(width: 16),
                admissionSchedule['schedule_status']!='cancelled'?Expanded(
                  flex: 6,
                  child: _buildInfoColumn(
                    label: 'Application Status',
                    value: admissionSchedule['db_admission_table']['admission_status'].toUpperCase() ?? 'N/A', // Example, adjust according to your data
                    scale: scale,
                  ),
                ):const SizedBox(),
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
                 admissionSchedule['schedule_status']!='cancelled'?Row(
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
                      ):
                      
                      Expanded(
                        flex: 9,
                        child: _buildInfoColumn(
                          label: 'Cancel Reason',
                          value: admissionSchedule['schedule_cancel_reason'] ??'', // Example, adjust according to your data
                          scale: scale,
                        ),
                      ) // This could still be removed if unnecessary
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

              const SizedBox(height: 15),
             Row(
  mainAxisAlignment: MainAxisAlignment.start, // Aligns the content to the left
  crossAxisAlignment: CrossAxisAlignment.center, // Aligns text and icon vertically
  children: [
     Text(
      'RESCHEDULE (${cancelledSchedules.length})',
      style:const TextStyle(
        fontSize: 14, // Adjust the font size as needed
        fontWeight: FontWeight.bold,
      ),
    ),
    const SizedBox(width: 4), // Space between text and icon
    const Icon(
      Icons.keyboard_arrow_down, // Down arrow icon
      size: 20, // Adjust size as needed
    ),
  ],
),

            SizedBox(
              height: 300,
              width: 1500,
              child: ListView.builder(
                itemCount: cancelledSchedules.length,
                itemBuilder: (context, i) {
                  // You can access your data here like this:
                  activeSchedules.sort((a, b) {
                    // If schedule_status is null, prioritize it to the top
                    if (a['schedule_status'] == null && b['schedule_status'] != null) {
                      return -1; // a comes before b
                    }
                    if (a['schedule_status'] != null && b['schedule_status'] == null) {
                      return 1; // b comes before a
                    }

                    // If schedule_status is "cancelled", prioritize it to the bottom
                    if (a['schedule_status'] == 'cancelled' && b['schedule_status'] != 'cancelled') {
                      return 1; // a comes after b
                    }
                    if (a['schedule_status'] != 'cancelled' && b['schedule_status'] == 'cancelled') {
                      return -1; // b comes after a
                    }

                    // If both are the same (either both null or both "cancelled"), keep original order
                    return 0;
                  });
                  var admissionSchedule = cancelledSchedules[i];
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
                  flex: 8,
                  child: _buildInfoColumn(
                    label: 'Applicant Name',
                    value: '${admissionSchedule['db_admission_table']['first_name']} ${admissionSchedule['db_admission_table']['last_name']}', // Example, adjust according to your data
                    scale: scale,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: _buildInfoColumn(
                    label: 'Grade Level',
                    value: admissionSchedule['db_admission_table']['level_applying_for'] ?? 'N/A', // Example, adjust according to your data
                    scale: scale,
                  ),
                ),
                const SizedBox(width: 16),
                admissionSchedule['schedule_status']!='cancelled'?Expanded(
                  flex: 6,
                  child: _buildInfoColumn(
                    label: 'Application Status',
                    value: admissionSchedule['db_admission_table']['admission_status'].toUpperCase() ?? 'N/A', // Example, adjust according to your data
                    scale: scale,
                  ),
                ):const SizedBox(),
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
                 admissionSchedule['schedule_status']!='cancelled'?Row(
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
                      ):
                      
                      Expanded(
                        flex: 9,
                        child: _buildInfoColumn(
                          label: 'Cancel Reason',
                          value: admissionSchedule['schedule_cancel_reason'] ??'', // Example, adjust according to your data
                          scale: scale,
                        ),
                      ) // This could still be removed if unnecessary
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
                overflow: TextOverflow.ellipsis,
                maxLines:1
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



  Widget _buildInfoColumn2({
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
          // Wrap the Text widget in a MouseRegion to detect hover and show a popup (tooltip)
          MouseRegion(
            onEnter: (_) {
              // You can define actions on hover if needed
            },
            onExit: (_) {
              // You can define actions on hover exit if needed
            },
            child: Tooltip(
              message: value, // The full value will be shown when hovering
              padding: const EdgeInsets.all(8.0), // Adjust padding around the tooltip
              decoration: BoxDecoration(
                color: const Color(0xff012169),
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 11 * scale,
                fontFamily: 'Roboto-B',
              ),
              child: Container(
                width: 85,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12 * scale,
                    fontFamily: 'Roboto-B',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
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
