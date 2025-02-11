//RESULTS PAGE2


import 'dart:ui';

import 'package:cdbs_admin/class/admission_forms.dart';
import 'package:cdbs_admin/shared/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Name of your class
class AdmissionResultsPage2 extends StatefulWidget {

  List<Map<String, dynamic>>? formDetails;
  final Function(bool isClicked, bool isResult, bool isPassed) onNextPressed;
  int userId;

  AdmissionResultsPage2({super.key, required this.formDetails, required this.onNextPressed, required  this.userId});

  @override
  State<AdmissionResultsPage2> createState() =>
      _AdmissionResultsPage2State();
}

class _AdmissionResultsPage2State extends State<AdmissionResultsPage2> {
  TextEditingController rejectController = TextEditingController();

  String? applicationId;
  String? fullName;
  String? status;
  String? dateCreatedString;
  String? formattedDate;
  String? docStatus;
  bool? selectedStatus;
  bool isComplete=false;
  bool isResult=false;
  bool isPassed=false;

  List<Map<String, dynamic>> myformDetails=[];

  @override
  void initState() {
    super.initState();
    myformDetails=widget.formDetails!;
    applicationId = myformDetails[0]['db_admission_table']['admission_form_id'];
    fullName='${myformDetails[0]['db_admission_table']['first_name']} ${myformDetails[0]['db_admission_table']['last_name']}';
    status=myformDetails[0]['db_admission_table']['admission_status'];
    dateCreatedString = myformDetails[0]['db_admission_table']['created_at'];
    DateTime dateCreated = DateTime.parse(dateCreatedString!);
    formattedDate = formatDate(dateCreated);
  }

  Future<void> updateData(int admissionId) async  {
    myformDetails = await ApiService(apiUrl).getFormsDetailsById(admissionId, supabaseUrl, supabaseKey);
  }

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');
    return formatter.format(date);
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
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 40),
      // First Row
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Application ID
          Expanded(
            flex: 3,
            child: _buildInfoColumn(
              label: "Application ID",
              value: applicationId!,
              scale: scale,
            ),
          ),
          const SizedBox(width: 16),

          // Applicant Name
          Expanded(
            flex: 5,
            child: _buildInfoColumn(
              label: 'Applicant Name',
              value: fullName!,
              scale: scale,
            ),
          ),
          const SizedBox(width: 16),

          // Grade Level
          Expanded(
            flex: 2,
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
    label: 'Date Created',
    value: formattedDate!,
    scale: scale,
  ),
),

          const SizedBox(width: 16),

          // Application Status
SizedBox(
  width: 200,
  height: 70,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Application Status',
            style: TextStyle(fontSize: 11 * scale),
          ),
         DropdownButton<bool>(
            value: selectedStatus, // Default value bound to a variable
            items: const [
              DropdownMenuItem(
                value: true,
                child: Text(
                  'PASSED',
                  style: TextStyle(color: Colors.green),
                ),
              ),
              DropdownMenuItem(
                value: false,
                child: Text(
                  'FAILED',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                
                setState(() {
                  selectedStatus = value;
                  isComplete=true;
                  isResult=true;
                  isPassed=selectedStatus!;
                  widget.onNextPressed(isComplete, isResult, isPassed);
                });
                // Update the state with the selected status
                
              }
            },
            underline: const SizedBox.shrink(), // Removes the bottom outline
            dropdownColor: Colors.white, // Set dropdown background to white
            focusColor: Colors.transparent,
            style: const TextStyle(
              backgroundColor: Colors.transparent, // Ensures no background in text
              fontSize: 12,
            ),
          ),
         
        ],
      ),
      Container(
        height: 1,
        color: const Color(0xff909590), // Outline below the entire row
      ),
    ],
  ),
),





const SizedBox(width: 40,),

        ],
      ),
      const SizedBox(height: 16), // Space between rows

      // Second Row

      // const SizedBox(height: 80),
      // const Divider(),

      // // Attached Documents Header
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //   children: [
      //     Text(
      //       'Attached Document/s',
      //       style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-R'),
      //     ),
      //   ],
      // ),

      const SizedBox(height: 40), // Space before images

      // Row of Images
      
    ],
  ),
);
  }

  // Helper method to create the individual information column
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
          color: const Color(0xFF909590), // Underline color
        ),
      ],
    );
  }

  // Helper method to create image cards
 /* Widget _buildImageCard({
    String? imagePath,
    required String label,
    required double scale,
    bool isPlaceholder = false,
    bool isDashedLine = false,
  }) {
    return GestureDetector(
      onTap: () => _showImageDialog(imagePath), // Open dialog on tap
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 158,
            height: 89,
            child: isDashedLine
                ? CustomPaint(
                    painter: DashedBorderPainter(),
                    child: Center(
                      child: isPlaceholder
                          ? Text(
                              "No Image",
                              style: TextStyle(
                                fontSize: 10 * scale,
                                color: Colors.grey,
                              ),
                            )
                          : null,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(5), // Image radius
                    child: Image.asset(
                      imagePath!,
                      width: 158,
                      height: 89,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
          const SizedBox(height: 8), // Space between image and text
          Text(
            label,
            style: TextStyle(
              fontSize: 11 * scale,
              fontFamily: 'Roboto-R',
            ),
            textAlign: TextAlign.left, // Align text to the left
          ),
        ],
      ),
    );
  }*/

 /* Widget _buildImageCard({
  String? imagePath,
  int? id,
  int? admissionId,
  String? status,
  required String label,
  required double scale,
  bool isPlaceholder = false,
  bool isDashedLine = false,
  required StateSetter setState
}) {
  return GestureDetector(
    onTap: () {
      _showImageDialog(imagePath, id!, admissionId!);
      print(imagePath);
    }, // Open dialog on tap
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 158,
          height: 89,
          child: isDashedLine
              ? CustomPaint(
                  painter: DashedBorderPainter(),
                  child: Center(
                    child: isPlaceholder
                        ? Text(
                            "No Image",
                            style: TextStyle(
                              fontSize: 10 * scale,
                              color: Colors.grey,
                            ),
                          )
                        : null,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(5), // Image radius
                  child: imagePath != null
                      ? Image.network(
                          imagePath,
                          width: 158,
                          height: 89,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text(
                                "Failed to load image",
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            "No Image",
                            style: TextStyle(
                              fontSize: 10 * scale,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
        ),
        const SizedBox(height: 8), // Space between image and text
        Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11 * scale,
                fontFamily: 'Roboto-R',
              ),
              textAlign: TextAlign.left, // Align text to the left
            ),
            Text(status!!='pending'?status.toUpperCase():'',
              style: TextStyle(
                fontSize: 11 * scale,
                fontFamily: 'Roboto-R',
              ),
              textAlign: TextAlign.left, // Align text to the left
            )
          ],
        ),
      ],
    ),
  );
}*/



  // Show image dialog when image is clicked
 /* void _showImageDialog(String? imagePath, int id, int admissionId, String docStatus, List<Map<String, dynamic>> formRequirements, String gradeLevel) {

    bool isComplete=false;
    bool isResult=false;
    bool isPassed=false;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          width: 550,
          height: 900,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: imagePath!,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: Center(
                        child: SpinKitCircle(
                          color: Color(0xff012169), // Customize color
                          size: 50.0,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed:  docStatus=='pending'?() async {
                            // Handle accept action
                            try {
                              final response = await http.post(
                                Uri.parse('$apiUrl/api/admin/update_required_form'),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'supabase-url': supabaseUrl,
                                  'supabase-key': supabaseKey,
                                },
                                body: json.encode({
                                  'document_status': 'accepted',
                                  'required_doc_id': id,
                                  'reject_reason': '',
                                }),
                              );

                              if (response.statusCode == 200) {
                                final responseBody = jsonDecode(response.body);
                                setState(() {
                                  updateData(admissionId);
                                  
                                });
                                // Show success modal
                                Navigator.of(context).popUntil((route) => route.isFirst);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Success"),
                                    content: const Text("The review has been marked as complete."),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          
                                          widget.onNextPressed(isComplete, isResult, isPassed);
                                          Navigator.of(context).pop(); // Close dialog
                                        },
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                // Handle failure
                                final responseBody = jsonDecode(response.body);
                                print('Error: ${responseBody['error']}');
                                Navigator.of(context).pop();
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Error"),
                                    content: Text("Failed to complete review: ${responseBody['error']}"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close dialog
                                        },
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } catch (error) {
                              // Handle network error
                              print('Error: $error');
                              Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Error"),
                                  content: const Text("An unexpected error occurred. Please try again later."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close dialog
                                      },
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              );
                            }
                          }:null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                  const SizedBox(width: 2),
                  ElevatedButton(
                    onPressed: docStatus=='pending'?() {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Reject"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("Please provide a reason for rejection:"),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: rejectController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: "Enter rejection reason",
                                  ),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close dialog
                                },
                                child: const Text("Close"),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  // Handle rejection submission
                                  try {
                                    final response = await http.post(
                                      Uri.parse('$apiUrl/api/admin/update_required_form'),
                                      headers: {
                                        'Content-Type': 'application/json',
                                        'supabase-url': supabaseUrl,
                                        'supabase-key': supabaseKey,
                                      },
                                      body: json.encode({
                                        'document_status': 'rejected',
                                        'required_doc_id': id,
                                        'reject_reason': rejectController.text,
                                      }),
                                    );

                                    if (response.statusCode == 200) {
                                      final responseBody = jsonDecode(response.body);
                                      setState(() {
                                        updateData(admissionId);
                                      });
                                      // Show success modal
                                      Navigator.of(context).popUntil((route) => route.isFirst);
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Rejected"),
                                          content: const Text("The review has been marked as rejected."),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                          widget.onNextPressed(isComplete, isResult, isPassed);
                                                Navigator.of(context).pop(); // Close dialog
                                              },
                                              child: const Text("OK"),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      // Handle failure
                                      final responseBody = jsonDecode(response.body);
                                      print('Error: ${responseBody['error']}');
                                      Navigator.of(context).pop();
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Error"),
                                          content: Text("Failed to complete review: ${responseBody['error']}"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close dialog
                                              },
                                              child: const Text("OK"),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  } catch (error) {
                                    // Handle network error
                                    print('Error: $error');
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Error"),
                                        content: const Text("An unexpected error occurred. Please try again later."),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(); // Close dialog
                                            },
                                            child: const Text("OK"),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text("Submit"),
                              ),
                            ],
                          );
                        },
                      );
                    }:null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
*/

}

// Custom painter for dashed border
class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(5),
      ));

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const double dashWidth = 5.0;
    const double dashSpace = 5.0;
    double distance = 0.0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        final double nextDash = distance + dashWidth;
        final double nextSpace = nextDash + dashSpace;
        final Tangent tangent = pathMetric.getTangentForOffset(distance) ?? const Tangent(Offset.zero, Offset.zero);

        canvas.drawLine(
          tangent.position,
          tangent.position + tangent.vector * dashWidth,
          paint,
        );

        distance = nextSpace;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
