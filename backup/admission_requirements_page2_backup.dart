import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cdbs_admin/bloc/auth/auth_bloc.dart';
import 'package:cdbs_admin/subpages/login_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cdbs_admin/bloc/admission_bloc/admission_bloc.dart';
import 'package:cdbs_admin/class/admission_forms.dart';
import 'package:cdbs_admin/shared/api.dart';
import 'package:cdbs_admin/widget/custom_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'package:http_parser/http_parser.dart';



// Name of your class
class AdmissionRequirementsPage2 extends StatefulWidget {
  List<Map<String, dynamic>>? formDetails;
  final Function(bool isClicked) onNextPressed;
  int userId;

  AdmissionRequirementsPage2(
      {super.key,
      required this.formDetails,
      required this.onNextPressed,
      required this.userId});

  @override
  State<AdmissionRequirementsPage2> createState() =>
      _AdmissionRequirementsPage2State();
}

class _AdmissionRequirementsPage2State
    extends State<AdmissionRequirementsPage2> {
  TextEditingController rejectController = TextEditingController();
  String? applicationId;
  String? fullName;
  String? parentName;
  String? parentEmail;
  String? parentContact;
  String? status;
  String? dateCreatedString;
  String? formattedDate;
  String? docStatus;
  bool isLoading = false;
  List<Map<String, dynamic>> myformDetails = [];
  List<PlatformFile> _selectedFiles =[];
  bool isSelect = false;

  @override
  void initState() {
    super.initState();
    myformDetails = widget.formDetails!;
    applicationId = myformDetails[0]['db_admission_table']['admission_form_id'];
    fullName = '${myformDetails[0]['db_admission_table']['first_name']} ${myformDetails[0]['db_admission_table']['last_name']}';
    parentName = '${myformDetails[0]['db_admission_users_table']['last_name']}, ${myformDetails[0]['db_admission_users_table']['first_name']}';
    parentEmail = '${myformDetails[0]['db_admission_users_table']['email_address']}';
    parentContact = '${myformDetails[0]['db_admission_users_table']['contact_no']}';
    status = myformDetails[0]['db_admission_table']['admission_status'];
    dateCreatedString = myformDetails[0]['db_admission_table']['created_at'];
    DateTime dateCreated = DateTime.parse(dateCreatedString!);
    formattedDate = formatDate(dateCreated);
  }

  Future<void> updateData(int admissionId) async {
    myformDetails = await ApiService(apiUrl).getFormsDetailsById(admissionId, supabaseUrl, supabaseKey);
    bool isDone = checkDocumentRequirements(myformDetails[0]['db_admission_table']['level_applying_for'],List<Map<String, dynamic>>.from(myformDetails[0]['db_admission_table']['db_required_documents_table']));
    if (isDone) {
      try {
        final response = await http.post(
          Uri.parse('$apiUrl/api/admin/update_admission'),
          headers: {
            'Content-Type': 'application/json',
            'supabase-url': supabaseUrl,
            'supabase-key': supabaseKey,
          },
          body: json.encode({
            'admission_id': myformDetails[0]['admission_id'], // Send admission_id in the request body
            'is_all_required_file_uploaded': true,
            'user_id': widget.userId,
            'admission_status': 'pending',
            'is_done': true,
          }),
        );
      } catch (error) {
        // Handle error (e.g., network error)
        print('Error: $error');

        // Show error modal
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: const Text(
                "An unexpected error occurred. Please try again later."),
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
    }
  }


  void openUrlsInSameTab(List<String> urls) {
  try {
    // Create an iframe to display the first document
    var iframe = html.IFrameElement();
    iframe.src = urls.first; // Set the first URL
    iframe.width = '100%';
    iframe.height = '100vh';
    html.document.body!.children.add(iframe); // Add iframe to the body

    // After viewing the first URL, switch to the next one
    for (var i = 1; i < urls.length; i++) {
      // Update the iframe's source to the next URL
      iframe.src = urls[i];
    }
  } catch (e) {
    // If an error occurs, show a SnackBar with the error message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not open the link'),
      ),
    );
  }
}


  /*Future<void> _pickFiles(StateSetter setState) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Allow only PDF files
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFiles = result.files; // Assign selected files
      });
    } else {
      setState(() {
        _selectedFiles = []; // Allow _selectedFiles to be empty
      });
    }
  } catch (e) {
    print('Error picking files: $e');
  }
}*/

/*Future<void> _pickFiles(StateSetter setState) async {
  try {
    // Create the file upload input element
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.pdf'; // Accept PDF files only
    uploadInput.multiple = true; // Allow multiple files

    uploadInput.click(); // Trigger the file picker dialog

    // Listen for the file selection
    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        // Convert the selected files into PlatformFile objects
        setState(() {
          _selectedFiles = files.map((file) {
            return PlatformFile(
              name: file.name,
              size: file.size, // Required size parameter
              path: null,// Extract file extension
            );
          }).toList();
        });
      }
    });
  } catch (e) {
    print('Error picking files: $e');
  }
}*/

/*Future<void> _pickFiles(StateSetter setState) async {
  try {
    // Create the file upload input element
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.pdf'; // Accept PDF files only
    uploadInput.multiple = true; // Allow multiple files

    uploadInput.click(); // Trigger the file picker dialog

    // Listen for the file selection
    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        // Create a list to store PlatformFile objects
        List<PlatformFile> selectedFiles = [];

        // Loop through each file and read its bytes
        for (var file in files) {
          // Use FileReader to read file content as bytes
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file); // Read as ArrayBuffer (Uint8List)
          
          await reader.onLoadEnd.first; // Wait for the file to be fully loaded

          if (reader.result != null) {
            // Convert ArrayBuffer to Uint8List
            final bytes = reader.result as Uint8List;
            
            // Create PlatformFile object with the bytes and other properties
            selectedFiles.add(PlatformFile(
              name: file.name,
              size: file.size,
              bytes: bytes, // Assign the file bytes
              path: null,   // Path is not available in web
            ));
          }
        }

        // Update the selected files in the state
        setState(() {
          _selectedFiles = selectedFiles;
        });
      }
    });
  } catch (e) {
    print('Error picking files: $e');
  }
}*/


Future<void> _pickFiles(StateSetter setState) async {
  try {
    // Create the file upload input element
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = '.pdf'; // Accept PDF files only
    uploadInput.multiple = true; // Allow multiple files
    uploadInput.click(); // Trigger the file picker dialog

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        // Create a list to store new selected files
        List<PlatformFile> newFiles = [];

        for (var file in files) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file); // Read as ArrayBuffer (Uint8List)
          await reader.onLoadEnd.first; // Wait for the file to be fully loaded

          if (reader.result != null) {
            final bytes = reader.result as Uint8List;

            // Check if the file is already in the list (prevent duplicates)
            bool fileExists = _selectedFiles.any((f) => f.name == file.name);
            if (!fileExists) {
              newFiles.add(PlatformFile(
                name: file.name,
                size: file.size,
                bytes: bytes,
                path: null, // Path is not available in web
              ));
            }
          }
        }

        // Update the selected files in the state
        setState(() {
          if (_selectedFiles.isEmpty) {
            _selectedFiles = newFiles; // If empty, replace with new files
          } else {
            _selectedFiles.addAll(newFiles); // Append new files
          }
        });
      }
    });
  } catch (e) {
    print('Error picking files: $e');
  }
}



  String formatDate(DateTime date) {
    // Convert the UTC date to local time
    DateTime localDate = date.toLocal();

    // Create a DateFormat object to format the date
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');

    // Return the formatted date in local time
    return formatter.format(localDate);
  }


/*Future<bool> _uploadRecommendation(
  String requirementsType,
  String admissionId,
  String bucketName,
  String requiredDocId,
) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiUrl/api/admin/upload_requirements'),
    );

    request.headers.addAll({
      'supabase-url': supabaseUrl,
      'supabase-key': supabaseKey,
    });

    request.fields['requirements_type'] = requirementsType;
    request.fields['admission_id'] = admissionId;
    request.fields['required_doc_id'] = requiredDocId;
    request.fields['bucket_name'] = bucketName;

    for (var file in _selectedFiles!) {
      try {
        final fileBytes = await _getFileBytes(file);
        if (fileBytes != null) {
          final mimeType = _getMimeType(file.extension ?? '');
          if (mimeType == null) {
            print('Unsupported file type: ${file.extension}');
            continue;
          }

          request.files.add(http.MultipartFile.fromBytes(
            'files',
            fileBytes,
            filename: file.name,
            contentType: MediaType.parse(mimeType),
          ));
        } else {
          print('Error reading file bytes for ${file.name}');
        }
      } catch (e) {
        print('Error processing file ${file.name}: $e');
      }
    }

    var response = await request.send().timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      print('Upload successful: $data');
      return true;
    } else {
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      print('Upload failed with status ${response.statusCode}: ${data['error'] ?? data}');
      return false;
    }
  } on TimeoutException {
    print('The request timed out. Please try again later.');
    return false;
  } catch (e) {
    print('Unexpected error: $e');
    return false;
  }
}*/

Future<bool> _uploadRecommendation(
  String requirementsType,
  String admissionId,
  String bucketName,
  String requiredDocId,
) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$apiUrl/api/admin/upload_requirements'),
    );

    // Adding headers
    request.headers.addAll({
      'supabase-url': supabaseUrl,
      'supabase-key': supabaseKey,
    });

    // Add form fields
    request.fields['requirements_type'] = requirementsType;
    request.fields['admission_id'] = admissionId;
    request.fields['required_doc_id'] = requiredDocId;
    request.fields['bucket_name'] = bucketName;

    // Add files
    for (var file in _selectedFiles!) {
      try {
        final fileBytes = await _getFileBytes(file);
        if (fileBytes != null) {
          // Log file size before uploading
          print('File size before upload for ${file.name}: ${fileBytes.length} bytes');

          final mimeType = _getMimeType(file.extension ?? '');
          if (mimeType == null) {
            print('Unsupported file type: ${file.extension}');
            continue;
          }

          // URL encode the file name to prevent special character issues
          String encodedFileName = encodeFileName(file.name);

          // Add the file to the request
          var multipartFile = http.MultipartFile.fromBytes(
            'files', 
            fileBytes,
            filename: encodedFileName, // URL-encoded filename
            contentType: MediaType.parse(mimeType),
          );

          // Add to request
          request.files.add(multipartFile);
        } else {
          print('Error reading file bytes for ${file.name}');
        }
      } catch (e) {
        print('Error processing file ${file.name}: $e');
      }
    }

    // Send the request with an increased timeout
    var response = await request.send().timeout(const Duration(seconds: 60)); // Increased timeout

    // Handle the response
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      print('Upload successful: $data');
      return true;
    } else {
      // If upload fails, log the response data
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      print('Upload failed with status ${response.statusCode}: ${data['error'] ?? data}');
      return false;
    }
  } on TimeoutException {
    print('The request timed out. Please try again later.');
    return false;
  } catch (e) {
    print('Unexpected error: $e');
    return false;
  }
}

// Ensure the file name is properly URL-encoded to handle special characters
String encodeFileName(String fileName) {
  return Uri.encodeComponent(fileName);
}

String? _getMimeType(String extension) {
  switch (extension.toLowerCase()) {
    case 'pdf':
      return 'application/pdf';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    default:
      return null;
  }
}

// Example method to fetch file bytes

Future<Uint8List?> _getFileBytes(PlatformFile file) async {
  final reader = html.FileReader();
  final completer = Completer<Uint8List>();

  // Check if file bytes are available and valid
  if (file.bytes == null || file.bytes!.isEmpty) {
    print('File bytes are empty or null for ${file.name}');
    return null; // Return null if no bytes
  }

  // Create a Blob from the file's bytes
  final blob = html.Blob([file.bytes!]);

  // Read the Blob as an ArrayBuffer
  reader.readAsArrayBuffer(blob);

  // Handle the load and error events
  reader.onLoadEnd.listen((e) {
    final result = reader.result;
    if (result != null) {
      print('File read successfully: ${(result as Uint8List).length} bytes');
      completer.complete(result as Uint8List);
    } else {
      print('Failed to read file data for ${file.name}');
      completer.completeError('Error reading file data');
    }
  });

  reader.onError.listen((e) {
    print('Error while reading file ${file.name}: ${e}');
    completer.completeError('Error reading file data');
  });

  return completer.future;
}




  /*Future<Uint8List> _getFileBytes(PlatformFile file) async {
    final reader = html.FileReader();
    final completer = Completer<Uint8List>();

    // Create a Blob from the file's bytes
    final blob = html.Blob(
        [file.bytes]); // Assuming 'file.bytes' gives you the byte data

    reader.readAsArrayBuffer(blob);
    reader.onLoadEnd.listen((e) {
      completer.complete(reader.result as Uint8List);
    });

    return completer.future;
  }*/

  


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
                  value: myformDetails[0]['db_admission_table']
                      ['level_applying_for'],
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
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Application ID
              Expanded(
                flex: 2,
                child: _buildParentColumn(
                  label: "Parent Name",
                  value: parentName!,
                  scale: scale,
                ),
              ),
              const SizedBox(width: 16),

              // Applicant Name
              Expanded(
                flex: 3,
                child: _buildInfoColumn(
                  label: 'Email Address',
                  value: parentEmail!,
                  scale: scale,
                ),
              ),
              const SizedBox(width: 16),

              // Grade Level
              Expanded(
                flex: 2,
                child: _buildInfoColumn(
                  label: 'Contact Number',
                  value: parentContact!,
                  scale: scale,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                flex: 2,
                child: SizedBox()
              ),
              const SizedBox(width: 16),
              const Expanded(
                flex: 2,
                child: SizedBox()
              ),
              
            ],
          ),

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

          SizedBox(
              width: 1200,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('Document Type',
                        style: TextStyle(
                            fontSize: 14 * scale, fontFamily: 'Roboto-L')),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 2,
                    child: Text('View Documents',
                        style: TextStyle(
                            fontSize: 14 * scale, fontFamily: 'Roboto-L')),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 1,
                    child: Text('Status',
                        style: TextStyle(
                            fontSize: 14 * scale, fontFamily: 'Roboto-L')),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 2,
                    child: Text('Reject Reason',
                        style: TextStyle(
                            fontSize: 14 * scale, fontFamily: 'Roboto-L')),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 2,
                    child: Text('Actions',
                        style: TextStyle(
                            fontSize: 14 * scale, fontFamily: 'Roboto-L')),
                  ),
                ],
              )),

          SizedBox(
            width: 1200,
            height: 400,
            child: BlocConsumer<AuthBloc, AuthState>(
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
                return ListView.builder(
                    itemCount: myformDetails[0]['db_admission_table']['db_required_documents_table'].length,
                    itemBuilder: (context, index) {
                      var document = myformDetails[0]['db_admission_table']['db_required_documents_table'];
                      String gradeLevel = myformDetails[0]['db_admission_table']['level_applying_for'];
                      String originalUrl = '';
                      if (document[index]['document_url'] != null) {
                        originalUrl = document[index]['document_url'].substring(
                            2, document[index]['document_url'].length - 2);
                      }
                      String encodedUrl = Uri.encodeFull(originalUrl);
                      String reject =  document[index]['reject_reason'] ?? 'N/A';
                      return Column(children: [
                        const SizedBox(height: 10),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  document[index]['db_requirement_type_table']['doc_type'],
                                  style: TextStyle(
                                      fontFamily: 'Roboto-R', fontSize: 14 * scale),
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                flex: 2,
                                child: (document[index]['requirements_type'] == 5 || document[index]['requirements_type'] == 15) && document[index]['document_url'] == null
                                ? ElevatedButton(
                                    onPressed: () {
                                      // Upload button action
                                      // Implement the upload functionality here\
                                      showUploadDialog(context, document[index], setState);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff28a745), // Green color for upload
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: const Text(
                                      "Upload",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                :ElevatedButton(
                                  onPressed: document[index]['document_url'] != null
                                      ? () async {
                                          // Ensure imagePath is a valid URL
                
                                          // Use the browser's built-in window.open method
                                         /* try {
                                            html.window.open(encodedUrl,
                                                '_blank'); // Open URL in a new tab
                                          } catch (e) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Could not open the link')),
                                            );
                                          }*/
                                          List<String> urls = List<String>.from(json.decode(document[index]['document_url']));
                          
                                          try {
                                            for (var url in urls) {
                                              // Open each URL in a new tab
                                              html.window.open(url, '_blank');
                                            }
                                          } catch (e) {
                                            // If an error occurs, show a SnackBar with the error message
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Could not open the link'),
                                              ),
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
                                    "Open Link",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                  flex: 1,
                                  child: Text(
                                    document[index]['document_status']
                                        .toUpperCase(),
                                    style: TextStyle(
                                        fontFamily: 'Roboto-R',
                                        fontSize: 14 * scale),
                                  )),
                                  const SizedBox(width: 40),
                              Expanded(
                                  flex: 2,
                                  child: Text(reject,
                                    style: TextStyle(
                                        fontFamily: 'Roboto-R',
                                        fontSize: 14 * scale),
                                  )),
                              const SizedBox(width: 40),
                              authState.adminType=='Admin' || authState.adminType=='Principal' || authState.adminType=='Registrar' || authState.adminType=='IT' || authState.adminType=='Sisters' || authState.adminType=='Center for Learner Wellness'?
                              Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed:
                                            document[index]['document_status'] == 'pending'
                                                ? () {
                                                    // Handle accept action
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => Dialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0)),
                                                        child: BlocConsumer<
                                                            AdmissionBloc,
                                                            AdmissionState>(
                                                          listener:
                                                              (context, state) {},
                                                          builder:
                                                              (context, state) {
                                                            if (state
                                                                is AdmissionIsLoading) {
                                                              isLoading =
                                                                  state.isLoading;
                                                            }
                                                            return SizedBox(
                                                              width: 349.0,
                                                              height: 272.0,
                                                              child: isLoading
                                                                  ? const CustomSpinner(
                                                                      color: Color(
                                                                          0xff13322b), // Change the spinner color if needed
                                                                      size:
                                                                          60.0, // Change the size of the spinner if needed
                                                                    )
                                                                  : Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        // Title
                                                                        const Padding(
                                                                          padding: EdgeInsets.only(
                                                                              top:
                                                                                  16.0,
                                                                              bottom:
                                                                                  8.0),
                                                                          child:
                                                                              Text(
                                                                            "Confirmation",
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily:
                                                                                  'Roboto',
                                                                              fontSize:
                                                                                  20,
                                                                              fontWeight:
                                                                                  FontWeight.bold,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ),
                                                                        // Content
                                                                        const Padding(
                                                                          padding: EdgeInsets.symmetric(
                                                                              horizontal:
                                                                                  24.0),
                                                                          child:
                                                                              Text(
                                                                            "Are you sure you want to confirm?",
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily:
                                                                                  'Roboto',
                                                                              fontSize:
                                                                                  13,
                                                                              fontWeight:
                                                                                  FontWeight.normal,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                16.0),
                                                                        // Divider
                                                                        const Padding(
                                                                          padding: EdgeInsets.only(
                                                                              left:
                                                                                  20,
                                                                              right:
                                                                                  20),
                                                                          child: Divider(
                                                                              thickness:
                                                                                  1),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                16.0),
                                                                        // No Button
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal:
                                                                                  30.0),
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                289,
                                                                            height:
                                                                                35,
                                                                            child:
                                                                                TextButton(
                                                                              style:
                                                                                  TextButton.styleFrom(
                                                                                backgroundColor:
                                                                                    const Color(0xffD3D3D3), // No button color
                                                                                shape:
                                                                                    RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                ),
                                                                              ),
                                                                              onPressed:
                                                                                  () {
                                                                                Navigator.of(context).pop(); // Close dialog
                                                                              },
                                                                              child:
                                                                                  const Text(
                                                                                "No",
                                                                                style:
                                                                                    TextStyle(color: Colors.black),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                12.0), // Spacing between buttons
                                                                        // Yes Button
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal:
                                                                                  30.0),
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                289,
                                                                            height:
                                                                                35,
                                                                            child:
                                                                                TextButton(
                                                                              style:
                                                                                  TextButton.styleFrom(
                                                                                backgroundColor:
                                                                                    const Color(0xff012169), // Amber button color
                                                                                shape:
                                                                                    RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                ),
                                                                              ),
                                                                              onPressed:
                                                                                  () async {
                                                                                context.read<AdmissionBloc>().add(IsLoadingClicked(true));
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
                                                                                      'required_doc_id': document[index]['required_doc_id'],
                                                                                      'reject_reason': '',
                                                                                    }),
                                                                                  );
                
                                                                                  if (response.statusCode == 200) {
                                                                                    final responseBody = jsonDecode(response.body);
                                                                                    setState(() {
                                                                                      updateData(document[index]['admission_id']);
                                                                                      bool isDone = checkDocumentRequirements(gradeLevel, List<Map<String, dynamic>>.from(document));
                                                                                    });
                                                                                    // Show success modal
                                                                                    context.read<AdmissionBloc>().add(IsLoadingClicked(false));
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
                                                                              child:
                                                                                  const Text(
                                                                                "Yes",
                                                                                style:
                                                                                    TextStyle(color: Colors.white),
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
                                                  }
                                                : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xff007937),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Accept',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      ElevatedButton(
                                        onPressed:
                                            document[index]['document_status'] ==
                                                    'pending'
                                                ? () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return Dialog(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0)),
                                                          child: BlocConsumer<AdmissionBloc, AdmissionState>(
                                                            listener:(context, state) {},
                                                            builder: (context, state) {
                                                              if (state is AdmissionIsLoading) {
                                                                isLoading = state.isLoading;
                                                              }
                                                              return SizedBox(
                                                                width: 349.0,
                                                                height: 320.0,
                                                                child: isLoading
                                                                  ? const CustomSpinner(
                                                                      color:
                                                                          Color(0xff13322b), // Change the spinner color if needed
                                                                      size: 60.0, // Change the size of the spinner if needed
                                                                    ): Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              16.0),
                                                                      child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment
                                                                                .start,
                                                                        children: [
                                                                          // const Text(
                                                                          //   "Reject",
                                                                          //   style: TextStyle(
                                                                          //     fontSize: 18,
                                                                          //     fontWeight: FontWeight.bold,
                                                                          //   ),
                                                                          // ),
                                                                          const SizedBox(
                                                                              height:
                                                                                  10),
                                                                          const Text(
                                                                              "Please provide a reason for rejection:"),
                                                                          const SizedBox(
                                                                              height:
                                                                                  10),
                                                                          TextField(
                                                                            controller:
                                                                                rejectController,
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              border:
                                                                                  OutlineInputBorder(),
                                                                              hintText:
                                                                                  "Enter rejection reason",
                                                                            ),
                                                                            maxLines:
                                                                                3,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const Padding(
                                                                      padding: EdgeInsets
                                                                          .only(
                                                                              left:
                                                                                  20,
                                                                              right:
                                                                                  20),
                                                                      child: Divider(
                                                                          thickness:
                                                                              1),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              16.0,
                                                                          vertical:
                                                                              8.0),
                                                                      child: Column(
                                                                        children: [
                                                                          // Close button on the first row
                                                                          SizedBox(
                                                                            width: double
                                                                                .infinity,
                                                                            height:
                                                                                35,
                                                                            child:
                                                                                TextButton(
                                                                              style:
                                                                                  TextButton.styleFrom(
                                                                                backgroundColor:
                                                                                    const Color(0xffD3D3D3),
                                                                                shape:
                                                                                    RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                ),
                                                                              ),
                                                                              onPressed:
                                                                                  () {
                                                                                Navigator.of(context).pop(); // Close dialog
                                                                              },
                                                                              child:
                                                                                  const Text(
                                                                                "Close",
                                                                                style:
                                                                                    TextStyle(fontSize: 16, color: Colors.black),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height:
                                                                                  10), // Spacer between the buttons
                                                                          // Submit button on the second row
                                                                          SizedBox(
                                                                            width: double
                                                                                .infinity,
                                                                            height:
                                                                                35,
                                                                            child:
                                                                                ElevatedButton(
                                                                              style:
                                                                                  ElevatedButton.styleFrom(
                                                                                backgroundColor:
                                                                                    const Color(0xff012169),
                                                                                shape:
                                                                                    RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                ),
                                                                              ),
                                                                              onPressed:
                                                                                  () async {
                                                                                // Handle rejection submission logic
                                                                                context.read<AdmissionBloc>().add(IsLoadingClicked(true));
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
                                                                                      'required_doc_id': document[index]['required_doc_id'],
                                                                                      'reject_reason': rejectController.text,
                                                                                      'doc_type_id': document[index]['requirements_type'],
                                                                                      'user_id': myformDetails[0]['user_id']
                                                                                    }),
                                                                                  );
                
                                                                                  if (response.statusCode == 200) {
                                                                                    final responseBody = jsonDecode(response.body);
                                                                                    setState(() {
                                                                                      updateData(document[index]['admission_id']);
                                                                                      checkDocumentRequirements(gradeLevel, List<Map<String, dynamic>>.from(myformDetails[0]['db_admission_table']['db_required_documents_table']));
                                                                                    });
                                                                                    context.read<AdmissionBloc>().add(IsLoadingClicked(false));
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
                                                                                  } else {
                                                                                    final responseBody = jsonDecode(response.body);
                                                                                    print('Error: ${responseBody['error']}');
                                                                                    Navigator.of(context).pop();
                                                                                    context.read<AdmissionBloc>().add(IsLoadingClicked(false));
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
                                                                                  context.read<AdmissionBloc>().add(IsLoadingClicked(false));
                                                                                  print('Error: $error');
                                                                                  Navigator.of(context).pop();
                                                                                }
                                                                              },
                                                                              child: const Text(
                                                                                  "Submit",
                                                                                  style: TextStyle(fontSize: 16, fontFamily: 'Roboto-R', color: Colors.white)),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  }
                                                : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xffC8102E),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30),
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Reject',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      )
                                    ],
                                  )):

                                  Expanded(
                                      flex: 2,
                                      child: Container(),
                                  )    
                            ]),
                        const Divider(color: Colors.grey, thickness: 1),
                      ]);
                    });
              }
              
              return Container();
              }
            )
          )
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



  Widget _buildParentColumn({
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
            Tooltip(
              message: fullName, // Full name shown on hover
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xff012169),
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
              child: SizedBox(
                width: 120,
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Roboto-B',
                    fontSize: 12 * scale,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
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

  Widget _buildImageCard(
      {String? imagePath,
      int? id,
      int? admissionId,
      String? status,
      required String label,
      required double scale,
      bool isPlaceholder = false,
      bool isDashedLine = false,
      required StateSetter setState,
      required List<Map<String, dynamic>> formRequirements,
      String? gradeLevel}) {
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
        _showImageDialog(imagePath, id!, admissionId!, status!,
            formRequirements, gradeLevel!);
      }, // Open dialog on tap
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 158,
            height: 89,
            child: Stack(
              clipBehavior:
                  Clip.none, // Allow content to overflow out of the Stack
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
                                  return Center(
                                    child: Column(
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
                                            final String url =
                                                imagePath; // Ensure imagePath is a valid URL

                                            // Use the browser's built-in window.open method
                                            try {
                                              html.window.open(url,
                                                  '_blank'); // Open URL in a new tab
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Could not open the link')),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            "Open Link",
                                            style:
                                                TextStyle(color: Colors.white),
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
                  top: -4, // Move it slightly outside the image (top)
                  right: -4, // Move it slightly outside the image (right)
                  child: CircleAvatar(
                    radius: 10, // Larger radius for the floating effect
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

  bool checkDocumentRequirements(
      String gradeLevel, List<Map<String, dynamic>> formRequirements) {
    // Define the list of required doc_ids based on the grade level
    List<int> requiredDocIds;

    // Check the gradeLevel and set the required doc_ids accordingly
    if (gradeLevel.toLowerCase() == 'pre-kinder' ||
        gradeLevel.toLowerCase() == 'kinder') {
      requiredDocIds = [
        1,
        2,
        4
      ]; // For 'pre-kinder' or 'kinder', require doc_ids 1, 2, and 4
    } else {
      if(gradeLevel.toLowerCase() == 'grade 1'){
        requiredDocIds = [
          1,
          2,
          5,
          14,
          15
        ];
      }else{
        requiredDocIds = [
          1,
          2,
          3,
          5,
          14,
          15
        ];
      } // For other grade levels, require doc_ids 1, 2, 3, and 5
    }

    // Loop through the required doc_ids
    for (int docId in requiredDocIds) {
      bool docFound = false;

      // Check if each doc_id (from requiredDocIds) is in the formRequirements and has 'accepted' status
      for (var requirement in formRequirements) {
        if (requirement['db_requirement_type_table'] != null) {
          var requirementDocId =
              requirement['db_requirement_type_table']['doc_id'];
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
  void _showImageDialog(
      String? imagePath,
      int id,
      int admissionId,
      String docStatus,
      List<Map<String, dynamic>> formRequirements,
      String gradeLevel) {
    bool isLoading = false;
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
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: docStatus == 'pending'
                          ? () {
                              // Handle accept action

                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: BlocConsumer<AdmissionBloc,
                                      AdmissionState>(
                                    listener: (context, state) {},
                                    builder: (context, state) {
                                      if (state is AdmissionIsLoading) {
                                        isLoading = state.isLoading;
                                      }
                                      return SizedBox(
                                        width: 349.0,
                                        height: 272.0,
                                        child: isLoading
                                            ? const CustomSpinner(
                                                color: Color(
                                                    0xff13322b), // Change the spinner color if needed
                                                size:
                                                    60.0, // Change the size of the spinner if needed
                                              )
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  // Title
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 16.0, bottom: 8.0),
                                                    child: Text(
                                                      "Confirmation",
                                                      style: TextStyle(
                                                        fontFamily: 'Roboto',
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  // Content
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 24.0),
                                                    child: Text(
                                                      "Are you sure you want to confirm?",
                                                      style: TextStyle(
                                                        fontFamily: 'Roboto',
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16.0),
                                                  // Divider
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 20, right: 20),
                                                    child:
                                                        Divider(thickness: 1),
                                                  ),
                                                  const SizedBox(height: 16.0),
                                                  // No Button
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 30.0),
                                                    child: SizedBox(
                                                      width: 289,
                                                      height: 35,
                                                      child: TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              const Color(
                                                                  0xffD3D3D3), // No button color
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(); // Close dialog
                                                        },
                                                        child: const Text(
                                                          "No",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      height:
                                                          12.0), // Spacing between buttons
                                                  // Yes Button
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 30.0),
                                                    child: SizedBox(
                                                      width: 289,
                                                      height: 35,
                                                      child: TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              const Color(
                                                                  0xff012169), // Amber button color
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                        onPressed: () async {
                                                          context
                                                              .read<
                                                                  AdmissionBloc>()
                                                              .add(
                                                                  IsLoadingClicked(
                                                                      true));
                                                          try {
                                                            final response =
                                                                await http.post(
                                                              Uri.parse(
                                                                  '$apiUrl/api/admin/update_required_form'),
                                                              headers: {
                                                                'Content-Type':
                                                                    'application/json',
                                                                'supabase-url':
                                                                    supabaseUrl,
                                                                'supabase-key':
                                                                    supabaseKey,
                                                              },
                                                              body:
                                                                  json.encode({
                                                                'document_status':
                                                                    'accepted',
                                                                'required_doc_id':
                                                                    id,
                                                                'reject_reason':
                                                                    '',
                                                              }),
                                                            );

                                                            if (response
                                                                    .statusCode ==
                                                                200) {
                                                              final responseBody =
                                                                  jsonDecode(
                                                                      response
                                                                          .body);
                                                              setState(() {
                                                                updateData(
                                                                    admissionId);
                                                                checkDocumentRequirements(
                                                                    gradeLevel,
                                                                    List<
                                                                        Map<String,
                                                                            dynamic>>.from(myformDetails[
                                                                                0]
                                                                            [
                                                                            'db_admission_table']
                                                                        [
                                                                        'db_required_documents_table']));
                                                              });
                                                              // Show success modal
                                                              context
                                                                  .read<
                                                                      AdmissionBloc>()
                                                                  .add(IsLoadingClicked(
                                                                      false));
                                                              Navigator.of(
                                                                      context)
                                                                  .popUntil(
                                                                      (route) =>
                                                                          route
                                                                              .isFirst);
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return Dialog(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          349,
                                                                      height:
                                                                          272,
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          16),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
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
                                                                            thickness:
                                                                                1,
                                                                            color:
                                                                                Colors.grey,
                                                                          ),
                                                                          // Close Button
                                                                          Align(
                                                                            alignment:
                                                                                Alignment.bottomCenter,
                                                                            child:
                                                                                ElevatedButton(
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
                                                              final responseBody =
                                                                  jsonDecode(
                                                                      response
                                                                          .body);
                                                              print(
                                                                  'Error: ${responseBody['error']}');
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        AlertDialog(
                                                                  title: const Text(
                                                                      "Error"),
                                                                  content: Text(
                                                                      "Failed to complete review: ${responseBody['error']}"),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop(); // Close dialog
                                                                      },
                                                                      child: const Text(
                                                                          "OK"),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            }
                                                          } catch (error) {
                                                            // Handle network error
                                                            print(
                                                                'Error: $error');
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) =>
                                                                      AlertDialog(
                                                                title:
                                                                    const Text(
                                                                        "Error"),
                                                                content: const Text(
                                                                    "An unexpected error occurred. Please try again later."),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(); // Close dialog
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                            "OK"),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          } // Close dialog
                                                        },
                                                        child: const Text(
                                                          "Yes",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
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
                            }
                          : null,
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
                      child: const Text(
                        'Accept',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 2),
                    ElevatedButton(
                      onPressed: docStatus == 'pending'
                          ? () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    child: SizedBox(
                                      width: 349.0,
                                      height: 320.0,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Reject",
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                const Text(
                                                    "Please provide a reason for rejection:"),
                                                const SizedBox(height: 10),
                                                TextField(
                                                  controller: rejectController,
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    hintText:
                                                        "Enter rejection reason",
                                                  ),
                                                  maxLines: 3,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(
                                                left: 20, right: 20),
                                            child: Divider(thickness: 1),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 8.0),
                                            child: Column(
                                              children: [
                                                // Close button on the first row
                                                SizedBox(
                                                  width: double.infinity,
                                                  height: 35,
                                                  child: TextButton(
                                                    style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xffD3D3D3),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // Close dialog
                                                    },
                                                    child: const Text(
                                                      "Close",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                    height:
                                                        10), // Spacer between the buttons
                                                // Submit button on the second row
                                                SizedBox(
                                                  width: double.infinity,
                                                  height: 35,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xff012169),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                    onPressed: () async {
                                                      // Handle rejection submission logic
                                                      try {
                                                        final response =
                                                            await http.post(
                                                          Uri.parse(
                                                              '$apiUrl/api/admin/update_required_form'),
                                                          headers: {
                                                            'Content-Type':
                                                                'application/json',
                                                            'supabase-url':
                                                                supabaseUrl,
                                                            'supabase-key':
                                                                supabaseKey,
                                                          },
                                                          body: json.encode({
                                                            'document_status':
                                                                'rejected',
                                                            'required_doc_id':
                                                                id,
                                                            'reject_reason':
                                                                rejectController
                                                                    .text,
                                                            'doc_type_id': myformDetails[
                                                                            0][
                                                                        'db_admission_table']
                                                                    [
                                                                    'db_required_documents_table'][0]
                                                                [
                                                                'requirements_type'],
                                                            'user_id':
                                                                myformDetails[0]
                                                                    ['user_id']
                                                          }),
                                                        );

                                                        if (response
                                                                .statusCode ==
                                                            200) {
                                                          final responseBody =
                                                              jsonDecode(
                                                                  response
                                                                      .body);
                                                          setState(() {
                                                            updateData(
                                                                admissionId);
                                                            checkDocumentRequirements(
                                                                gradeLevel,
                                                                List<
                                                                    Map<String,
                                                                        dynamic>>.from(myformDetails[
                                                                            0][
                                                                        'db_admission_table']
                                                                    [
                                                                    'db_required_documents_table']));
                                                          });
                                                          Navigator.of(context)
                                                              .popUntil((route) =>
                                                                  route
                                                                      .isFirst);
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return Dialog(
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                                child:
                                                                    Container(
                                                                  width: 349,
                                                                  height: 272,
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          16),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
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
                                                                            width:
                                                                                90,
                                                                            height:
                                                                                90,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              border: Border.all(color: const Color(0XFF012169), width: 2),
                                                                            ),
                                                                            child:
                                                                                const Center(
                                                                              child: Icon(
                                                                                Icons.check,
                                                                                color: Color(0XFF012169),
                                                                                size: 40,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 20),
                                                                          // No Form Submitted Text
                                                                          const Text(
                                                                            "Attached Documents has beeen Rejected!",
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 20,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      // Divider
                                                                      const Divider(
                                                                        thickness:
                                                                            1,
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                      // Close Button
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.bottomCenter,
                                                                        child:
                                                                            ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop(); // Close the modal
                                                                          },
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            backgroundColor:
                                                                                const Color(0xff012169), // Button color
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(8),
                                                                            ),
                                                                            minimumSize:
                                                                                const Size(double.infinity, 50), // Expand width and set height
                                                                          ),
                                                                          child:
                                                                              const Text(
                                                                            "Close",
                                                                            style:
                                                                                TextStyle(fontSize: 16, color: Colors.white),
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
                                                          final responseBody =
                                                              jsonDecode(
                                                                  response
                                                                      .body);
                                                          print(
                                                              'Error: ${responseBody['error']}');
                                                          Navigator.of(context)
                                                              .pop();
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (context) =>
                                                                    AlertDialog(
                                                              title: const Text(
                                                                  "Error"),
                                                              content: Text(
                                                                  "Failed to complete review: ${responseBody['error']}"),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop(); // Close dialog
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                          "OK"),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }
                                                      } catch (error) {
                                                        print('Error: $error');
                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    },
                                                    child: const Text("Submit",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Roboto-R',
                                                            color:
                                                                Colors.white)),
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
                            }
                          : null,
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
                      child: const Text(
                        'Reject',
                        style: TextStyle(color: Colors.white),
                      ),
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

  
void showUploadDialog(
      BuildContext context, final request, StateSetter setState) {
    bool _isLoading = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
            backgroundColor: const Color(0xffffffff),
            content: SizedBox(
                                                          width: 349.0,
                                                          height: 450,
                                                          child: _isLoading
                                                              ? const CustomSpinner(
                                                                  color: Color(
                                                                      0xff13322b), // Change the spinner color if needed
                                                                  size:
                                                                      60.0, // Change the size of the spinner if needed
                                                                )
                                                              : Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    // Title
                                                                    const Padding(
                                                                      padding: EdgeInsets.only(
                                                                          top:
                                                                              16.0,
                                                                          bottom:
                                                                              8.0),
                                                                      child:
                                                                          Text(
                                                                        "Upload Recommendation File",
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Roboto',
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                      ),
                                                                    ),
                                                                    // Content
                                                                     Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                                                        child: Container(
                                                                          child: Column(
                                                                            children: [
                                                                              SizedBox(
                                                                                width: 200,
                                                                                height: 40,
                                                                                child: ElevatedButton(
                                                                                  onPressed: !isSelect
                                                                                      ? () {
                                                                                          _pickFiles(setState);
                                                                                          isSelect=true; // Open the file picker
                                                                                        }
                                                                                      : null,
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                    ),
                                                                                    backgroundColor: !isSelect
                                                                                        ? const Color(0xff012169)
                                                                                        : const Color(0xffD3D3D3),
                                                                                  ),
                                                                                  child: Text(
                                                                                    'Select File',
                                                                                    style: TextStyle(
                                                                                      color: !isSelect
                                                                                          ? const Color(0xffffffff)
                                                                                          : const Color(0xff000000),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),

                                                                              if (_selectedFiles.isNotEmpty) const SizedBox(height: 5),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),

                                                                        if (_selectedFiles.isNotEmpty)
                                                                                SizedBox(
                                                                                  height: 200,
                                                                                  child: SingleChildScrollView(
                                                                                    child: Column(
                                                                                      children: _selectedFiles.asMap().entries.map((entry) {
                                                                                        int index = entry.key;
                                                                                        var file = entry.value;
                                                                                        return Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                          children: [
                                                                                            SizedBox(
                                                                                              width: 250,
                                                                                              child: Text(
                                                                                                file.name,
                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                style: const TextStyle(color: Color(0xff13322b)),
                                                                                              ),
                                                                                            ),
                                                                                            IconButton(
                                                                                              icon: const Icon(
                                                                                                Icons.delete,
                                                                                                color: Color(0xff13322b),
                                                                                              ),
                                                                                              onPressed: () {
                                                                                                setState(() {
                                                                                                  _selectedFiles.removeAt(index);
                                                                                                  isSelect=false;
                                                                                                });
                                                                                              },
                                                                                            ),
                                                                                          ],
                                                                                        );
                                                                                      }).toList(),
                                                                                    ),
                                                                                  ),
                                                                                ),

                                                              
                                                                     SizedBox(height:_selectedFiles.isEmpty?155:25),
                                                                    // Divider
                                                                    const Padding(
                                                                      padding: EdgeInsets.only(
                                                                          left:
                                                                              20,
                                                                          right:
                                                                              20),
                                                                      child: Divider(
                                                                          thickness:
                                                                              1),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            16.0),
                                                                    // No Button
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              30.0),
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            289,
                                                                        height:
                                                                            35,
                                                                        child:
                                                                            TextButton(
                                                                          style:
                                                                              TextButton.styleFrom(
                                                                            backgroundColor:
                                                                                const Color(0xffD3D3D3), // No button color
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(8),
                                                                            ),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                                _selectedFiles=[];
                                                                            Navigator.of(context).pop(); // Close dialog
                                                                          },
                                                                          child:
                                                                              const Text(
                                                                            "Cancel",
                                                                            style:
                                                                                TextStyle(color: Colors.black),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            12.0), // Spacing between buttons
                                                                    // Yes Button
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              30.0),
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            289,
                                                                        height:
                                                                            35,
                                                                        child:
                                                                            TextButton(
                                                                          style:
                                                                              TextButton.styleFrom(
                                                                            backgroundColor:_selectedFiles.isNotEmpty?
                                                                                const Color(0xff012169):  Color(0xffD3D3D3), // Amber button color
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(8),
                                                                            ),
                                                                          ),
                                                                          onPressed: _selectedFiles.isNotEmpty? () async {
                                                                             try{
                                                                                if(_selectedFiles.isEmpty){
                                                                                  _showMessage('Please select a recommendation file to upload', "Error: File upload is required");
                                                                                  setState(() {
                                                                                    _selectedFiles = [];
                                                                                  });
                                                                                }else{
                                                                                  setState(() {
                                                                                    _isLoading = true; // Start loading
                                                                                  });
                                                                                  bool isStated = await _uploadRecommendation(
                                                                                    request['requirements_type'].toString(),
                                                                                    request['admission_id'].toString(),
                                                                                    'document_upload',
                                                                                    request['required_doc_id'].toString()
                                                                                  );
                                                              
                                                                                  setState(() {
                                                                                    _selectedFiles = [];
                                                                                    _isLoading = false; // Stop loading
                                                                                  });
                                                                                    
                                                                                  if (isStated) {
                                                                                    updateData(request['admission_id']);
                                                                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                                                                    _selectedFiles = [];
                                                                                    isSelect=false;
                                                                                    _showMessage('Recommendation for: ${request['admission_id']} has been uploaded',
                                                                                        'Upload Completed');
                                                                                  } else {
                                                                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                                                                    _selectedFiles = [];
                                                                                    isSelect=false;
                                                                                    _showMessage('File upload failed. The file size exceeds the 4 MB limit. Please ensure the file is under 4 MB in size.',
                                                                                        'Error');
                                                                                  }
                                                                                }
                                                                              }catch(error){
                                                                                _selectedFiles = [];
                                                                                isSelect=false;
                                                                                _showMessage('Connection timeout', "Error: File upload failed");
                                                                              }
                                                                          }:null,
                                                                          child:
                                                                               Text(
                                                                            "Upload",
                                                                            style:
                                                                                TextStyle(color: _selectedFiles.isNotEmpty? Colors.white:const Color(0xff000000)),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                        ),
            
          );
          }
        );
      },
    );
  }

  //message alert box
  void _showMessage(String message, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
              side: const BorderSide(color: Color(0xff13322b), width: 2)),
          title: Center(
              child: Text(
            title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xff13322b)),
          )),
          content: Text(message,
              style: const TextStyle(fontSize: 16, color: Color(0xff13322b))),
          actions: <Widget>[
            TextButton(
              child: const Text("OK",
                  style: TextStyle(fontSize: 16, color: Color(0xff13322b))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
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
        final Tangent tangent = pathMetric.getTangentForOffset(distance) ??
            const Tangent(Offset.zero, Offset.zero);

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
