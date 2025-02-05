//WHOLE APPLICANTIONS PAGE2

import 'package:cdbs_admin/bloc/admission_bloc/admission_bloc.dart';
import 'package:cdbs_admin/services/ggx_connection.dart';
import 'package:cdbs_admin/shared/api.dart';
import 'package:cdbs_admin/widget/checkbox_readonly.dart';
import 'package:cdbs_admin/widget/custom_spinner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;

class AdmissionApplicationsPage2 extends StatefulWidget {
  
  List<Map<String, dynamic>>? formDetails;
  final Function(bool isClicked) onNextPressed;
  String adminType;

  AdmissionApplicationsPage2({super.key, required this.formDetails, required this.onNextPressed, required this.adminType});

  @override
  State<AdmissionApplicationsPage2> createState() =>
      _AdmissionApplicationsPage2State();
}

class _AdmissionApplicationsPage2State
    extends State<AdmissionApplicationsPage2> {
  int _currentPage = 1; // Variable to track the current page (1, 2, or 3)
  TextEditingController othersController = TextEditingController();
  Set<String> selectedOptions = {};
  String heardAboutSchool ='';
  void onSelectionChanged(Set<String> selected) {
    setState(() {
      selectedOptions = selected;
    });
  }

  void _nextPage() {
    setState(() {
      if (_currentPage < 5) {
        _currentPage++;
        if(_currentPage==1){
          title='Personal Data';
        }else if(_currentPage==2 || _currentPage==3 || _currentPage==4){
          title='Family Background';
        }else{
          title='Special Concerns';
        }
      }
    });
  }

  void _previousPage() {
    setState(() {
      if (_currentPage > 1) {
        _currentPage--;
         if(_currentPage==1){
          title='Personal Data';
        }else if(_currentPage==2 || _currentPage==3 || _currentPage==4){
          title='Family Background';
        }else{
          title='Special Concerns';
        }
      }
    });
  }

bool isEditable = false;
bool isLastPage = false;
bool isLoading = false;

String originalUrl = '';
String encodedUrl='';
String noSibling='';

TextEditingController dateController = TextEditingController();
TextEditingController fnameController = TextEditingController();
TextEditingController mnameController = TextEditingController();
TextEditingController lnameController = TextEditingController();
TextEditingController schoolYearController = TextEditingController();
TextEditingController levelApplyingController = TextEditingController();
TextEditingController birthPlaceController = TextEditingController();
TextEditingController ageController = TextEditingController();
TextEditingController religionController = TextEditingController();
TextEditingController citizenshipController = TextEditingController();
TextEditingController acrController = TextEditingController();
TextEditingController addressController = TextEditingController();
TextEditingController postalController = TextEditingController();
TextEditingController contactController = TextEditingController();
TextEditingController languageSpokenController = TextEditingController();
TextEditingController companionController = TextEditingController();
TextEditingController siblingQuantityController = TextEditingController();


//special concern
TextEditingController specialConcernController = TextEditingController();
TextEditingController mdpConditionController = TextEditingController();
TextEditingController medicationController = TextEditingController();
TextEditingController interventionController = TextEditingController();


//father controllers details
TextEditingController fatherNameController = TextEditingController();
TextEditingController fatherAgeController = TextEditingController();
TextEditingController fatherEduAttainController = TextEditingController();
String? fatherEmploymentStatus;
String? fatherSalary;
TextEditingController fatherEmployedAtController = TextEditingController();
TextEditingController fatherOfficeAddressController = TextEditingController();
TextEditingController fatherContactController = TextEditingController();
TextEditingController fatherWorkPositionController = TextEditingController();
TextEditingController fatherSalaryScaleController = TextEditingController();
//mother controllers details
TextEditingController motherNameController = TextEditingController();
TextEditingController motherAgeController = TextEditingController();
TextEditingController motherEduAttainController = TextEditingController();
String? motherEmploymentStatus;
String? motherSalary;
TextEditingController motherEmployedAtController = TextEditingController();
TextEditingController motherOfficeAddressController = TextEditingController();
TextEditingController motherContactController = TextEditingController();
TextEditingController motherWorkPositionController = TextEditingController();
TextEditingController motherSalaryScaleController = TextEditingController();
//guardian
TextEditingController guardianNameController = TextEditingController();
TextEditingController guardianAgeController = TextEditingController();
TextEditingController guardianEduAttainController = TextEditingController();
String? guardianEmploymentStatus;
String? guardianSalary;
TextEditingController guardianEmployedAtController = TextEditingController();
TextEditingController guardianOfficeAddressController = TextEditingController();
TextEditingController guardianContactController = TextEditingController();
TextEditingController guardianWorkPositionController = TextEditingController();
TextEditingController guardianSalaryScaleController = TextEditingController();
String? guardianRelationTo;


String parentStatus = 'Married';
TextEditingController civilWeddingController = TextEditingController();
TextEditingController churchNameController = TextEditingController();

String selectedGender = '';
String dropdown1Value = 'Option 1';
String dropdown2Value = 'Option A';

int quantityReceived = 0;

String title = 'Personal Data';

List<TextEditingController> nameControllers = [];
List<TextEditingController> ageControllers = [];
List<TextEditingController> gradeLevelControllers = [];
List<TextEditingController> schoolBisControllers = [];

List<Widget> siblings = [];

  late TextEditingController name;
  late TextEditingController ageSibling;
  late TextEditingController gradeLevel;
  late TextEditingController schoolBis;


String? districtName;
String? city;
String? province;
var address;
var parts;
final GgxApi ggx = GgxApi();

Future<void> fetchDistrictName(String districtId) async {
    final apiUrl = '$ggxUrl/locations/districts/$districtId';
    var jwt = ggx.generateJwt();
    try {
      var response = await http.get(Uri.parse(apiUrl),
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          districtName = data['data'][0]['name'];
        });
      } else {
        setState(() {
          districtName = 'Error: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        districtName = 'Error: $e';
      });
    }
  }

  Future<void> fetchCityName(String cityId) async {
    final apiUrl = '$ggxUrl/locations/cities/$cityId';
    var jwt = ggx.generateJwt();
    try {
      var response = await http.get(Uri.parse(apiUrl),
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          city = data['data'][0]['name'];
        });
      } else {
        setState(() {
          city = 'Error: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        city = 'Error: $e';
      });
    }
  }

  Future<void> fetchProvinceName(String provinceId) async {
    final apiUrl = '$ggxUrl/locations/provinces/$provinceId';
    var jwt = ggx.generateJwt();
    try {
      var response = await http.get(Uri.parse(apiUrl),
      headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          province = data['data'][0]['name'];
        });
      } else {
        setState(() {
          province = 'Error: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        province = 'Error: $e';
      });
    }
  }

void addItemDescription(double scale) {
    // Ensure descriptionControllers list length matches quantityReceived
    while (nameControllers.length < quantityReceived) {
      nameControllers.add(TextEditingController());
      ageControllers.add(TextEditingController());
      gradeLevelControllers.add(TextEditingController());
      schoolBisControllers.add(TextEditingController());
    }
    while (nameControllers.length > quantityReceived) {
      TextEditingController removedController = nameControllers.removeLast();
      removedController.dispose(); // Dispose the removed controller
      TextEditingController removedQuantityController = ageControllers.removeLast();
      removedQuantityController.dispose(); // Dispose the removed controller
      TextEditingController removedpriceController = gradeLevelControllers.removeLast();
      removedpriceController.dispose();
      TextEditingController removedorderDocController = schoolBisControllers.removeLast();
      removedorderDocController.dispose();
    }
    List<Widget> newDescriptions = [];
    for (int i = 0; i < quantityReceived; i++) {
      name = nameControllers[i];
      ageSibling = ageControllers[i];
      gradeLevel = gradeLevelControllers[i];
      schoolBis = schoolBisControllers[i];
      newDescriptions.add(
        Column(
          children: [
            const SizedBox(height: 16),

              // 3rd Row - Divider
              const Divider(),


              const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
              child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // First Column: Fixed width 600
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Name*',
                              style: TextStyle(fontSize: 14, fontFamily: 'Roboto-R'), // Adjust font size as needed
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 400,
                              height: 40,
                              child: TextField(
                                controller: name,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
            
                        // Second Column: Fixed width 120
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Age*',
                              style: TextStyle(fontSize: 14, fontFamily: 'Roboto-R'),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 120,
                              height: 40,
                              child: TextField(
                                controller: ageSibling,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
            
                        // Third Column: Expanded
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Grade Level/ Course/ Occupation*',
                                style: TextStyle(fontSize: 14, fontFamily: 'Roboto-R'),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: gradeLevel,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
            
                        // Fourth Column: Expanded
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'School/ Business Office*',
                                style: TextStyle(fontSize: 14, fontFamily: 'Roboto-R'),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: schoolBis,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      );
    }

    try {
      setState(() {
        siblings = newDescriptions;
      });
    } catch (e) {
      print('Error in putaway addItemDescription: $e');
    }
  }


  void updateQuantity() {
    try {
      setState(() {
        quantityReceived = int.tryParse(siblingQuantityController.text) ?? 0;
      });
    } catch (e) {
      print('Error in putaway updateQuantity: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    address = widget.formDetails![0]['db_admission_table']['address'] as String;
    parts = address.split('|');
    if (parts.isNotEmpty) {
      final districtId = parts[1];
      final cityId = parts[2]; // Extract the first number (13817)
      final provinceId = parts[3];
      fetchDistrictName(districtId);
      fetchCityName(cityId);
      fetchProvinceName(provinceId);
    }
    heardAboutSchool =widget.formDetails![0]['db_admission_table']['db_survey_table'][0]['heard_about_school'];
    List<String> heardAboutList = heardAboutSchool.split(',');
    selectedOptions.addAll(heardAboutList);

     selectedGender =widget.formDetails![0]['db_admission_table']['sex'] ??'';
     fnameController.text=widget.formDetails![0]['db_admission_table']['first_name']??'';
     mnameController.text=widget.formDetails![0]['db_admission_table']['middle_name']??'';
     lnameController.text=widget.formDetails![0]['db_admission_table']['last_name']??'';
     schoolYearController.text=widget.formDetails![0]['db_admission_table']['school_year']??'';
     levelApplyingController.text=widget.formDetails![0]['db_admission_table']['level_applying_for']??'';
     dateController.text=widget.formDetails![0]['db_admission_table']['date_of_birth']??'';
     birthPlaceController.text=widget.formDetails![0]['db_admission_table']['place_of_birth']??'';
     religionController.text=widget.formDetails![0]['db_admission_table']['religion']??'';
     citizenshipController.text=widget.formDetails![0]['db_admission_table']['citizenship']??'';
     acrController.text=widget.formDetails![0]['db_admission_table']['acr_number']??'';
     
     postalController.text=widget.formDetails![0]['db_admission_table']['zip_postal_code']??'';
     contactController.text=widget.formDetails![0]['db_admission_table']['contact_no']??'';
     languageSpokenController.text=widget.formDetails![0]['db_admission_table']['language_dialect_spoken']??'';
     companionController.text=widget.formDetails![0]['db_admission_table']['usual_companion_at_home']??'';

      
     DateTime dateOfBirth = DateTime.parse(dateController.text);
     DateTime today = DateTime.now();
     int age = today.year - dateOfBirth.year;
     if(widget.formDetails![0]['db_admission_table']['db_family_background_table'].isNotEmpty){
      noSibling = widget.formDetails![0]['db_admission_table']['db_family_background_table'][0]['no_of_siblings'].toString();
      parentStatus=widget.formDetails![0]['db_admission_table']['db_family_background_table'][0]['parent_status'] ?? '';
      civilWeddingController.text=widget.formDetails![0]['db_admission_table']['db_family_background_table'][0]['civil_wedding'] ?? '';
      churchNameController.text=widget.formDetails![0]['db_admission_table']['db_family_background_table'][0]['church_name'] ?? '';
      
     }
     
     siblingQuantityController.text=noSibling == 'null' ?'0':noSibling;

     for(int i=0; i<widget.formDetails![0]['db_admission_table']['db_family_background_table'][0]['db_sibling_table'].length;i++){
        var sibling = widget.formDetails![0]['db_admission_table']['db_family_background_table'][0]['db_sibling_table'][i];
        String sdate=sibling['sibling_bday'];
        DateTime siblingBday = DateTime.parse(sdate);
        int siblingAge = today.year - siblingBday.year;
        if (today.month < siblingBday.month || (today.month == siblingBday.month && today.day < siblingBday.day)) {
          siblingAge--;
        }
        nameControllers.add(TextEditingController());
        ageControllers.add(TextEditingController());
        gradeLevelControllers.add(TextEditingController());
        schoolBisControllers.add(TextEditingController());
        name = nameControllers[i];
        ageSibling=ageControllers[i];
        gradeLevel = gradeLevelControllers[i];
        schoolBis = schoolBisControllers[i];

        name.text='${sibling['sibling_first_name']} ${sibling['sibling_middle_name']} ${sibling['sibling_last_name']}';
        ageSibling.text=siblingAge.toString();
        gradeLevel.text=sibling['sibling_grade_course_occupation'];
        schoolBis.text=sibling['sibling_school_business'];
      }
      if (today.month < dateOfBirth.month || (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
        age--;
      }
      ageController.text=age.toString();
      updateQuantity();
      addItemDescription(widget.formDetails![0]['db_admission_table']['db_family_background_table'][0]['db_sibling_table'].length);
     
     

     if(widget.formDetails![0]['db_admission_table']['db_special_concerns_table'].isNotEmpty && widget.formDetails![0]['db_admission_table']['db_special_concerns_table'] != null){
       specialConcernController.text=widget.formDetails![0]['db_admission_table']['db_special_concerns_table'][0]['special_concern'] ?? '';
        mdpConditionController.text=widget.formDetails![0]['db_admission_table']['db_special_concerns_table'][0]['medical_condition'] ?? '';
        medicationController.text=widget.formDetails![0]['db_admission_table']['db_special_concerns_table'][0]['medication'] ?? '';
        interventionController.text=widget.formDetails![0]['db_admission_table']['db_special_concerns_table'][0]['intervention'] ?? '';
        if (widget.formDetails![0]['db_admission_table']['db_special_concerns_table'][0]['supporting_documents'] != null) {
                      originalUrl = widget.formDetails![0]['db_admission_table']['db_special_concerns_table'][0]['supporting_documents'].substring(
                          2, widget.formDetails![0]['db_admission_table']['db_special_concerns_table'][0]['supporting_documents'].length - 2);
                          encodedUrl = Uri.encodeFull(originalUrl);
                    }
      }

       


     if(widget.formDetails![0]['db_admission_table']['db_special_concerns_table'].isNotEmpty && widget.formDetails![0]['db_admission_table']['db_special_concerns_table'] != null){
       specialConcernController.text=widget.formDetails![0]['db_admission_table']['db_special_concerns_table'][0]['special_concern'] ?? '';
        mdpConditionController.text=widget.formDetails![0]['db_admission_table']['db_special_concerns_table'][0]['medical_condition'] ?? '';
        medicationController.text=widget.formDetails![0]['db_admission_table']['db_special_concerns_table'][0]['medication'] ?? '';
        interventionController.text=widget.formDetails![0]['db_admission_table']['db_special_concerns_table'][0]['intervention'] ?? '';
        if (widget.formDetails![0]['db_admission_table']['db_special_concerns_table'][0]['supporting_documents'] != null) {
                      originalUrl = widget.formDetails![0]['db_admission_table']['db_special_concerns_table'][0]['supporting_documents'].substring(
                          2, widget.formDetails![0]['db_admission_table']['db_special_concerns_table'][0]['supporting_documents'].length - 2);
                          encodedUrl = Uri.encodeFull(originalUrl);
                    }
      }

 
 
 if(widget.formDetails![0]['db_admission_table']['db_family_background_table'].isNotEmpty){
        if(widget.formDetails![0]['db_admission_table']['db_family_background_table'][0]['db_parent_table'].length>0){
            for(int i=0; i<widget.formDetails![0]['db_admission_table']['db_family_background_table'][0]['db_parent_table'].length;i++){
              var parent = widget.formDetails![0]['db_admission_table']['db_family_background_table'][0]['db_parent_table'][i];
              String fullName='${parent['first_name']} ${parent['last_name']}';
              DateTime dateOfBirth = DateTime.parse(parent['date_of_birth']);
              DateTime today = DateTime.now();
              int age = today.year - dateOfBirth.year;
              if(parent['relationship_to_child']=='mother'){
                motherNameController.text = fullName;
                motherAgeController.text = age.toString();
                motherEduAttainController.text=parent['educational_attainment'];
                motherEmploymentStatus = parent['employment_status'];
                motherEmployedAtController.text = parent['employed_at'] ?? '';
                motherOfficeAddressController.text=parent['office_address'] ?? '';
                motherContactController.text=parent['contact_no'] ?? '';
                motherWorkPositionController.text = parent['job_position'] ?? '';
                motherSalary = parent['salary_scale'] ?? '';
              }else if(parent['relationship_to_child']=='father'){
                fatherNameController.text = fullName;
                fatherAgeController.text = age.toString();
                fatherEduAttainController.text=parent['educational_attainment'];
                fatherEmploymentStatus = parent['employment_status'];
                fatherEmployedAtController.text = parent['employed_at'] ?? '';
                fatherOfficeAddressController.text=parent['office_address'] ?? '';
                fatherContactController.text=parent['contact_no'] ?? '';
                fatherWorkPositionController.text = parent['job_position'] ?? '';
                fatherSalary = parent['salary_scale'] ?? '';
              }else if(parent['relationship_to_child']=='guardian'){
                guardianNameController.text = fullName;
                guardianAgeController.text = age.toString();
                guardianEduAttainController.text=parent['educational_attainment'];
                guardianEmploymentStatus = parent['employment_status']??'';
                guardianEmployedAtController.text = parent['employed_at'] ?? '';
                guardianOfficeAddressController.text=parent['office_address'] ?? '';
                guardianContactController.text=parent['contact_no'] ?? '';
                guardianWorkPositionController.text = parent['job_position'] ?? '';
                guardianRelationTo = parent['relationship_to_child'] ?? '';
                guardianSalary = parent['salary_scale'] ?? '';
              }
            }
        }
    }     

      
    
  }
  


  

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double baseWidth = 400;
    double baseHeight = 950;
    double widthScale = screenWidth / baseWidth;
    double heightScale = screenHeight / baseHeight;
    double scale = widthScale < heightScale ? widthScale : heightScale;


    addressController.text='${parts[0]}, $districtName, $city, $province';


    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page 1 content


            if(widget.adminType!='Admission' && widget.adminType!='Center for Learner Wellness')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Text(title,
                    style: TextStyle(
                      fontFamily: 'Roboto-R',
                      fontSize: 20 * scale,
                    ),
                  ),
                  isEditable?ElevatedButton(
                    onPressed: () async{
                       showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                  child: BlocConsumer<AdmissionBloc, AdmissionState>(
                                    listener: (context, state) {},
                                    builder: (context, state) {
                                       // Enable button based on the state
                                              if (state is AdmissionIsLoading) {
                                                isLoading = state.isLoading;
                                              }
                                      return SizedBox(
                                                                      width: 349.0,
                                                                      height: 272.0,
                                                                      child: isLoading
                                                              ? const CustomSpinner(
                                                                  color:
                                                                      Color(0xff13322b), // Change the spinner color if needed
                                                                  size: 60.0, // Change the size of the spinner if needed
                                                                ): Column(
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          // Title
                                                                          const Padding(
                                                                            padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                                                                            child: Text(
                                                                              "Confirmation",
                                                                              style: TextStyle(
                                                                                fontFamily: 'Roboto',
                                                                                fontSize: 22,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                          ),
                                                                          // Content
                                                                          const Padding(
                                                                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                                                                            child: Text(
                                                                              "Are you sure you want to update this application?",
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
                                                                        context.read<AdmissionBloc>().add(IsLoadingClicked(true));
                                                                        try {
                                                                                final response = await http.post(
                                                                        Uri.parse('$apiUrl/api/admin/update_form'),
                                                                        headers: {
                                                                          'Content-Type': 'application/json',
                                                                          'supabase-url': supabaseUrl,
                                                                          'supabase-key': supabaseKey,
                                                                        },
                                                                        body: json.encode({
                                                                          'admission_id': widget.formDetails![0]['db_admission_table']['admission_id'],
                                                                          'level_applying': levelApplyingController.text,
                                                                          'school_year': schoolYearController.text,
                                                                          'fname': fnameController.text,
                                                                          'mname': mnameController.text,
                                                                          'lname': lnameController.text,
                                                                          'birthday': dateController.text,
                                                                          'birth_place': birthPlaceController.text,
                                                                          'sex': selectedGender,
                                                                          'religion': religionController.text,
                                                                          'citizenship': citizenshipController.text,
                                                                        }),
                                                                      );
                                                                              
                                                                              
                                  
                                                                              if (response.statusCode == 200) {
                                                                                final responseBody = jsonDecode(response.body);
                                                                                context.read<AdmissionBloc>().add(IsLoadingClicked(false));
                                                                                // ignore: use_build_context_synchronously
                                                                                setState(() {
                                                                                  isEditable=false;
                                                                                  if(isLastPage && !isEditable){
                                                                                    widget.onNextPressed(true);
                                                                                  }
                                                                                });
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
                                                                                                  "Application Updated",
                                                                                                  style: TextStyle(
                                                                                                    fontSize: 22,
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
                                                                                                  Navigator.of(context).popUntil((route) => route.isFirst);
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
                                  
                                                                                // Show failure modal
                                                                                // ignore: use_build_context_synchronously
                                                                                showDialog(
                                                                                  context: context,
                                                                                  builder: (context) => AlertDialog(
                                                                                    title: const Text("Error"),
                                                                                    content: Text("Failed to complete review: ${responseBody['error']}"),
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
                                                                            } catch (error) {
                                                                              // Handle error (e.g., network error)
                                                                              print('Error: $error');
                                  
                                                                              // Show error modal
                                                                              showDialog(
                                                                                context: context,
                                                                                builder: (context) => AlertDialog(
                                                                                  title: const Text("Error"),
                                                                                  content: const Text("An unexpected error occurred. Please try again later."),
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
                                                        );
                                    },
                                  ),
                    ),
                  );


                      // Toggle edit mode
                          
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffF5F7FB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                    ),
                    child: Text('Save', // Change button text dynamically
                      style: TextStyle(
                        fontFamily: 'Roboto-R',
                        fontSize: 13 * scale,
                      ),
                    ),
                  ):ElevatedButton(
                    onPressed: () {
                      // Toggle edit mode
                      setState(() {
                        isEditable = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffF5F7FB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                    ),
                    child: Text('Edit Application', // Change button text dynamically
                      style: TextStyle(
                        fontFamily: 'Roboto-R',
                        fontSize: 13 * scale,
                      ),
                    ),
                  ),
                ],
              ),
            if (_currentPage == 1) ...[
             Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1
       
        const SizedBox(height: 16),
    
    
    
    
    //SCHOOL YEAR || TEXTS
        Row(
    children: [
      Expanded(
        flex: 1,
        child: Text(
          'Level Applying For:',
          style: TextStyle(
            fontFamily: 'Roboto-R',
            fontSize: 11 * scale,
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Text(
          'School Year:',
          style: TextStyle(
            fontFamily: 'Roboto-R',
            fontSize: 11 * scale,
          ),
        ),
      ),
    ],
        ),
        const SizedBox(height: 8),
    
    
    
    
    
    //SCHOOL YEAR DROPDOWN || TEXTFIELD
        Row(
    children: [
      /*Expanded(
  flex: 1,
  child: SizedBox(
    height: 40, // Set the height to 20
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Adjust padding
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scale),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Option 1', child: Text('Option 1', style: TextStyle(fontSize: 10))), // Adjust font size
        DropdownMenuItem(value: 'Option 2', child: Text('Option 2', style: TextStyle(fontSize: 10))), // Adjust font size
      ],
      onChanged: (value) {},
    ),
  ),
),*/

Expanded(
        flex: 1,
        child: SizedBox(
          height: 40,
          child: TextField(
      controller: levelApplyingController,
      enabled: isEditable,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ),

      const SizedBox(width: 8),
      Expanded(
        flex: 1,
        child: SizedBox(
          height: 40,
          child: TextField(
      controller: schoolYearController,
      enabled: isEditable,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ),
    ],
        ),
        const SizedBox(height: 16),
    
    
    
    
    //FULLNAME TEXT
        Text(
    'Full Name*',
    style: TextStyle(
      fontFamily: 'Roboto-R',
      fontSize: 11 * scale,
    ),
        ),
        const SizedBox(height: 8),
    
    
    
    
    //FULLNAME TEXTFIELDS
        Row(
    children: [
      Expanded(
  flex: 1,
  child: SizedBox(
    height: 40,
    child: TextField(
      controller: fnameController,
      enabled: isEditable,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
  ),
),


      const SizedBox(width: 8),
      Expanded(
        flex: 1,
        child: SizedBox(
          height: 40,
          child: TextField(
      controller: mnameController,
      enabled: isEditable,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 1,
        child: SizedBox(
          height: 40,
          child: TextField(
      controller: lnameController,
      enabled: isEditable,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ),
    ],
        ),
        const SizedBox(height: 16),
    
      
    
    
    
    
    
      //CALENDAR ROW || TEXTS
        Row(
    children: [
      Expanded(
        child: Text(
          'Date of Birth*',
          style: TextStyle(
            fontFamily: 'Roboto-R',
            fontSize: 11 * scale,
          ),
        ),
      ),
      Expanded(
        child: Text(
          'Place of Birth*',
          style: TextStyle(
            fontFamily: 'Roboto-R',
            fontSize: 11 * scale,
          ),
        ),
      ),
      Expanded(
        child: Text(
          'Age*',
          style: TextStyle(
            fontFamily: 'Roboto-R',
            fontSize: 11 * scale,
          ),
        ),
      ),
    ],
        ),
        const SizedBox(height: 8),
    
    
    
    
    
    
    //CALENDAR ROW || FIELDS
        Row(
    children: [
    Expanded(
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: dateController, // Use the controller to update the text
          readOnly: true,
          enabled: isEditable,  // Makes the TextField non-editable, so the calendar triggers the date picker
          decoration: InputDecoration(
            suffixIcon: IconButton(
        icon: const Icon(Icons.calendar_today), // Calendar icon
        onPressed: () async {
          // Show the date picker dialog
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(), // Initial date when the dialog opens
            firstDate: DateTime(1900), // First date allowed to be selected
            lastDate: DateTime(2101), // Last date allowed to be selected
          );
          if (pickedDate != null) {
            // Update the text field with the selected date
            setState(() {
              dateController.text = "${pickedDate.toLocal()}".split(' ')[0]; // Format the date as YYYY-MM-DD
            });
          }
        },
            ),
            border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8 * scale), // Scalable radius
            ),
          ),
        ),
      ),
    ),
    
      const SizedBox(width: 8),
      Expanded(
        flex: 1,
        child: SizedBox(
          height: 40,
          child: TextField(
      controller: birthPlaceController,
      enabled: isEditable,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 1,
        child: SizedBox(
          height: 40,
          child: TextField(
      controller: ageController,
      enabled: isEditable,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ),
    ],
        ),
        const SizedBox(height: 16),
    
    
    
    
    //SEX ROW | TEXTS
        Row(
    children: [
      Expanded(
        child: Text(
          'Sex*',
          style: TextStyle(
            fontFamily: 'Roboto-R',
            fontSize: 11 * scale,
          ),
        ),
      ),
      Expanded(
        child: Text(
          'Religion*',
          style: TextStyle(
            fontFamily: 'Roboto-R',
            fontSize: 11 * scale,
          ),
        ),
      ),
      Expanded(
        child: Text(
          'Citizenship*',
          style: TextStyle(
            fontFamily: 'Roboto-R',
            fontSize: 11 * scale,
          ),
        ),
      ),
    ],
        ),
        const SizedBox(height: 8),
    
    
    
    
    
    //RADIO BUTTON ROW
    Row(
      children: [
        // First Column: Radio Buttons
        Expanded(
    flex: 1,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    
Row(
  children: [
    Expanded(
      child: Row(
        children: [
          Radio<String>(
            value: 'Male',
            groupValue: selectedGender,
            activeColor: const Color(0XFF012169), // Active (selected) color is set to red
            onChanged: (value) {
              setState(() {
                if (selectedGender.toLowerCase() == value!.toLowerCase()) {
                  selectedGender = value;
                }
              });
            },
          ),
          Text(
            'Male',
            style: TextStyle(fontSize: 13 * scale),
          ),
        ],
      ),
    ),
    Expanded(
      child: Row(
        children: [
          Radio<String>(
            value: 'Female',
            groupValue: selectedGender,
            activeColor: const Color(0XFF012169), // Active (selected) color is set to red
            onChanged: (value) {
              setState(() {
                if (selectedGender.toLowerCase() == value!.toLowerCase()) {
                  selectedGender = value;
                }
              });
            },
          ),
          Text(
            'Female',
            style: TextStyle(fontSize: 13 * scale),
          ),
        ],
      ),
    ),
  ],
),

      ],
    ),
        ),
    
        // Second Column: Dropdown 1
       /* Expanded(
    flex: 1,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    
        SizedBox(
          height: 40,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8 * scale),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
              DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
            ],
            onChanged: (value) {
              setState(() {
                dropdown1Value = value!;
              });
            },
          ),
        ),
      ],
    ),
        ),*/
        Expanded(
        flex: 1,
        child: SizedBox(
          height: 40,
          child: TextField(
      controller: religionController,
      enabled: isEditable,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ),
    
        const SizedBox(width: 8),

        Expanded(
        flex: 1,
        child: SizedBox(
          height: 40,
          child: TextField(
      controller: citizenshipController,
      enabled: isEditable,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ),
    
        // Third Column: Dropdown 2
        /*Expanded(
    flex: 1,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    
        SizedBox(
          height: 40,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8 * scale),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Option A', child: Text('Option A')),
              DropdownMenuItem(value: 'Option B', child: Text('Option B')),
            ],
            onChanged: (value) {
              setState(() {
                dropdown2Value = value!;
              });
            },
          ),
        ),
      ],
    ),
        ),*/
      ],
    ),
    
    
    
    
    
    
        const SizedBox(height: 16),
    
    
    
    
    //ACR NUMBER
        Row(
    children: [
      Expanded(
        child: Text(
          'ACR Number (For Foreign Learners Only)',
          style: TextStyle(
            fontFamily: 'Roboto-R',
            fontSize: 11 * scale,
          ),
        ),
      ),
      
    ],
        ),
        const SizedBox(height: 8),
    
        Row(
    children: [
       Expanded(
        flex: 1,
        child: SizedBox(
          height: 40,
          child: TextField(
      controller: acrController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ),
    ],
        ),
    
    
    
    
    
    
    
    
        const SizedBox(height: 16),
    
    
    
    
    //ADDRESS
        Row(
    children: [
      Expanded(
        child: Text(
          'Address*',
          style: TextStyle(
            fontFamily: 'Roboto-R',
            fontSize: 11 * scale,
          ),
        ),
      ),
      
    ],
        ),
        const SizedBox(height: 8),
    
        Row(
    children: [
      Expanded(
        flex: 1,
        child: SizedBox(
          height: 40,
          child: TextField(
      controller: addressController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ),
    ],
        ),
    
    
    
    
       const SizedBox(height: 16),
    
    
    
    
    //ZIP POSTAL ROW || TEXTS
        Row(
    children: [
      Expanded(
        flex: 1,
        child: Text(
          'Zip/Postal Code*',
          style: TextStyle(
            fontFamily: 'Roboto-R',
            fontSize: 11 * scale,
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Text(
          'Contact No.*',
          style: TextStyle(
            fontFamily: 'Roboto-R',
            fontSize: 11 * scale,
          ),
        ),
      ),
    ],
        ),
        const SizedBox(height: 8),
    
    
    
    
    
    //ZIP POSTAL ROW || TEXTFIELD
        Row(
    children: [
      Expanded(
        flex: 1,
        child: SizedBox(
          height: 40,
          child: TextField(
      controller: postalController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 1,
        child: SizedBox(
          height: 40,
          child: TextField(
      controller: contactController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ),
    ],
        ),
    
    
    
    
    
    
    
    
    
    const SizedBox(height: 16),
    
    
    
    
    //LANGUAGES ROW || TEXTS
        Row(
    children: [
      Expanded(
        flex: 1,
        child: Text(
          'Languages/Dialects Spoken*',
          style: TextStyle(
            fontFamily: 'Roboto-R',
            fontSize: 11 * scale,
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Text(
          'Usual Companion at Home*',
          style: TextStyle(
            fontFamily: 'Roboto-R',
            fontSize: 11 * scale,
          ),
        ),
      ),
    ],
        ),
        const SizedBox(height: 8),
    
    
    
    
    
    //LANGAUAGES ROW || TEXTFIELD
        Row(
    children: [
      /*Expanded(
        flex: 1,
        child: SizedBox(
          height: 40,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8 * scale),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Option 1', child: Text('Option 1')),
              DropdownMenuItem(value: 'Option 2', child: Text('Option 2')),
            ],
            onChanged: (value) {},
          ),
        ),
      ),*/
      Expanded(
        flex: 1,
        child: SizedBox(
          height: 40,
          child: TextField(
      controller: languageSpokenController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 1,
        child: SizedBox(
          height: 40,
          child: TextField(
      controller: companionController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ),
    ],
        ),
    
    
    const SizedBox(height: 30),
    
        // Centered Next Button
        Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
  onPressed: (){
    _nextPage();
  }, // Switch to the second page
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF012169), // Button color
    fixedSize: const Size(188, 35), // Width and height
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // Radius
    ),
  ),
  child: const Text(
    'Next',
    style: TextStyle(
      fontSize: 13, // Text size
      fontFamily: 'Roboto-R', // Font family
      color: Colors.white, // Text color
    ),
  ),
),

    ],
        ),
      ],
    ),
            ],

























































//PAGE 2 CONTENTS
            if (_currentPage == 2) ...[
              
        const SizedBox(height: 16),

              // 2nd Row - Number of siblings dropdown field
              /*SizedBox(
  width: 420,
  child: SizedBox(
    height: 40,
    child: DropdownButtonFormField<String>(
      items: ['1', '2', '3', '4', '5']
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: (value) {},
      decoration: InputDecoration(
        labelText: 'Number of Siblings',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  ),
),*/
SizedBox(
  width: 420,
  height: 40,
  child: TextField(
    controller: siblingQuantityController,
    enabled: false, 
    keyboardType: TextInputType.number,  // To handle numeric input
    decoration: InputDecoration(
      labelText: "Number of Siblings", // Optional label
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    onChanged: (String value) {
      updateQuantity();
      addItemDescription(double.parse(siblingQuantityController.text));
    },
  ),
),


Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children:
 
 [
                Container(
                  
                  height: screenHeight * 0.45,
                  width: screenWidth * 0.72,
                  padding: const EdgeInsets.all(0),
                  //decoration: boxdecoration.copyWith(borderRadius: BorderRadius.circular(15)),
                  child: ListView.builder(
                    itemCount: siblings.length,
                    itemBuilder: (context, index) {
                      return siblings[index];
                    },
                  ),
                ),
              ]),





              // 6th Row - Name, Age, Grade, and School text fields
              
              const SizedBox(height: 75),

              // Centered Back and Next buttons for the second page
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton(
      onPressed: _previousPage, // Toggle to go back to the first page
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD3D3D3), // Button color
        fixedSize: const Size(188, 35), // Width and height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Radius
        ),
      ),
      child: const Text(
        'Back',
        style: TextStyle(
          fontSize: 13, // Text size
          fontFamily: 'Roboto-R', // Font family
          color: Colors.black, // Text color
        ),
      ),
    ),
  ],
),
const SizedBox(height: 8), // Add some space between buttons
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton(
      onPressed: _nextPage, // Toggle to the next page
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF012169), // Button color
        fixedSize: const Size(188, 35), // Width and height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Radius
        ),
      ),
      child: const Text(
        'Next',
        style: TextStyle(
          fontSize: 13, // Text size
          fontFamily: 'Roboto-R', // Font family
          color: Colors.white, // Text color
        ),
      ),
    ),
  ],
),

            ],














































//PAGE 3 CONTENT
            if (_currentPage == 3) ...[
              // Add content for the third page here
        Text(
        'Please enter Parents Information',
        style: TextStyle(
          fontFamily: 'Roboto-R',
          fontSize: 13 * scale,
        ),
      ),

        const SizedBox(height: 16),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // First Column: Fixed width 600
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'Father’s Full Name*',
          style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'), // Adjust font size as needed
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 600,
          height: 40,
          child: TextField(
      controller: fatherNameController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ],
    ),
    const SizedBox(width: 8),

    // Second Column: Fixed width 120
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'Age*',
          style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 120,
          height: 40,
          child: TextField(
      controller: fatherAgeController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ],
    ),
    const SizedBox(width: 8),

    // Third Column: Expanded
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Educational Attainment*',
            style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(
      controller: fatherEduAttainController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
          ),
        ],
      ),
    ),
    const SizedBox(width: 8),

    // Fourth Column: Expanded
Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Employment Status*',
        style: TextStyle(
          fontSize: 11 * scale,
          fontFamily: 'Roboto-R',
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 40,
        child: DropdownButtonFormField<String>(
          value: fatherEmploymentStatus,
          items: const [
            DropdownMenuItem(
              value: 'Employed',
              child: Text('Employed'),
            ),
            DropdownMenuItem(
              value: 'Unemployed',
              child: Text('Unemployed'),
            ),
            DropdownMenuItem(
              value: 'Self-employed',
              child: Text('Self-employed'),
            ),
            DropdownMenuItem(
              value: 'Student',
              child: Text('Student'),
            ),
          ],
          onChanged: null,
          // onChanged: (value) {
          // },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
    ],
  ),
),

  ],
),
              const SizedBox(height: 16),


Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Employed at*',
            style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(
      controller: fatherEmployedAtController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
          ),
        ],
      ),
    ),
    const SizedBox(width: 8),

    // Fourth Column: Expanded
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Office Address*',
            style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(
      controller: fatherOfficeAddressController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
          ),
        ],
      ),
    ),
  ],
),
              const SizedBox(height: 16),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Contact No.*',
            style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(
      controller: fatherContactController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
          ),
        ],
      ),
    ),
    const SizedBox(width: 8),

    // Fourth Column: Expanded
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Position*',
            style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(
      controller: fatherWorkPositionController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
          ),
        ],
      ),
    ),



        const SizedBox(width: 8),

    // Fourth Column: Expanded
Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Salary Scale*',
        style: TextStyle(
          fontSize: 11 * scale,
          fontFamily: 'Roboto-R',
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 40,
        child: DropdownButtonFormField<String>(
          value: fatherSalary,
          items: const [
            DropdownMenuItem(
              value: 'PhP 9,999',
              child: Text('< PhP 9,999'),
            ),
            DropdownMenuItem(
              value: 'PhP 10,000 - 19,999',
              child: Text('PhP 10,000 - 19,999'),
            ),
            DropdownMenuItem(
              value: 'PhP 20,000 - 39,999',
              child: Text('PhP 20,000 - 39,999'),
            ),
            DropdownMenuItem(
              value: 'PhP 40,000 - 69,999',
              child: Text('PhP 40,000 - 69,999'),
            ),
            DropdownMenuItem(
              value: 'PhP 70,000 - 99,999',
              child: Text('PhP 70,000 - 99,999'),
            ),
            DropdownMenuItem(
              value: 'PhP 100,000+',
              child: Text('PhP 100,000+'),
            ),
            DropdownMenuItem(
              value: '',
              child: Text('N/A'),
            ),
          ],
          onChanged: null,
          // onChanged: (value) {
          // },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: Text(
            'Select Salary Scale',
            style: TextStyle(
              fontSize: 11 * scale,
              fontFamily: 'Roboto-R',
              color: Colors.grey,
            ),
          ),
        ),
      ),
    ],
  ),
),

  ],
),

              const SizedBox(height: 16),

              // 5th Row - Divider
              const Divider(),

              const SizedBox(height: 16),



Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // First Column: Fixed width 600
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'Mother’s Full Maiden Name*',
          style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'), // Adjust font size as needed
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 600,
          height: 40,
          child: TextField(
      controller: motherNameController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ],
    ),
    const SizedBox(width: 8),

    // Second Column: Fixed width 120
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'Age*',
          style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 120,
          height: 40,
          child: TextField(
      controller: motherAgeController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
        ),
      ],
    ),
    const SizedBox(width: 8),

    // Third Column: Expanded
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Educational Attainment*',
            style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(
      controller: motherEduAttainController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
          ),
        ],
      ),
    ),
    const SizedBox(width: 8),

    // Fourth Column: Expanded
Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Employment Status*',
        style: TextStyle(
          fontSize: 11 * scale,
          fontFamily: 'Roboto-R',
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 40,
        child: DropdownButtonFormField<String>(
          value: motherEmploymentStatus,
          items: const [
            DropdownMenuItem(
              value: 'Employed',
              child: Text('Employed'),
            ),
            DropdownMenuItem(
              value: 'Unemployed',
              child: Text('Unemployed'),
            ),
            DropdownMenuItem(
              value: 'Self-employed',
              child: Text('Self-employed'),
            ),
            DropdownMenuItem(
              value: 'Student',
              child: Text('Student'),
            ),
          ],
          onChanged: null,
          // onChanged: (value) {
          // },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
    ],
  ),
),

  ],
),
              const SizedBox(height: 16),


Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Employed at*',
            style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(
      controller: motherEmployedAtController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
          ),
        ],
      ),
    ),
    const SizedBox(width: 8),

    // Fourth Column: Expanded
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Office Address*',
            style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(
      controller: motherOfficeAddressController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
          ),
        ],
      ),
    ),
  ],
),
              const SizedBox(height: 16),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Contact No.*',
            style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(
      controller: motherContactController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
          ),
        ],
      ),
    ),
    const SizedBox(width: 8),

    // Fourth Column: Expanded
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Position*',
            style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(
      controller: motherWorkPositionController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
          ),
        ],
      ),
    ),



        const SizedBox(width: 8),

    // Fourth Column: Expanded
Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Salary Scale*',
        style: TextStyle(
          fontSize: 11 * scale,
          fontFamily: 'Roboto-R',
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 40,
        child: DropdownButtonFormField<String>(
          value: motherSalary,
          items: const [
            DropdownMenuItem(
              value: '',
              child: Text('Please select salary scale'),
            ),
            DropdownMenuItem(
              value: 'PhP 9,999',
              child: Text('< PhP 9,999'),
            ),
            DropdownMenuItem(
              value: 'PhP 10,000 - 19,999',
              child: Text('PhP 10,000 - 19,999'),
            ),
            DropdownMenuItem(
              value: 'PhP 20,000 - 39,999',
              child: Text('PhP 20,000 - 39,999'),
            ),
            DropdownMenuItem(
              value: 'PhP 40,000 - 69,999',
              child: Text('PhP 40,000 - 69,999'),
            ),
            DropdownMenuItem(
              value: 'PhP 70,000 - 99,999',
              child: Text('PhP 70,000 - 99,999'),
            ),
            DropdownMenuItem(
              value: 'PhP 100,000+',
              child: Text('PhP 100,000+'),
            ),
          ],
          onChanged: null,
          // onChanged: (value) {
          // },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: Text(
            'Select Salary Scale',
            style: TextStyle(
              fontSize: 11 * scale,
              fontFamily: 'Roboto-R',
              color: Colors.grey,
            ),
          ),
        ),
      ),
    ],
  ),
),

  ],
),



const SizedBox(height: 97),

Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton(
      onPressed: _previousPage, // Toggle to go back to the first page
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD3D3D3), // Button color
        fixedSize: const Size(188, 35), // Width and height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Radius
        ),
      ),
      child: const Text(
        'Back',
        style: TextStyle(
          fontSize: 13, // Text size
          fontFamily: 'Roboto-R', // Font family
          color: Colors.black, // Text color
        ),
      ),
    ),
  ],
),
const SizedBox(height: 8), // Add some space between buttons
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton(
      onPressed: _nextPage, // Toggle to the next page
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF012169), // Button color
        fixedSize: const Size(188, 35), // Width and height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Radius
        ),
      ),
      child: const Text(
        'Next',
        style: TextStyle(
          fontSize: 13, // Text size
          fontFamily: 'Roboto-R', // Font family
          color: Colors.white, // Text color
        ),
      ),
    ),
  ],
),

            ],


































//PAGE 4 CONTENT
            if (_currentPage == 4) ...[
              // Add content for the third page here
        Text(
        'Please enter Guardian Information',
        style: TextStyle(
          fontFamily: 'Roboto-R',
          fontSize: 13 * scale,
        ),
      ),

        const SizedBox(height: 16),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // First Column: Fixed width 600
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'Guardian’s Full Name',
          style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'), // Adjust font size as needed
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 600,
          height: 40,
          child: TextField(
            controller: guardianNameController,
            enabled: false, 
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    ),
    const SizedBox(width: 8),

    // Second Column: Fixed width 120
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'Age*',
          style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 120,
          height: 40,
          child: TextField(
            controller: guardianAgeController,
            enabled: false, 
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    ),
    const SizedBox(width: 8),

    // Third Column: Expanded
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Educational Attainment*',
            style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(
              controller: guardianEduAttainController,
              enabled: false, 
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(width: 8),

    // Fourth Column: Expanded
Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Employment Status*',
        style: TextStyle(
          fontSize: 11 * scale,
          fontFamily: 'Roboto-R',
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 40,
        child: DropdownButtonFormField<String>(
          value: guardianEmploymentStatus,
          items: const [
            DropdownMenuItem(
              value: 'Employed',
              child: Text('Employed'),
            ),
            DropdownMenuItem(
              value: 'Unemployed',
              child: Text('Unemployed'),
            ),
            DropdownMenuItem(
              value: 'Self-employed',
              child: Text('Self-employed'),
            ),
            DropdownMenuItem(
              value: 'Student',
              child: Text('Student'),
            ),
          ],
          onChanged: null,
          // onChanged: (value) {
          // },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ),
    ],
  ),
),

  ],
),
              const SizedBox(height: 16),


Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Employed at*',
            style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(
              controller: guardianEmployedAtController,
              enabled: false, 
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(width: 8),

    // Fourth Column: Expanded
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Office Address*',
            style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(
              controller: guardianOfficeAddressController,
              enabled: false, 
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ],
),
              const SizedBox(height: 16),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Contact No.*',
            style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(controller: guardianContactController,
            enabled: false, 
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(width: 8),

    // Fourth Column: Expanded
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Position*',
            style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: TextField(
              controller: guardianWorkPositionController,
              enabled: false, 
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    ),



        const SizedBox(width: 8),

    // Fourth Column: Expanded
Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Salary Scale*',
        style: TextStyle(
          fontSize: 11 * scale,
          fontFamily: 'Roboto-R',
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 40,
        child: DropdownButtonFormField<String>(
          value: guardianSalary,
          items: const [
            DropdownMenuItem(
              value: 'PhP 9,999',
              child: Text('< PhP 9,999'),
            ),
            DropdownMenuItem(
              value: 'PhP 10,000 - 19,999',
              child: Text('PhP 10,000 - 19,999'),
            ),
            DropdownMenuItem(
              value: 'PhP 20,000 - 39,999',
              child: Text('PhP 20,000 - 39,999'),
            ),
            DropdownMenuItem(
              value: 'PhP 40,000 - 69,999',
              child: Text('PhP 40,000 - 69,999'),
            ),
            DropdownMenuItem(
              value: 'PhP 70,000 - 99,999',
              child: Text('PhP 70,000 - 99,999'),
            ),
            DropdownMenuItem(
              value: 'PhP 100,000+',
              child: Text('PhP 100,000+'),
            ),
          ],
          onChanged: null,
          // onChanged: (value) {
          // },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: Text(
            'Select Salary Scale',
            style: TextStyle(
              fontSize: 11 * scale,
              fontFamily: 'Roboto-R',
              color: Colors.grey,
            ),
          ),
        ),
      ),
    ],
  ),
),

  ],
),

              const SizedBox(height: 16),

              // 5th Row - Divider
              const Divider(),

              const SizedBox(height: 16),



Row(
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Relationship to the Child (If Guardian)*',
            style: TextStyle(
              fontSize: 11 * scale,
              fontFamily: 'Roboto-R',
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: DropdownButtonFormField<String>(
              value: guardianRelationTo,
              items: const [
                DropdownMenuItem(
                  value: 'parent',
                  child: Text('Parent'),
                ),
                DropdownMenuItem(
                  value: 'guardian',
                  child: Text('Guardian'),
                ),
                DropdownMenuItem(
                  value: 'relative',
                  child: Text('Relative'),
                ),
                DropdownMenuItem(
                  value: 'other',
                  child: Text('Other'),
                ),
              ],
              onChanged: null,
          // onChanged: (value) {
          // },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: Text(
                'Select Relationship',
                style: TextStyle(
                  fontSize: 11 * scale,
                  fontFamily: 'Roboto-R',
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ],
),

const SizedBox(height: 16,),


Row(
  children: [
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parent Status*',
            style: TextStyle(
              fontSize: 11 * scale,
              fontFamily: 'Roboto-R',
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: DropdownButtonFormField<String>(
              value: parentStatus,
              items: const [
                DropdownMenuItem(
                  value: 'Married',
                  child: Text('Married'),
                ),
                DropdownMenuItem(
                  value: 'Separated',
                  child: Text('Separated'),
                ),
                DropdownMenuItem(
                  value: 'Solo Parent',
                  child: Text('Solo Parent'),
                ),
                DropdownMenuItem(
                  value: 'Widowed',
                  child: Text('Widowed'),
                ),
                DropdownMenuItem(
                  value: 'Not Married',
                  child: Text('Not Married'),
                ),
              ],
              onChanged: null,
          // onChanged: (value) {
          // },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: Text(
                'Select Parent Status',
                style: TextStyle(
                  fontSize: 11 * scale,
                  fontFamily: 'Roboto-R',
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ],
),


const SizedBox(height: 16,),

    Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Civil Wedding*',
                style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
              ),
              const SizedBox(height: 8),
              SizedBox(
            height: 40,
            child: TextField(
      controller: civilWeddingController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
          ),
            ],
          ),
        ),
      ],
    ),




    const SizedBox(height: 16,),

        Row(
          children: [
            Expanded(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Church Name*',
                style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
              ),
              const SizedBox(height: 8),
              SizedBox(
            height: 40,
            child: TextField(
      controller: churchNameController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
          ),
            ],
                  ),
                ),
          ],
        ),



const SizedBox(height: 16,),


Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton(
      onPressed: (){
        widget.onNextPressed(false);
        _previousPage();
      }, // Toggle to go back to the first page
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD3D3D3), // Button color
        fixedSize: const Size(188, 35), // Width and height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Radius
        ),
      ),
      child: const Text(
        'Back',
        style: TextStyle(
          fontSize: 13, // Text size
          fontFamily: 'Roboto-R', // Font family
          color: Colors.black, // Text color
        ),
      ),
    ),
  ],
),
const SizedBox(height: 8), // Add some space between buttons
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton(
      onPressed: (){
        if(!isEditable){
         widget.onNextPressed(true);
        }else{
         widget.onNextPressed(false);
        }

        setState(() {
          isLastPage=true;
        });
        _nextPage();
      }, // Toggle to the next page
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF012169), // Button color
        fixedSize: const Size(188, 35), // Width and height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Radius
        ),
      ),
      child: const Text(
        'Next',
        style: TextStyle(
          fontSize: 13, // Text size
          fontFamily: 'Roboto-R', // Font family
          color: Colors.white, // Text color
        ),
      ),
    ),
  ],
    ),


            ],























//PAGE 5 CONTENT
            if (_currentPage == 5) ...[
              // Add content for the third page here
             
              const SizedBox(height: 16),

                  Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Special Concerns',
                style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
              ),
              const SizedBox(height: 8),
              SizedBox(
            height: 40,
            child: TextField(
      controller: specialConcernController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
          ),
            ],
          ),
        ),
      ],
    ),
              const SizedBox(height: 16),

                  Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Medical/ Developmental/ Psychological Condition',
                style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
              ),
              const SizedBox(height: 8),
              SizedBox(
            height: 40,
            child: TextField(
      controller: mdpConditionController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
          ),
            ],
          ),
        ),
      ],
    ),

const SizedBox(height: 16),

                  Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Medication',
                style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
              ),
              const SizedBox(height: 8),
              SizedBox(
            height: 40,
            child: TextField(
      controller: medicationController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
          ),
            ],
          ),
        ),

const SizedBox(width: 8,),
        
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          'Intervention',
                          style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
            height: 40,
            child: TextField(
      controller: interventionController,
      enabled: false,
      style: TextStyle(
        color: isEditable ? const Color(0XFF012169) : Colors.black, // Dynamically change text color
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when enabled
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when focused
            width: 2.0,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isEditable ? const Color(0XFF012169) : Colors.black, // Match text and border color when disabled
            width: 1.0,
          ),
        ),
      ),
    ),
          ),
                      ],
                    ),
                  ),
      ],
    ),

const SizedBox(height: 16),


                  Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Attach Supporting Document',
                style: TextStyle(fontSize: 11 * scale, fontFamily: 'Roboto-R'),
              ),
              const SizedBox(height: 8),
              SizedBox(
            height: 40,
            child: /*TextField(
              enabled: false, 
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            */ElevatedButton(
                              onPressed: encodedUrl.isNotEmpty
                                  ? () async {
                                      // Ensure imagePath is a valid URL

                                      // Use the browser's built-in window.open method
                                      /*try {
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
                                      List<String> urls = List<String>.from(json.decode(widget.formDetails![0]['db_admission_table']['db_special_concerns_table'][0]['supporting_documents']));
                          
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
                            )
          ),
            ],
          ),
        ),
      ],
    ),

    
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:[
        const SizedBox(height: 25),
        Text('Survey',style: TextStyle(fontSize: 20, fontFamily: 'Roboto-R')),
        const SizedBox(height: 15),
        Text('How did you first hear about our school?',style: TextStyle(fontSize: 15, fontFamily: 'Roboto-R')),
        HeardAboutSchoolCheckboxes(
                heardAboutSchool: heardAboutSchool,  // Pass the default value
                onSelectionChanged: onSelectionChanged, // Pass the callback
                othersController: othersController, // Pass the controller for "Others" text field
              ),
      ]
    ),

    


const SizedBox(height: 120),



              Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton(
      onPressed: (){
         widget.onNextPressed(false);
        _previousPage();}, // Toggle to go back to the first page
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD3D3D3), // Button color
        fixedSize: const Size(188, 35), // Width and height
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Radius
        ),
      ),
      child: const Text(
        'Back',
        style: TextStyle(
          fontSize: 13, // Text size
          fontFamily: 'Roboto-R', // Font family
          color: Colors.black, // Text color
        ),
      ),
    ),
  ],
),
              const SizedBox(height: 8), // Add some space between buttons

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     ElevatedButton(
              //       onPressed: () {
              //         // Handle Submit action
              //       },
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.green, // Green button color
              //       ),
              //       child: const Text('Submit'),
              //     ),
              //   ],
              // ),
            ],





            
          ],
        ),
      ),
    );
  }
}
