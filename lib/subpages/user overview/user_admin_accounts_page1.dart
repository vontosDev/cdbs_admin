import 'package:cdbs_admin/bloc/auth/auth_bloc.dart';
import 'package:cdbs_admin/class/admission_forms.dart';
import 'package:cdbs_admin/shared/api.dart';
import 'package:cdbs_admin/subpages/landing_page.dart';
import 'package:cdbs_admin/subpages/page3.dart';
import 'package:cdbs_admin/subpages/s1.dart';
import 'package:cdbs_admin/subpages/s2.dart';
import 'package:cdbs_admin/widget/custom_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserAdminAccountsPage1 extends StatefulWidget {
  const UserAdminAccountsPage1({super.key});

  @override
  State<UserAdminAccountsPage1> createState() => _UserAdminAccountsPage1State();
}



class _UserAdminAccountsPage1State extends State<UserAdminAccountsPage1> {
  

  int _selectedAction = 0; // 0: Default, 1: View, 2: Reminder, 3: Deactivate
  late Stream<List<Map<String, dynamic>>> admissionForms;
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> filteredRequest = [];
  late ApiService _apiService;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //controllers
  TextEditingController fnameController = TextEditingController();
  TextEditingController mnameController = TextEditingController();
  TextEditingController lnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController contactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(apiUrl); // Replace with your actual API URL
    admissionForms = _apiService.streamAdminForms(supabaseUrl, supabaseKey);
    // Initialize the service with your endpoint
  }

  
String formatDate(DateTime date) {
    final DateTime localDate = date.toLocal();
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');
    return formatter.format(localDate);
  }

//sample
  

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
            if (_selectedAction == 0) _buildDefaultContent(scale), // Default content
            if (_selectedAction == 1) _buildViewContent(scale), // View content
            if (_selectedAction == 2) _buildReminderContent(scale), // Reminder content
            if (_selectedAction == 3) _buildDeactivateContent(scale),
            if (_selectedAction == 0) ...[
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Admin Accounts',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New User',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: "Roboto-R",
                  fontWeight: FontWeight.normal,
                ),
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
              'First name',
              style: TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              label:const Row(
                children: [
                  Text('', style: TextStyle(color: Colors.black)),
                  Text(' *', style: TextStyle(color: Colors.red)), 
                  ]),
                  labelStyle: const TextStyle(
                    color: Color(0xff13322b),
                    fontSize: 16,
                    ),
                    controller: fnameController,
                    isNumeric: false,
                    validator: (value) {
                    if (value == null || value.isEmpty) {
                       return '*';
                    }
                    return null;
                    }),
          ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Middle name',
              style: TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              label:const Row(
                children: [
                  Text('', style: TextStyle(color: Colors.black)),
                  Text(' *', style: TextStyle(color: Colors.red)), 
                  ]),
                  labelStyle: const TextStyle(
                    color: Color(0xff13322b),
                    fontSize: 16,
                    ),
                    controller: mnameController,
                    isNumeric: false,
                    validator: (value) {
                      return null;
                    
                    }),
          ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last name',
              style: TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              label:const Row(
                children: [
                  Text('', style: TextStyle(color: Colors.black)),
                  Text(' *', style: TextStyle(color: Colors.red)), 
                  ]),
                  labelStyle: const TextStyle(
                    color: Color(0xff13322b),
                    fontSize: 16,
                    ),
                    controller: lnameController,
                    isNumeric: false,
                    validator: (value) {
                    if (value == null || value.isEmpty) {
                       return '*';
                    }
                    return null;
                    }),
          ],
                ),
              ),
            ],
          ),
          
          
              const SizedBox(height: 16),
              // Expanded Dropdown
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email Address',
                          style: TextStyle(fontSize: 11),
                        ),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                        label:const Row(
                          children: [
                            Text('', style: TextStyle(color: Colors.black)),
                            Text(' *', style: TextStyle(color: Colors.red)), 
                            ]),
                            labelStyle: const TextStyle(
                              color: Color(0xff13322b),
                              fontSize: 16,
                              ),
                              controller: emailController,
                              isNumeric: false,
                              isEmail: true,
                              validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '*';
                              }
                              return null;
                              }),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Password',
                          style: TextStyle(fontSize: 11),
                        ),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                        label:const Row(
                          children: [
                            Text('', style: TextStyle(color: Colors.black)),
                            Text(' *', style: TextStyle(color: Colors.red)), 
                            ]),
                            labelStyle: const TextStyle(
                              color: Color(0xff13322b),
                              fontSize: 16,
                              ),
                              controller: passwordController,
                              isNumeric: false,
                              isEmail: true,
                              isObscure: true,
                              validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '*';
                              }
                              return null;
                              }),
                      ],
                    ),
                  ),
                ],
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
                            'Role',
                            style: TextStyle(fontSize: 11),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                      items: [
                        {'label': 'Admin', 'value': 1},
                        {'label': 'Sisters', 'value': 2},
                        {'label': 'Principal', 'value': 3},
                        {'label': 'IT', 'value': 4},
                        {'label': 'Cashier', 'value': 5},
                        {'label': 'Registrar', 'value': 6},
                        {'label': 'Admission', 'value': 7},
                        {'label': 'Center Learner Wellness', 'value': 8},
                      ].map((grade) => DropdownMenuItem<int>(
                                value: grade['value'] as int,
                                child: Text(grade['label'].toString()),
                              ))
                          .toList(),
                      onChanged: (int? value) {
                        // Handle change
                        if (value != null) {
                          setState(() {
                            roleController.text=value.toString();
                          });
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      hint: const Text('Select Admin Role'),
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
                          'Department',
                          style: TextStyle(fontSize: 11),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          items: [
                            {'label': 'School Administration', 'value': 2},
                            {'label': 'Admissions', 'value': 3},
                            {'label': 'Registrar', 'value': 4},
                            {'label': 'Accounting', 'value': 5},
                            {'label': 'Academics- Primary', 'value': 6},
                            {'label': 'Academics - Secondary', 'value': 7},
                            {'label': 'Center Learner Wellness', 'value': 8},
                            {'label': 'Information Technology', 'value': 9},
                          ].map((grade) => DropdownMenuItem<int>(
                                    value: grade['value'] as int,
                                    child: Text(grade['label'].toString()),
                                  ))
                              .toList(),
                          onChanged: (int? value) {
                            // Handle change
                            if (value != null) {
                              setState(() {
                                // Use the numeric value for your logic
                                departmentController.text=value.toString();
                              });
                            }
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          hint: const Text('Select Department'),
                        )
          
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                          'Contact Number',
                          style: TextStyle(fontSize: 11),
                        ),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                        label:const Row(
                          children: [
                            Text('', style: TextStyle(color: Colors.black)),
                            Text(' *', style: TextStyle(color: Colors.red)), 
                            ]),
                            labelStyle: const TextStyle(
                              color: Color(0xff13322b),
                              fontSize: 16,
                              ),
                              controller: contactController,
                              isNumeric: true,
                              maxLength: 11,
                              validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '*';
                              }
                              return null;
                              }),
                          
              const Spacer(),
              // Submit Button
              Center(
                child: SizedBox(
                  width: 289,
                  height: 35,
                  child: ElevatedButton(
                    onPressed: () async {
                      if(!_formKey.currentState!.validate())return;
                      
                      if(fnameController.text.isNotEmpty && lnameController.text.isNotEmpty && emailController.text.isNotEmpty && passwordController.text.isNotEmpty
                      && contactController.text.isNotEmpty
                      ){
                        try {
                        final response = await http.post(Uri.parse('$apiUrl/api/admin/add_admin'),
                                                headers: {
                                                  'Content-Type': 'application/json',
                                                  'supabase-url': supabaseUrl,
                                                  'supabase-key': supabaseKey,
                                                },
                                                body: json.encode({
                                                  'admin_type': int.parse(roleController.text),
                                                  'department_id':int.parse(departmentController.text),  // Send customer_id in the request body
                                                  'fname':fnameController.text,
                                                  'mname':mnameController.text,
                                                  'lname':lnameController.text,
                                                  'email':emailController.text,
                                                  'password':passwordController.text,
                                                  'contact_no':contactController.text,
                                                }),
                                              );
          
                                              if (response.statusCode == 200) {
                                                final responseBody = jsonDecode(response.body);
                                                Navigator.of(context).popUntil((route) => route.isFirst);
                                                showMessageDialog(context, 'New user created', false);
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
                        fnameController.text='';
                        mnameController.text='';
                        lnameController.text='';
                        emailController.text='';
                        passwordController.text='';
                        contactController.text='';
                        roleController.text='';
                        departmentController.text='';
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
          'Add New User',
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Roboto-R',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    const SizedBox(width: 16),
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
                // Expanded(
                //   flex: 1,
                //   child: Text(
                //     '',
                //     style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
                //   ),
                // ),

                // const SizedBox(width: 40,),

                Expanded(
                  flex: 3,
                  child: Text(
                    'NAME',
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
                    'ROLE',
                    style: TextStyle(fontSize: 16 * scale, fontFamily: 'Roboto-L'),
                  ),
                ),

                const SizedBox(width: 40,),

                Expanded(
                  flex: 3,
                  child: Text(
                    'DEPARTMENT',
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
    //               final processBy = request['db_admission_table']['db_admission_form_handler_table'].isNotEmpty
    // ? '${request['db_admission_table']['db_admission_form_handler_table'][0]['db_admin_table']['first_name']} ${request['db_admission_table']['db_admission_form_handler_table'][0]['db_admin_table']['last_name']}'
    // : '---';

                  // String dateCreatedString = request]['created_at'];
                  // DateTime dateCreated = DateTime.parse(dateCreatedString);
                  // String formattedDate = formatDate(dateCreated);
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Expanded(
                          //   flex: 1,
                          //   child: Row(
                          //     children: [
                          //       Checkbox(
                          //         value: checkboxStates[index],
                          //         onChanged: (value) {
                          //           setState(() {
                          //             checkboxStates[index] = value ?? false;
                          //           });
                          //         },
                          //         activeColor: const Color(0XFF012169), // Set the active color to pink
                          //       ),
                          //      /* Text(
                          //         request['admin_id'].toString(),
                          //         style: TextStyle(fontSize: 14 * scale),
                          //       ),*/
                          //     ],
                          //   ),
                          // ),

                          // const SizedBox(width: 40,),

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
                                  style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 40,),
                          
                          Expanded(
                            flex: 3,
                            child: Text(
                              request['email_address'],
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                            ),
                          ),

                          const SizedBox(width: 40,),

                          Expanded(
                            flex: 2,
                            child: Text(
                              request['db_admin_type']['admin_type'],
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                            ),
                          ),

                          const SizedBox(width: 40,),

                          Expanded(
                            flex: 3,
                            child: Text(
                              request['db_admin_department']['department'],
                              style: TextStyle(fontFamily: 'Roboto-R', fontSize: 16 * scale),
                            ),
                          ),

                          const SizedBox(width: 40,),
                            // Other table cells...
                            Expanded(
                              flex: 1,
                              child: PopupMenuButton<int>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) {
                                  setState(() {
                                    _selectedAction = value; // Change the selected action
                                  });
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    // value: 1,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.visibility, color: Color(0xff909590)),
                                        SizedBox(width: 8 * scale),
                                        Text("VIEW", style: TextStyle(fontSize: 18 * scale, color: const Color(0xff909590))),
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
  Widget _buildViewContent(double scale) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const S2Page(),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedAction = 0; // Go back to default content
              });
            },
            child: const Text("Go Back"),
          ),
        ],
      )
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
              // Centered Text
              const Center(
                // child: Text(
                //   "",
                //   style: TextStyle(
                //     fontSize: 22,
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
                      fontSize: 18,
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
                    style: TextStyle(fontSize: 18, color: Colors.white),
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

