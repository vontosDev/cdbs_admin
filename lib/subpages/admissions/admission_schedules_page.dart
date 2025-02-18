import 'dart:async';
import 'package:cdbs_admin/bloc/admission_bloc/admission_bloc.dart';
import 'package:cdbs_admin/subpages/admissions/admission_schedules_page2.dart';
import 'package:cdbs_admin/widget/multiselect_dialog.dart';
import 'package:intl/intl.dart';
import 'package:cdbs_admin/bloc/auth/auth_bloc.dart';
import 'package:cdbs_admin/class/admission_forms.dart';
import 'package:cdbs_admin/shared/api.dart';
//import 'package:cdbs_admin/subpages/landing_page.dart';
import 'package:cdbs_admin/subpages/login_page.dart';
//import 'package:cdbs_admin/subpages/page3.dart';
//import 'package:cdbs_admin/subpages/s1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdmissionSchedulesPage extends StatefulWidget {
  const AdmissionSchedulesPage({super.key});

  @override
  State<AdmissionSchedulesPage> createState() => _AdmissionSchedulesPageState();
}



class _AdmissionSchedulesPageState extends State<AdmissionSchedulesPage> {
  //List<bool> checkboxStates = List.generate(10, (_) => false);
  late ApiService _apiService;
  // Variable to track current action
  int _selectedAction = 0; // 0: Default, 1: View, 2: Reminder, 3: Deactivate
  late Stream<List<Map<String, dynamic>>> admissionForms;
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> filteredRequest = [];
  List<Map<String, dynamic>>? formDetails;
  
  TextEditingController dateController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController gradeController = TextEditingController();
  TextEditingController slotController = TextEditingController();
  TextEditingController cancelController = TextEditingController();

  final List<String> grades = [
    'Pre-Kinder',
    'Kinder',
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
    'Grade 6',
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10',
    'Grade 11',
    'Grade 12'
  ];

  List<String> selectedGrades = [];
    
  @override
  void initState() {
    super.initState();
    _apiService = ApiService(apiUrl); // Replace with your actual API URL
    admissionForms = _apiService.streamSchedule(supabaseUrl, supabaseKey);
    // Initialize the service with your endpoint
  }

  String convertTimeTo24HourFormat(String time12HourFormat) {
  // Parse the 12-hour time format string into a DateTime object
    DateFormat inputFormat = DateFormat("hh:mm a");
    DateTime dateTime = inputFormat.parse(time12HourFormat);

    // Format the DateTime object into a 24-hour time format (HH:mm:ss)
    DateFormat outputFormat = DateFormat("HH:mm:ss");
    return outputFormat.format(dateTime);
  }


  String formatDate(DateTime date) {
    final DateTime localDate = date.toLocal(); // Converts to local time zone

  final DateFormat formatter = DateFormat('dd-MM-yyyy');
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

  String formatTime(String time) {
  // Parse the time string into a DateTime object. 
  // For example, "8:00" should be parsed into a DateTime object with 12:00 AM
  final DateTime parsedTime = DateFormat('HH:mm').parse(time);

  // Format the DateTime object into a 12-hour format with AM/PM
  final DateFormat formatter = DateFormat('hh:mm a'); // 'hh' for 12-hour format, 'a' for AM/PM
  
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



@override
void dispose() {
  startTimeController.dispose();
  endTimeController.dispose();
  super.dispose();
}

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
                filteredRequest = requests;
                List<bool> checkboxStates = List.generate(filteredRequest.length, (_) => false);
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
            if (_selectedAction == 0) ...[

Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    Text(
      'Schedules',
      style: TextStyle(
        color: const Color(0xff222222),
        fontFamily: "Roboto-L",
        fontSize: 22 * scale,
      ),
    ),
    const Spacer(),
    SizedBox(
      width: 178,
      height: 37,
      child: ElevatedButton(
        onPressed: () {
showDialog(
  context: context,
  builder: (context) => Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    child: SizedBox(
      width: 500,
      height: 520,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'New Schedule Form',
              style: TextStyle(
                fontSize: 22,
                fontFamily: "Roboto-R",
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 16),
            // Date Field
            const Text(
              'Exam Date',
              style: TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 8),
            TextField(
  controller: dateController, // Attach the controller to the TextField
  decoration: InputDecoration(
    hintText: 'Select date',
    suffixIcon: const Icon(Icons.calendar_today),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),
  readOnly: true,
  onTap: () async {
    // Open date picker
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      // Update the text field with the selected date
      dateController.text = selectedDate.toLocal().toString().split(' ')[0];
    }
  },
),
            const SizedBox(height: 16),
            // First Row of Dropdowns
            Row(
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exam Start Time',
            style: TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: startTimeController, // Controller for start time
            decoration: InputDecoration(
              hintText: 'Select start time',
              suffixIcon: const Icon(Icons.access_time),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            readOnly: true,
            onTap: () async {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                // Update the text field with the selected time
                startTimeController.text = pickedTime.format(context);
              }
            },
          ),
        ],
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exam End Time',
            style: TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: endTimeController, // Controller for end time
            decoration: InputDecoration(
              hintText: 'Select end time',
              suffixIcon: const Icon(Icons.access_time),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            readOnly: true,
            onTap: () async {
              final TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                // Update the text field with the selected time
                endTimeController.text = pickedTime.format(context);
              }
            },
          ),
        ],
      ),
    ),
  ],
),


            const SizedBox(height: 16),
            // Expanded Dropdown
            const Text(
              'Location',
              style: TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 8),
TextField(
  controller: locationController,
  decoration: InputDecoration(
    hintText: "Lobby", // Placeholder text
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),
  enabled: false, // Disable the TextField
  onChanged: (value) {
    // Handle text input (won't be called when disabled)
  },
),


            const SizedBox(height: 16),
            // Second Row of Dropdowns
            Row(
              children: [
                Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Grade Level',
        style: TextStyle(fontSize: 11),
      ),
      const SizedBox(height: 8),
      /*DropdownButtonFormField<String>(
        items: [
          'Pre-Kinder & Kinder',
          'Grade 1',
          'Grade 2',
          'Grade 3',
          'Grade 4 - 6',
          'Grade 7 - 12',
        ]
        .map((grade) => DropdownMenuItem(
              value: grade,
              child: Text(grade),
            ))
        .toList(),
        onChanged: (value) {
          // Handle change
          setState(() {
            gradeController.text=value!;
          });
        },
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),*/
      GestureDetector(
              onTap: () async {
                final List<String>? result = await showDialog(
                  context: context,
                  builder: (context) => MultiSelectDialog(
                    items: grades,
                    selectedItems: selectedGrades,
                  ),
                );
                if (result != null) {
                  setState(() {
                    selectedGrades = result;
                    selectedGrades.sort((a, b) => grades.indexOf(a).compareTo(grades.indexOf(b)));
                    gradeController.text = selectedGrades.join(', ');
                  });
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: gradeController,
                  decoration: const InputDecoration(
                    hintText: 'Select Grades',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            )
    ],
  ),
),








                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Slots',
                        style: TextStyle(fontSize: 11),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: slotController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onChanged: (value) {
                          // Handle text input
                        },
                      ),

                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Submit Button
            Center(
              child: SizedBox(
                width: 289,
                height: 35,
                child: ElevatedButton(
                  onPressed: () async {
                    bool isValid =false;
                    if(startTimeController.text.isEmpty || endTimeController.text.isEmpty || dateController.text.isEmpty || selectedGrades.isEmpty || slotController.text.isEmpty){
                      showMessageDialog(context, 'All fields are required', true);
                    }
                    else{
                      if(startTimeController.text.isNotEmpty && endTimeController.text.isNotEmpty){
                        isValid =validateAndConvertTime(startTimeController.text, endTimeController.text);
                        if(isValid){
                        showMessageDialog(context, 'Invalid time range: Start and end times must be between 08:00 AM and 05:00 PM, with the start time before the end time.', isValid);
                        }
                      }
                      try {
                      final response = await http.post(Uri.parse('$apiUrl/api/admin/create_exam_schedule'),
                                              headers: {
                                                'Content-Type': 'application/json',
                                                'supabase-url': supabaseUrl,
                                                'supabase-key': supabaseKey,
                                              },
                                              body: json.encode({
                                                'exam_date': dateController.text,
                                                'start_time':startTimeController.text,  // Send customer_id in the request body
                                                'end_time':endTimeController.text,
                                                'location':'Lobby',
                                                'grade_level':gradeController.text,
                                                'slots':slotController.text
                                              }),
                                            );

                                            if (response.statusCode == 200) {
                                              final responseBody = jsonDecode(response.body);
                                              Navigator.of(context).popUntil((route) => route.isFirst);
                                              showMessageDialog(context, 'The exam schedule has been successfully created.', isValid);
                                              setState(() {
                                                dateController.text='';
                                                startTimeController.text='';
                                                endTimeController.text='';
                                                locationController.text='';
                                                gradeController.text='';
                                                slotController.text='';
                                                selectedGrades.clear();
                                              });
                                            } else {
                                              // Handle failure
                                              final responseBody = jsonDecode(response.body);
                                              print('Error: ${responseBody['error']}');
                                              showMessageDialog(context, '${responseBody['error']}', true);
                                            }
                                          } catch (error) {
                                            // Handle error (e.g., network error)
                                            print('Error: $error');
                                          }
                    }
                    
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff012169),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text('Submit', style: TextStyle(color: Colors.white, fontFamily: 'Roboto-R', fontSize: 13),),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Cancel Button
            Center(
              child: SizedBox(
                width: 289,
                height: 35,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      dateController.text='';
                      startTimeController.text='';
                      endTimeController.text='';
                      locationController.text='';
                      gradeController.text='';
                      slotController.text='';
                      selectedGrades.clear();
                    });
                    Navigator.of(context).pop(); // Close the modal
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffD3D3D3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text('Cancel', style: TextStyle(color: Colors.black, fontFamily: 'Roboto-R', fontSize: 13),),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);


        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff012169),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: const Text(
          'Add New Schedule',
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Roboto-R',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    const SizedBox(width: 16), // Space between button and search bar
    SizedBox(
      width: 226 * scale,
      height: 32 * scale,
      child: TextField(
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
                    'EXAM DATE',
                    style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'EXAM TIME',
                    style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'MEETING PLACE',
                    style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'GRADE LEVEL',
                    style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'SLOTS',
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

                  String dateCreatedString = request['create_at'];
                  DateTime dateCreated = DateTime.parse(dateCreatedString);
                  String formattedDate = formatDate(dateCreated);

                  String examDate = request['exam_date'];
                  DateTime dateExam = DateTime.parse(examDate);
                  String formattedExamDate = formatDate(dateExam);

                  String startTime = formatTime(request['start_time']);
                  String endTime = formatTime(request['end_time']);
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Text(formattedExamDate,
                                  style: TextStyle(fontSize: 16 * scale),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('$startTime - $endTime',
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(request['location'],
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(request['grade_level'].toUpperCase(),
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                            ),
                          ),
                          const SizedBox(width: 40,),
                          Expanded(
                            flex: 1,
                            child: Text(request['reservation_count']==request['slots']?'FULL':'${request['reservation_count']}/${request['slots']}',
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
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
                                onSelected: (value) async {
                                  List<Map<String, dynamic>> members = await ApiService(apiUrl).fetchScheduleById(request['schedule_id'], supabaseUrl, supabaseKey);
                                     if(members.isNotEmpty){
                                             
                                        setState(()  {
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
  child: InkWell(
    onTap: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: SizedBox(
              width: 349.0,
              height: 320.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Section with Heading and TextField
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   "CANCEL",
                        //   style: TextStyle(
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        const SizedBox(height: 10),
                        const Text("Please provide a reason for cancellation:"),
                        const SizedBox(height: 10),
                        TextField(
                          controller: cancelController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Enter cancellation reason: ",
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  // Divider
                  const Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(thickness: 1),
                  ),
                  // Bottom Section with Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      children: [
                        // Close Button
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
                        const SizedBox(height: 10),
                        // Submit Button
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
                              try {
                      final response = await http.post(Uri.parse('$apiUrl/api/admin/cancel_exam_schedule'),
                                              headers: {
                                                'Content-Type': 'application/json',
                                                'supabase-url': supabaseUrl,
                                                'supabase-key': supabaseKey,
                                              },
                                              body: json.encode({
                                                'schedule_id': request['schedule_id'],
                                                'cancel_reason':cancelController.text
                                              }),
                                            );

                                            if (response.statusCode == 200) {
                                              final responseBody = jsonDecode(response.body);
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
                    "Successfully cancelled!",
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
                                            }
                                          } catch (error) {
                                            // Handle error (e.g., network error)
                                            print('Error: $error');
                                          }
                             
                              
                            },
                            child: const Text(
                              "Submit",
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
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
    },
    child: Row(
      children: [
        const Icon(Icons.block, color: Colors.black),
        SizedBox(width: 8 * scale),
        Text(
          "CANCEL",
          style: TextStyle(fontSize: 16 * scale, color: Colors.black),
        ),
      ],
    ),
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
    return Container(
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
       AdmissionSchedulesPage2(formDetails: details, onNextPressed: (bool isClicked) {
         context.read<AdmissionBloc>().add(MarkAsCompleteClicked(isClicked));
       },userId: userId,),
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

  bool isValidWorkingHourRange(DateTime start, DateTime end) {
  // Define working hours as 08:00 AM to 05:00 PM (17:00)
  const int workingStartHour = 8;
  const int workingEndHour = 17;

  // Compare only time (ignore date)
  if (start.hour < workingStartHour || start.hour >= workingEndHour) {
    return false; // Start time is outside working hours
  }

  if (end.hour < workingStartHour || (end.hour > workingEndHour || (end.hour == workingEndHour && end.minute > 0))) {
    return false; // End time is outside working hours
  }

  // Ensure that the start time is strictly before the end time
  if (start.isAtSameMomentAs(end) || start.isAfter(end)) {
    return false; // Start time must be before the end time
  }

  return true; // The time range is valid
}

bool validateAndConvertTime(String startTime12Hour, String endTime12Hour) {
  try {

    
    // Parse times in 12-hour format
    DateTime startTime = DateFormat("hh:mm a").parse(startTime12Hour);
    DateTime endTime = DateFormat("hh:mm a").parse(endTime12Hour);    
    // Rebuild times on the same arbitrary date (e.g., 2024-01-01) to normalize comparisons
    DateTime workingStartTime = DateTime(2024, 12, 13, startTime.hour, startTime.minute);
    DateTime workingEndTime = DateTime(2024, 12, 13, endTime.hour, endTime.minute);

    // Validate the time range



    if (!isValidWorkingHourRange(workingStartTime, workingEndTime)) {
      
      return true; // Invalid time range
      
    }


    // Convert to 24-hour format for additional processing or debugging if needed
    String start24 = DateFormat("HH:mm").format(workingStartTime);
    String end24 = DateFormat("HH:mm").format(workingEndTime);

    

    print("Converted Start Time: $start24, End Time: $end24");

    return false; // Valid time range
  } catch (e) {
    DateTime startTime = DateFormat("hh:mm a").parse(startTime12Hour);
    DateTime endTime = DateFormat("hh:mm a").parse(endTime12Hour);
    print(startTime);
    print(endTime);
    return true; // Error in parsing or validation
  }
}


void showMessageDialog(BuildContext context, String message, bool isValid) {
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
                      border: Border.all(color: isValid ? Colors.red: const Color(0XFF012169), width: 2),
                    ),
                    child:  Center(
                      child: Icon(
                        isValid?Icons.close_rounded:Icons.check_rounded,
                        color: isValid ? Colors.red: const Color(0XFF012169),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Success Message Text
                  Text(message,
                    style: const TextStyle(
                      fontSize: 16,
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
}
}

