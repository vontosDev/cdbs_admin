import 'package:cdbs_admin/bloc/admission_bloc/admission_bloc.dart';
import 'package:cdbs_admin/bloc/auth/auth_bloc.dart';
import 'package:cdbs_admin/class/admission_forms.dart';
import 'package:cdbs_admin/shared/api.dart';
import 'package:cdbs_admin/subpages/landing_page.dart';
import 'package:cdbs_admin/subpages/page3.dart';
import 'package:cdbs_admin/subpages/s1.dart';
import 'package:cdbs_admin/subpages/user%20overview/user_guest_accounts_page2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class UserGuestAccountsPage1 extends StatefulWidget {
  const UserGuestAccountsPage1({super.key});

  @override
  State<UserGuestAccountsPage1> createState() => _UserGuestAccountsPage1State();
}



class _UserGuestAccountsPage1State extends State<UserGuestAccountsPage1> {
  //List<bool> checkboxStates = List.generate(10, (_) => false);

    int _selectedAction = 0; // 0: Default, 1: View, 2: Reminder, 3: Deactivate
  late Stream<List<Map<String, dynamic>>> admissionForms;
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> filteredRequest = [];
  late ApiService _apiService;
   List<Map<String, dynamic>>? formDetails;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(apiUrl); // Replace with your actual API URL
    admissionForms = _apiService.streamRegisteredUser(supabaseUrl, supabaseKey);
    // Initialize the service with your endpoint
  }

  
String formatDate(DateTime date) {
    final DateTime localDate = date.toLocal();
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');
    return formatter.format(localDate);
  }


  String stringDate(DateTime date) {
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
                  'User Overview',
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
                  'Guest Accounts',
                  style: TextStyle(
                    color: const Color(0xff222222),
                    fontFamily: "Roboto-L",
                    fontSize: 32 * scale,
                  ),
                ),
                const Spacer(),
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
                  flex: 3,
                  child: Text(
                    'NAME',
                    style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),

                const SizedBox(width: 40,),

                Expanded(
                  flex: 2,
                  child: Text(
                    'CONTACT NO.',
                    style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),

                const SizedBox(width: 40,),

                Expanded(
                  flex: 3,
                  child: Text(
                    'EMAIL',
                    style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),

                const SizedBox(width: 40,),

                Expanded(
                  flex: 2,
                  child: Text(
                    'STATUS',
                    style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),

                const SizedBox(width: 40,),

                Expanded(
                  flex: 2,
                  child: Text(
                    'LAST LOGIN DATE',
                    style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),

                const SizedBox(width: 40,),

                const Expanded(flex: 1, child: SizedBox.shrink()),
              ],
            ),
            const Divider(color: Colors.grey, thickness: 1),
            Expanded(
              child: ListView.builder(
                itemCount: filteredRequest.length,
                itemBuilder: (context, index) {
                  final request = filteredRequest[index];
                  final fullName = '${request['first_name']} ${request['last_name']}';
                  String dateCreatedString;
                  DateTime dateCreated;
                  String formattedDate;
                  DateTime now= DateTime.now();
                  String today = DateFormat('dd-MM-yyyy').format(DateTime.now());
                  String loginDate;
                  if(request['last_login']!=null){
                    dateCreatedString= request['last_login'];
                    dateCreated = DateTime.parse(dateCreatedString);
                    formattedDate = formatDate(dateCreated);
                    loginDate=stringDate(dateCreated);
                  }else{
                    formattedDate='---';
                    loginDate='';
                  }
                  
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 3,
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
                                  fullName,
                                  style: TextStyle(fontSize: 16 * scale),
                                ),
                              ],
                            ),
                          ),


                          const SizedBox(width: 40,),

                          Expanded(
                            flex: 2,
                            child: Text(request['contact_no'],
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                            ),
                          ),

                          const SizedBox(width: 40,),
                          
                          Expanded(
                            flex: 3,
                            child: Text(request['email_address'],
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                            ),
                          ),

                          const SizedBox(width: 40,),

                          Expanded(
                            flex: 2,
                            child: Text(today==loginDate?'ACTIVE':"INACTIVE",
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                            ),
                          ),

                          const SizedBox(width: 40,),

                          Expanded(
                            flex: 2,
                            child: Text(
                              formattedDate ??"",
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                            ),
                          ),

                          const SizedBox(width: 40,),

                            // Other table cells...
                           Expanded(
  flex: 1,
  child: PopupMenuButton<int>(
    icon: const Icon(Icons.more_vert),
    onSelected: (value) async {

      List<Map<String, dynamic>> members = await ApiService(apiUrl).getUserAllRequest(request['user_id'], supabaseUrl, supabaseKey);
                                     if(members.isNotEmpty){
                                             
                                        setState(()  {
                                          formDetails=members;
                                          _selectedAction = value; // Change the selected action
                                        });
                                     }else{
                                      _showViewModal(context);
                                     }

      /*if (value == 1) {
        // Show the modal when "VIEW" is clicked
        _buildViewContent(scale, formDetails!, authState.uid);
      } else if (value == 2) {
        // Handle REMINDER action
        _showMessage('Reminder action', "Reminder");
      } else if (value == 3) {
        // Handle DEACTIVATE action
        _showMessage('Deactivate action', "Deactivate");
      }*/
    },
    itemBuilder: (context) => [
      PopupMenuItem(
        value: 1,
        child: Row(
          children: [
            const Icon(Icons.visibility, color: Colors.black),
            SizedBox(width: 8 * scale),
            Text("VIEW", style: TextStyle(fontSize: 18 * scale)),
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
 Widget _buildViewContent(double scale, List<Map<String, dynamic>> details, int userId) {

     return BlocConsumer<AdmissionBloc, AdmissionState>(
      listener: (context, state) {},
      builder: (context, state) {
              bool isButtonEnabled = false;

              // Enable button based on the state
              if (state is AdmissionStatusUpdated) {
                isButtonEnabled = state.isComplete;
              }
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
       UserGuestAccountsPage2(formDetails: details, onNextPressed: (bool isClicked) {
         context.read<AdmissionBloc>().add(MarkAsCompleteClicked(isClicked));
       }),
    ],
  ),
);
      }
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




//VIEW MODAL
void _showViewModal(BuildContext context) {
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
                //     fontSize: 32,
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
                        Icons.auto_stories_sharp,
                        color: Color(0XFF012169),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // No Form Submitted Text
                  const Text(
                    "No data entry found!",
                    style: TextStyle(
                      fontSize: 30,
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
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xff13322b)),
          )),
          content: Text(message,
              style: const TextStyle(fontSize: 18, color: Color(0xff13322b))),
          actions: <Widget>[
            TextButton(
              child: const Text("OK",
                  style: TextStyle(fontSize: 18, color: Color(0xff13322b))),
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

