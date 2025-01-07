import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cdbs_admin/class/admission_forms.dart';
import 'package:cdbs_admin/shared/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;



// Name of your class
class AdmissionRequirementsPage2 extends StatefulWidget {

  List<Map<String, dynamic>>? formDetails;
  final Function(bool isClicked) onNextPressed;

  AdmissionRequirementsPage2({super.key, required this.formDetails, required this.onNextPressed});

  @override
  State<AdmissionRequirementsPage2> createState() =>
      _AdmissionRequirementsPage2State();
}

class _AdmissionRequirementsPage2State extends State<AdmissionRequirementsPage2> {
  TextEditingController rejectController = TextEditingController();

  String? applicationId;
  String? fullName;
  String? status;
  String? dateCreatedString;
  String? formattedDate;
  String? docStatus;

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
            flex: 2,
            child: _buildInfoColumn(
              label: "Application ID",
              value: applicationId!,
              scale: scale,
            ),
          ),
          const SizedBox(width: 16),

          // Applicant Name
          Expanded(
            flex: 3,
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

          // Application Status
          Expanded(
            flex: 2,
            child: _buildInfoColumn(
              label: 'Application Status',
              value: status!.toUpperCase(),
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
        ],
      ),


      // Second Row

      const SizedBox(height: 80),
      const Divider(),

      // Attached Documents Header
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Attached Document/s',
            style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-R'),
          ),
        ],
      ),

      const SizedBox(height: 40), // Space before images

      // Row of Images
      Wrap(
        alignment: WrapAlignment.start,
        spacing: 20,
        runSpacing: 20,
        children: [

          if (myformDetails.isNotEmpty)
            ...myformDetails[0]['db_admission_table']['db_required_documents_table']
                .map<Widget>((document) {
              // Check if the document has a document_url
              if (document != null && document['document_url'] != null) {
                String originalUrl = document['document_url'].substring(2, document['document_url'].length - 2);
                String encodedUrl = Uri.encodeFull(originalUrl);
                docStatus=document['document_status'];
                return _buildImageCard(
                  imagePath: encodedUrl, // Use document_url
                  id:document['required_doc_id'],
                  status: docStatus,
                  label:  document['db_requirement_type_table']['doc_type'], // Default label if not provided
                  scale: scale,
                  setState: setState,
                  admissionId: document['admission_id'],
                  formRequirements: List<Map<String, dynamic>>.from(
                    myformDetails[0]['db_admission_table']['db_required_documents_table']
                  ),
                  gradeLevel: myformDetails[0]['db_admission_table']['level_applying_for']
                );
              } else {
                // If no document_url is provided, show a placeholder
                return _buildImageCard(
                  label:  'Image is not Available', // Display document name
                  id:document['required_doc_id'],
                  status: docStatus,
                  scale: scale,
                  isPlaceholder: true,
                  isDashedLine: true, // Dashed border for placeholder
                  setState: setState,
                  admissionId: document['admission_id'],
                  formRequirements: List<Map<String, dynamic>>.from(
                    myformDetails[0]['db_admission_table']['db_required_documents_table']
                  ),
                  gradeLevel: myformDetails[0]['db_admission_table']['level_applying_for']
                );
              }
            }).toList(),
         /* _buildImageCard(
            imagePath: 'assets/q4.jpg',
            label: '*Birth Certificate (PSA Copy)',
            scale: scale,
          ),
          _buildImageCard(
            imagePath: 'assets/q2.jpg',
            label: '*Recent ID Photo',
            scale: scale,
          ),
          _buildImageCard(
            imagePath: 'assets/q3.jpg',
            label: '*Parent Questionnaire',
            scale: scale,
          ),
          _buildImageCard(
            imagePath: 'assets/q4.jpg',
            label: 'Baptismal Certificate',
            scale: scale,
          ),
          _buildImageCard(
            label: 'First Communion Certificate',
            scale: scale,
            isPlaceholder: true,
            isDashedLine: true, // Dashed border for placeholder
          ),
          _buildImageCard(
            label: 'Parent’s Marriage Certificate',
            scale: scale,
            isPlaceholder: true,
            isDashedLine: true, // Dashed border for placeholder
          ),*/
        ],
      ),
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


Widget _buildImageCard({
  String? imagePath,
  int? id,
  int? admissionId,
  String? status,
  required String label,
  required double scale,
  bool isPlaceholder = false,
  bool isDashedLine = false,
  required StateSetter setState,
  required List<Map<String, dynamic>> formRequirements,
  String? gradeLevel
}) {
  // Determine the color for the status circle
  Color statusColor = Colors.transparent;
  if (status == 'accepted') {
    statusColor = Colors.green;
  } else if (status == 'rejected') {
    statusColor = Colors.red;
  } // Default is transparent for 'pending'

  bool isPdf = imagePath != null && imagePath.toLowerCase().endsWith('.pdf');

  return GestureDetector(
    onTap: () {
      _showImageDialog(imagePath, id!, admissionId!, status!, formRequirements, gradeLevel!);
    }, // Open dialog on tap
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 158,
          height: 89,
          child: Stack(
            clipBehavior: Clip.none,  // Allow content to overflow out of the Stack
            children: [
              // Image or placeholder
              isDashedLine
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
                                return  Center(
                                  child:  Column(
                                    children: [
                                      const Text(
                                    "Failed to load image",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () async {
                                          /*final Uri url = Uri.parse(imagePath); // Convert string to Uri
                                                
                                          try {
                                              if (Foundation.kIsWeb) {
                                                // Web-specific launch
                                                await launchUrl(url);
                                              } else {
                                                // Mobile-specific launch (use the older method for mobile platforms)
                                                await launch(url.toString());
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Could not open the link')),
                                              );
                                            }*/
                                            final String url = imagePath; // Ensure imagePath is a valid URL

                                              // Use the browser's built-in window.open method
                                              try {
                                                html.window.open(url, '_blank');  // Open URL in a new tab
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Could not open the link')),
                                                );
                                              }                                            
                                      
                                        },
                                        child: const Text(
                                          "Open Link",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
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
              // Status circle in the upper-right corner (floating above the image)
              Positioned(
                top: -4,  // Move it slightly outside the image (top)
                right: -4, // Move it slightly outside the image (right)
                child: CircleAvatar(
                  radius: 10,  // Larger radius for the floating effect
                  backgroundColor: statusColor,
                ),
              ),
            ],
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
          ],
        ),
      ],
    ),
  );
}

bool checkDocumentRequirements(String gradeLevel, List<Map<String, dynamic>> formRequirements) {
    // Define the list of required doc_ids based on the grade level
    List<int> requiredDocIds;

    // Check the gradeLevel and set the required doc_ids accordingly
    if (gradeLevel.toLowerCase() == 'pre-kinder' || gradeLevel.toLowerCase() == 'kinder') {
      requiredDocIds = [1, 2, 4]; // For 'pre-kinder' or 'kinder', require doc_ids 1, 2, and 4
    } else {
      requiredDocIds = [1, 2, 3, 5]; // For other grade levels, require doc_ids 1, 2, 3, and 5
    }
    
    // Loop through the required doc_ids
    for (int docId in requiredDocIds) {
      bool docFound = false;
      
      // Check if each doc_id (from requiredDocIds) is in the formRequirements and has 'accepted' status
      for (var requirement in formRequirements) {
        if (requirement['db_requirement_type_table'] != null) {
          var requirementDocId = requirement['db_requirement_type_table']['doc_id'];
          var documentStatus = requirement['document_status'];
          
          // If we find the document with the required doc_id and 'accepted' status, mark it as found
          if (requirementDocId == docId && documentStatus == 'accepted') {
            docFound = true;
            break; // No need to check further for this docId, move on to the next docId
          }
        }
      }
      
      // If any required document (from requiredDocIds) is missing or not 'accepted', return false
      if (!docFound) {
        return false; // Exit early, because we found a missing or not accepted document
      }
    }
    
    // If all required docs (1, 2, 3, 4, or 5) are found with 'accepted' status, return true
    return true;
  }


  // Show image dialog when image is clicked
  void _showImageDialog(String? imagePath, int id, int admissionId, String docStatus, List<Map<String, dynamic>> formRequirements, String gradeLevel) {

    bool isComplete=false;
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
                          color: Color(0xff13322B), // Customize color
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
                    onPressed:  docStatus=='pending'?() {
                            // Handle accept action
                            
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
      onPressed: () async {
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
                                  checkDocumentRequirements(gradeLevel, List<Map<String, dynamic>>.from(
                    myformDetails[0]['db_admission_table']['db_required_documents_table']
                  ));
                                });
                                // Show success modal
                                Navigator.of(context).popUntil((route) => route.isFirst);
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
              // Centered Text
              const Center(
                // child: Text(
                //   "",
                //   style: TextStyle(
                //     fontSize: 20,
                //   ),
                //   textAlign: TextAlign.center,
                // ),
              ),
              // Red X Icon with Circular Outline
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
                    "Attached Documents has beeen Accepted!",
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
                    Navigator.of(context).pop(); // Close the modal
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
                            } // Close dialog
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
    ),
  ),
);

                              
                          }:null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff007937),
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                    ),
                    child: const Text('Accept', style: TextStyle(color: Colors.white),),
                  ),
                  const SizedBox(width: 2),
                  ElevatedButton(
                    onPressed: docStatus=='pending'?() {
                      showDialog(
  context: context,
  builder: (context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: SizedBox(
        width: 349.0,
        height: 320.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Reject",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
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
            ),
            const Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Divider(thickness: 1),
          ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  // Close button on the first row
                  SizedBox(
                    width: double.infinity,
                    height: 35,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xffD3D3D3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                      },
                      child: const Text(
                        "Close",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Spacer between the buttons
                  // Submit button on the second row
                  SizedBox(
                    width: double.infinity,
                    height: 35,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff012169),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        // Handle rejection submission logic
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
                              'doc_type_id':myformDetails[0]['db_admission_table']['db_required_documents_table'][0]['requirements_type'],
                              'user_id':myformDetails[0]['user_id']
                            }),
                          );

                          if (response.statusCode == 200) {
                            final responseBody = jsonDecode(response.body);
                            setState(() {
                              updateData(admissionId);
                              checkDocumentRequirements(gradeLevel, List<Map<String, dynamic>>.from(
                                myformDetails[0]['db_admission_table']['db_required_documents_table']
                              ));
                            });
                            Navigator.of(context).popUntil((route) => route.isFirst);
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
              // Centered Text
              const Center(
                // child: Text(
                //   "",
                //   style: TextStyle(
                //     fontSize: 20,
                //   ),
                //   textAlign: TextAlign.center,
                // ),
              ),
              // Red X Icon with Circular Outline
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
                    "Attached Documents has beeen Rejected!",
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
                    Navigator.of(context).pop(); // Close the modal
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
                            // showDialog(
                            //   context: context,
                            //   builder: (context) => AlertDialog(
                            //     title: const Text("Rejected"),
                            //     content: const Text("The review has been marked as rejected."),
                            //     actions: [
                            //       TextButton(
                            //         onPressed: () {
                            //           isComplete = checkDocumentRequirements(
                            //             gradeLevel,
                            //             List<Map<String, dynamic>>.from(myformDetails[0]['db_admission_table']['db_required_documents_table']),
                            //           );
                            //           widget.onNextPressed(isComplete);
                            //           Navigator.of(context).pop(); // Close dialog
                            //         },
                            //         child: const Text("OK"),
                            //       ),
                            //     ],
                            //   ),
                            // );
                          } else {
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
                          print('Error: $error');
                          Navigator.of(context).pop();
  //                         showDialog(
  //   context: context,
  //   builder: (BuildContext context) {
  //     return Dialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       child: Container(
  //         width: 349,
  //         height: 272,
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             // Centered Text
  //             const Center(
  //               // child: Text(
  //               //   "",
  //               //   style: TextStyle(
  //               //     fontSize: 20,
  //               //   ),
  //               //   textAlign: TextAlign.center,
  //               // ),
  //             ),
  //             // Red X Icon with Circular Outline
  //             Column(
  //               children: [
  //                 Container(
  //                   width: 90,
  //                   height: 90,
  //                   decoration: BoxDecoration(
  //                     shape: BoxShape.circle,
  //                     border: Border.all(color: const Color(0XFF012169), width: 2),
  //                   ),
  //                   child: const Center(
  //                     child: Icon(
  //                       Icons.check,
  //                       color: Color(0XFF012169),
  //                       size: 40,
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 20),
  //                 // No Form Submitted Text
  //                 const Text(
  //                   "Attached Documents has beeen Rejected!",
  //                   style: TextStyle(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                   textAlign: TextAlign.center,
  //                 ),
  //               ],
  //             ),
  //             // Divider
  //             const Divider(
  //               thickness: 1,
  //               color: Colors.grey,
  //             ),
  //             // Close Button
  //             Align(
  //               alignment: Alignment.bottomCenter,
  //               child: ElevatedButton(
  //                 onPressed: () {
  //                   Navigator.of(context).pop(); // Close the modal
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: const Color(0xff012169), // Button color
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                   minimumSize: const Size(double.infinity, 50), // Expand width and set height
  //                 ),
  //                 child: const Text(
  //                   "Close",
  //                   style: TextStyle(fontSize: 16, color: Colors.white),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   },
  // );
                        }
                      },
                      child: const Text("Submit", style: TextStyle(fontSize: 16, fontFamily: 'Roboto-R', color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  },
);
                    }:null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffC8102E),
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                    ),
                    child: const Text('Reject', style: TextStyle(color: Colors.white),),
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
