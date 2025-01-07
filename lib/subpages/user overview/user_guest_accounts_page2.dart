import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserGuestAccountsPage2 extends StatefulWidget {
    List<Map<String, dynamic>>? formDetails;
  final Function(bool isClicked) onNextPressed;
  
  UserGuestAccountsPage2({super.key, required this.formDetails, required this.onNextPressed});

  @override
  State<UserGuestAccountsPage2> createState() => _UserGuestAccountsPage2State();
}

class _UserGuestAccountsPage2State extends State<UserGuestAccountsPage2> {


  @override
  void initState() {
    super.initState();
  }

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Row with Logo, Text, and Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo and Text
              Row(
                children: [
                  // Logo (replace 'assets/logo.png' with your image path)
                  Container(
                    width: 50,
                    height: 50,
                    margin: const EdgeInsets.only(right: 8),
                    child: Image.asset(
                      'assets/Logo.png', 
                      fit: BoxFit.cover,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                      Text('${widget.formDetails![0]['db_admission_users_table']['first_name']} ${widget.formDetails![0]['db_admission_users_table']['last_name']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Roboto-R',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.formDetails![0]['db_admission_users_table']['email_address']} / ${widget.formDetails![0]['db_admission_users_table']['contact_no']}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Roboto-R',
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(
                Icons.more_vert,
                color: Colors.black,
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Three Copies of Rows in Containers
          SizedBox(
                    height: 300,
                    width: 1500,
            child: Expanded(
              child: ListView.builder(
                itemCount: widget.formDetails!.length,
                itemBuilder: (context, index) {
                  final admissionData = widget.formDetails![index]['db_admission_table'];
                  final applicationId = admissionData['admission_form_id'] ?? 'N/A'; // Handle null values gracefully
                  final fullName = '${admissionData['first_name']} ${admissionData['last_name']}'; // Handle null values gracefully
                  String dateCreatedString = admissionData['created_at'];
                  DateTime dateCreated = DateTime.parse(dateCreatedString);
                  String formattedDate = formatDate(dateCreated);
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
                    ),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
            children: [
              // Second Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Avoid alignment issues
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildInfoColumn(
                      label: 'Application ID',
                      value: applicationId,
                      scale: scale,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: _buildInfoColumn(
                      label: 'Applicant Name',
                      value: fullName,
                      scale: scale,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 180,
                    child: _buildInfoColumn(
                      label: 'Grade Level',
                      value: admissionData['level_applying_for'], // Replace with dynamic data if available
                      scale: scale,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildInfoColumn(
                      label: 'Application Status',
                      value: admissionData['admission_status'].toUpperCase(), // Replace with dynamic data if available
                      scale: scale,
                    ),
                  ),
                  const SizedBox(width: 16),

                Expanded(
               flex: 2,
                child: _buildInfoColumn(
                  label: 'Date Created',
                  value: formattedDate, // Replace with dynamic data if available
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
                        'Action',
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
            
              const SizedBox(height: 16),
            
              // Third Row

            ],
                    ),
                  );
                },
              ),
            ),
          ),


             Row(
  mainAxisAlignment: MainAxisAlignment.start, // Aligns the content to the left
  children: [
    const Text(
      'Number of Applications: ',
      style: TextStyle(
        fontSize: 14, // Adjust the font size as needed
        fontWeight: FontWeight.bold,
      ),
    ),
    Text(widget.formDetails!.length.toString(), // Display the number of applications
      style: const TextStyle(
        fontSize: 14,
        color: Colors.blue, // You can customize the color
      ),
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
