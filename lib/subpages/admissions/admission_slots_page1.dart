import 'dart:convert';

import 'package:cdbs_admin/bloc/admission_bloc/admission_bloc.dart';
import 'package:cdbs_admin/bloc/auth/auth_bloc.dart';
import 'package:cdbs_admin/class/admission_forms.dart';
import 'package:cdbs_admin/shared/api.dart';
import 'package:cdbs_admin/subpages/login_page.dart';
import 'package:cdbs_admin/widget/custom_spinner.dart';
import 'package:cdbs_admin/widget/custom_textform_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;

class AdmissionSlotsPage1 extends StatefulWidget {
  const AdmissionSlotsPage1({super.key});

  @override
  State<AdmissionSlotsPage1> createState() => _AdmissionSlotsPage1State();
}

class _AdmissionSlotsPage1State extends State<AdmissionSlotsPage1> {
//List<bool> checkboxStates = List.generate(10, (_) => false);
  late ApiService _apiService;
  TextEditingController slotController = TextEditingController();
  TextEditingController gradeController = TextEditingController();
  bool isLoading = false;
  late Stream<List<Map<String, dynamic>>> gradeSlot;
  List<Map<String, dynamic>> requests = [];
  List<Map<String, dynamic>> filteredRequest = [];

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(apiUrl); // Replace with your actual API URL
    gradeSlot = _apiService.streamGradeSlot(supabaseUrl, supabaseKey);
    // Initialize the service with your endpoint
  }

  final List<String> gradeOrder = [
    'Pre-kinder',
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
    'Grade 12',
  ];

  List<Map<String, dynamic>> sortSlots(List<Map<String, dynamic>> slots) {
    return slots..sort((a, b) {
      int indexA = gradeOrder.indexOf(a['level_applying']);
      int indexB = gradeOrder.indexOf(b['level_applying']);
      return indexA.compareTo(indexB);
    });
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
              stream: gradeSlot,
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
                filteredRequest = sortSlots(requests);

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

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Slots',
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
                            child: BlocConsumer<AdmissionBloc, AdmissionState>(
                              listener: (context, state) {},
                              builder: (context, state) {
                                if (state is AdmissionIsLoading) {
                                  isLoading = state.isLoading;
                                }
                                return SizedBox(
                                  width: 500,
                                  height: 350,
                                  child: isLoading
                                      ? const CustomSpinner(
                                          color: Color(
                                              0xff13322b), // Change the spinner color if needed
                                          size:
                                              60.0, // Change the size of the spinner if needed
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'New Slot Form',
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontFamily: "Roboto-R",
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              // Date Field
                                              const Text(
                                                'Select Grade Level',
                                                style: TextStyle(fontSize: 11),
                                              ),
                                              const SizedBox(height: 8),
                                              // First Row of Dropdowns
                                              DropdownButtonFormField<String>(
                                                items: [
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
                                                  'Grade 12',
                                                ]
                                                    .map((grade) =>
                                                        DropdownMenuItem(
                                                          value: grade,
                                                          child: Text(grade),
                                                        ))
                                                    .toList(),
                                                onChanged: (value) {
                                                  // Handle change
                                                  setState(() {
                                                    gradeController.text =
                                                        value!;
                                                  });
                                                },
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                ),
                                              ),
                                              // Expanded Dropdow
                                              const SizedBox(height: 16),
                                              const Text(
                                                'Slots',
                                                style: TextStyle(fontSize: 11),
                                              ),
                                              const SizedBox(height: 8),
                                              CustomTextFormField(
                                                  label: const Row(children: [
                                                    Text('',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black)),
                                                    Text(' *',
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ]),
                                                  labelStyle: const TextStyle(
                                                    color: Color(0xff13322b),
                                                    fontSize: 16,
                                                  ),
                                                  controller: slotController,
                                                  isNumeric: true,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
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
                                                      context
                                                          .read<AdmissionBloc>()
                                                          .add(IsLoadingClicked(
                                                              true));
                                                      try {
                                                        final response =
                                                            await http.post(
                                                          Uri.parse(
                                                              '$apiUrl/api/admin/create_slot'),
                                                          headers: {
                                                            'Content-Type':
                                                                'application/json',
                                                            'supabase-url':
                                                                supabaseUrl,
                                                            'supabase-key':
                                                                supabaseKey,
                                                          },
                                                          body: json.encode({
                                                            'slot_available':
                                                                slotController
                                                                    .text,
                                                            'level_applying':
                                                                gradeController
                                                                    .text, // Send customer_id in the request body
                                                            'slot_status':
                                                                'open',
                                                          }),
                                                        );

                                                        if (response
                                                                .statusCode ==
                                                            200) {
                                                          final responseBody =
                                                              jsonDecode(
                                                                  response
                                                                      .body);
                                                          context
                                                              .read<
                                                                  AdmissionBloc>()
                                                              .add(
                                                                  IsLoadingClicked(
                                                                      false));
                                                          Navigator.of(context)
                                                              .popUntil((route) =>
                                                                  route
                                                                      .isFirst);
                                                          showMessageDialog(
                                                              context,
                                                              'New slot created',
                                                              false);
                                                        } else {
                                                          // Handle failure
                                                          final responseBody =
                                                              jsonDecode(
                                                                  response
                                                                      .body);
                                                          print(
                                                              'Error: ${responseBody['error']}');
                                                          context
                                                              .read<
                                                                  AdmissionBloc>()
                                                              .add(
                                                                  IsLoadingClicked(
                                                                      false));
                                                          Navigator.of(context)
                                                              .popUntil((route) =>
                                                                  route
                                                                      .isFirst);
                                                          showMessageDialog(
                                                              context,
                                                              'Error slot not created',
                                                              true);
                                                        }
                                                      } catch (error) {
                                                        // Handle error (e.g., network error)
                                                        print('Error: $error');
                                                        context
                                                            .read<
                                                                AdmissionBloc>()
                                                            .add(
                                                                IsLoadingClicked(
                                                                    false));
                                                        Navigator.of(context)
                                                            .popUntil((route) =>
                                                                route.isFirst);
                                                        showMessageDialog(
                                                            context,
                                                            'Error in connection',
                                                            true);
                                                      }
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xff012169),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Submit',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily:
                                                              'Roboto-R',
                                                          fontSize: 13),
                                                    ),
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
                                                        gradeController.text =
                                                            '';
                                                        slotController.text =
                                                            '';
                                                      });
                                                      Navigator.of(context)
                                                          .pop(); // Close the modal
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color(
                                                              0xffD3D3D3),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontFamily:
                                                              'Roboto-R',
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                );
                              },
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
                        'Add Grade Slot',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: 'Roboto-R',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Grade Level',
                      style: TextStyle(
                          fontSize: 16 * scale, fontFamily: 'Roboto-L'),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Slots',
                      style: TextStyle(
                          fontSize: 16 * scale, fontFamily: 'Roboto-L'),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Status',
                      style: TextStyle(
                          fontSize: 16 * scale, fontFamily: 'Roboto-L'),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.grey, thickness: 1),

              Expanded(
                child: ListView.builder(
                  itemCount: filteredRequest.length,
                  itemBuilder: (context, index) {
                    final request = filteredRequest[index];
                    print(filteredRequest);
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(request['level_applying'],
                                style: TextStyle(
                                    fontFamily: 'Roboto-R',
                                    fontSize: 16 * scale),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('${request['admission_count'].toString()}/${request['slot_available'].toString()}',
                                style: TextStyle(
                                    fontFamily: 'Roboto-R',
                                    fontSize: 16 * scale),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text( request['admission_count']!=request['slot_available']?
                                request['slot_status'].toUpperCase():'CLOSED',
                                style: TextStyle(
                                    fontFamily: 'Roboto-R',
                                    fontSize: 16 * scale),
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
          ),
        );
              }
            );
          }
        return Container();
          
      },
    ));
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
                        border: Border.all(
                            color:
                                isValid ? Colors.red : const Color(0XFF012169),
                            width: 2),
                      ),
                      child: Center(
                        child: Icon(
                          isValid ? Icons.close_rounded : Icons.check_rounded,
                          color: isValid ? Colors.red : const Color(0XFF012169),
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Success Message Text
                    Text(
                      message,
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
                      minimumSize: const Size(
                          double.infinity, 50), // Expand width and set height
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
