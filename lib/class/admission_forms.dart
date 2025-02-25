import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class ApiService {
  final String apiUrl;
  late StreamController<List<Map<String, dynamic>>> _streamController;
  Timer? _timer;
  ApiService(this.apiUrl){
    _streamController = StreamController<List<Map<String, dynamic>>>.broadcast();
  }

  Stream<List<Map<String, dynamic>>> get admissionFormsStream => _streamController.stream;

  Future<List<Map<String, dynamic>>> fetchAdmissionForms(String supabaseUrl, String supabaseKey) async {
    final response = await http.get(
      Uri.parse('$apiUrl/api/admin/get_admission'),
      headers: {
        "supabase-url": supabaseUrl,
        "supabase-key": supabaseKey,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // Ensure the type safety by converting to List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(data['user'] ?? []);
      
    } else {
      throw Exception('Failed to form data');
    }
  }



  void startStreaming(String supabaseUrl, String supabaseKey) {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final members = await fetchAdmissionForms(supabaseUrl, supabaseKey);
        final filteredMembers = members.where((member) => member['db_admission_table'] != null).toList();
        _streamController.add(filteredMembers);
      } catch (e) {
        print('Error fetching members: $e');
        _streamController.add([]);
      }
    });
  }

  // Stop the stream when searching
  void stopStreaming() {
    _timer?.cancel();
  }

  // Fetch data manually (for search)
  Future<void> searchAdmissionForms(String supabaseUrl, String supabaseKey, String query) async {
    stopStreaming(); // Stop the automatic refresh
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/api/admin/search_overview?search=$query'),
        headers: {
          "supabase-url": supabaseUrl,
          "supabase-key": supabaseKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final searchResults = List<Map<String, dynamic>>.from(data['userData'] ?? []);
        _streamController.add(searchResults);
      } else {
        throw Exception('Failed to fetch search results');
      }
    } catch (e) {
      print('Error searching: $e');
      _streamController.add([]);
    }
  }


  Stream<List<Map<String, dynamic>>> streamAdmissionForms(String supabaseUrl, String supabaseKey) async* {
  while (true) {
    try {
      // Fetch the admission forms (assuming fetchAdmissionForms is already defined)
      final members = await fetchAdmissionForms(supabaseUrl, supabaseKey);
      
      // Filter out the members where db_admission_table is null
      final filteredMembers = members.where((member) {
        // Ensure db_admission_table is not null
        return member['db_admission_table'] != null;
      }).toList(); // Convert the iterable to a list

      // Emit the filtered list of members
      yield filteredMembers;
    } catch (e) {
      print('Error fetching members: $e');
      yield []; // Emit an empty list on error
    }

    // Delay the next fetch
    await Future.delayed(const Duration(seconds: 3)); // Refresh every 3 seconds
  }
}


  /*Stream<List<Map<String, dynamic>>> streamMembers(String supabaseUrl, String supabaseKey) async* {
    while (true) {
      try {
        final response = await http.get(
          Uri.parse('https://medicareplus-api.vercel.app/api/admin/get_all_members'),
          headers: {
            'Content-Type': 'application/json',
            'supabase-url': supabaseUrl,
            'supabase-key': supabaseKey,
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          yield List<Map<String, dynamic>>.from(data['members'] ?? []);
        } else {
          throw Exception('Failed to load status count');
        }
      } catch (e) {
        print('Error: $e');
        yield []; // Emit an empty list on error
      }

      await Future.delayed(const Duration(seconds: 5)); // Refresh every 5 seconds
    }
  }*/


  Future<List<Map<String, dynamic>>> getDetailsById(int admissionId, String supabaseUrl, String supabaseKey) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/api/admin/get_admission_details'),
      headers: {
        'Content-Type': 'application/json',
        'supabase-url': supabaseUrl,
        'supabase-key': supabaseKey,
      },
      body: json.encode({
        'admission_id': admissionId,  // Send customer_id in the request body
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      //print('Response data: $data');  // Debugging output

      // Check if 'members' is a list or a map
      if (data['detail'] is List) {
        // If it's already a list, return it as a List<Map<String, dynamic>>
        return List<Map<String, dynamic>>.from(data['detail']);
      } else if (data['detail'] is Map) {
        // If it's a map (single member), convert it to a list with that single map
        return [data['detail']];
      } else {
        // Return an empty list if 'members' is neither a List nor a Map
        return [];
      }
    } else {
      throw Exception('Failed to load member');
    }
  } catch (e) {
    print('Error: $e');
    return []; // Return an empty list on error
  }
}



Future<List<Map<String, dynamic>>> getUserAllRequest(int userId, String supabaseUrl, String supabaseKey) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/api/admin/get_admission_details'),
      headers: {
        'Content-Type': 'application/json',
        'supabase-url': supabaseUrl,
        'supabase-key': supabaseKey,
      },
      body: json.encode({
        'user_id': userId,  // Send customer_id in the request body
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      //print('Response data: $data');  // Debugging output

      // Check if 'members' is a list or a map
      if (data['detail'] is List) {
        // If it's already a list, return it as a List<Map<String, dynamic>>
        return List<Map<String, dynamic>>.from(data['detail'].where((entry) => entry['db_admission_table'] != null),);
      } else if (data['detail'] is Map) {
        // If it's a map (single member), convert it to a list with that single map
        return [data['detail']];
      } else {
        // Return an empty list if 'members' is neither a List nor a Map
        return [];
      }
    } else {
      throw Exception('Failed to load member');
    }
  } catch (e) {
    print('Error: $e');
    return []; // Return an empty list on error
  }
}


Future<List<Map<String, dynamic>>> getFormsDetailsById(int admissionId, String supabaseUrl, String supabaseKey) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/api/admin/get_requirements_details'),
      headers: {
        'Content-Type': 'application/json',
        'supabase-url': supabaseUrl,
        'supabase-key': supabaseKey,
      },
      body: json.encode({
        'admission_id': admissionId,  // Send customer_id in the request body
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      //print('Response data: $data');  // Debugging output

      // Check if 'members' is a list or a map
      if (data['detail'] is List) {
        // If it's already a list, return it as a List<Map<String, dynamic>>
        return List<Map<String, dynamic>>.from(data['detail']);
      } else if (data['detail'] is Map) {
        // If it's a map (single member), convert it to a list with that single map
        return [data['detail']];
      } else {
        // Return an empty list if 'members' is neither a List nor a Map
        return [];
      }
    } else {
      throw Exception('Failed to load member');
    }
  } catch (e) {
    print('Error: $e');
    return []; // Return an empty list on error
  }
}



Future<List<Map<String, dynamic>>> fetchRegisteredUser(String supabaseUrl, String supabaseKey) async {
    final response = await http.get(
      Uri.parse('$apiUrl/api/admin/get_all_registered'),
      headers: {
        "supabase-url": supabaseUrl,
        "supabase-key": supabaseKey,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // Ensure the type safety by converting to List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(data['user'] ?? []);
      
    } else {
      throw Exception('Failed to form data');
    }
  }

  Stream<List<Map<String, dynamic>>> streamRegisteredUser(String supabaseUrl, String supabaseKey) async* {
    while (true) {
      try {
        final members = await fetchRegisteredUser(supabaseUrl, supabaseKey);
        yield members; // Emit the list of members
      } catch (e) {
        print('Error fetching members: $e');
        yield []; // Emit an empty list on error
      }

      await Future.delayed(const Duration(seconds: 3)); // Refresh every 10 seconds
    }
  }





//PAYMENT
Future<List<Map<String, dynamic>>> fetchPaymentForms(String supabaseUrl, String supabaseKey) async {
    final response = await http.get(
      Uri.parse('$apiUrl/api/admin/get_admission_for_payment'),
      headers: {
        "supabase-url": supabaseUrl,
        "supabase-key": supabaseKey,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // Ensure the type safety by converting to List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(data['user'] ?? []);
      
    } else {
      throw Exception('Failed to form data');
    }
  }




  void startPaymentStreaming(String supabaseUrl, String supabaseKey) {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final members = await fetchPaymentForms(supabaseUrl, supabaseKey);
        final filteredMembers = members.where((member) => member['db_admission_table'] != null).toList();
        _streamController.add(filteredMembers);
      } catch (e) {
        print('Error fetching members: $e');
        _streamController.add([]);
      }
    });
  }

  // Fetch data manually (for search)
  Future<void> searchPaymentAdmissionForms(String supabaseUrl, String supabaseKey, String query) async {
    stopStreaming(); // Stop the automatic refresh
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/api/admin/search_payments?search=$query'),
        headers: {
          "supabase-url": supabaseUrl,
          "supabase-key": supabaseKey,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final searchResults = List<Map<String, dynamic>>.from(data['userData'] ?? []);
        _streamController.add(searchResults);
      } else {
        throw Exception('Failed to fetch search results');
      }
    } catch (e) {
      print('Error searching: $e');
      _streamController.add([]);
    }
  }

  Stream<List<Map<String, dynamic>>> streamPaymentForms(String supabaseUrl, String supabaseKey) async* {
  while (true) {
    try {
      // Fetch the admission forms (assuming fetchAdmissionForms is already defined)
      final members = await fetchPaymentForms(supabaseUrl, supabaseKey);
      
      // Filter out the members where db_admission_table is null
      final filteredMembers = members.where((member) {
        // Ensure db_admission_table is not null
        return member['db_admission_table'] != null;
      }).toList(); // Convert the iterable to a list

      // Emit the filtered list of members
      yield filteredMembers;
    } catch (e) {
      print('Error fetching members: $e');
      yield []; // Emit an empty list on error
    }

    // Delay the next fetch
    await Future.delayed(const Duration(seconds: 3)); // Refresh every 3 seconds
  }
}




//EXAM SCHEDULE
Future<List<Map<String, dynamic>>> fetchSchedule(String supabaseUrl, String supabaseKey) async {
    final response = await http.get(
      Uri.parse('$apiUrl/api/admin/check_exam_schedule'),
      headers: {
        "supabase-url": supabaseUrl,
        "supabase-key": supabaseKey,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // Ensure the type safety by converting to List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(data['exam_schedules'] ?? []);
      
    } else {
      throw Exception('Failed to form data');
    }
  }


  Stream<List<Map<String, dynamic>>> streamSchedule(String supabaseUrl, String supabaseKey) async* {
    while (true) {
      try {
        final members = await fetchSchedule(supabaseUrl, supabaseKey);
        yield members; // Emit the list of members
      } catch (e) {
        print('Error fetching members: $e');
        yield []; // Emit an empty list on error
      }

      await Future.delayed(const Duration(seconds: 3)); // Refresh every 10 seconds
    }
  }



  //GRADE SLOT
Future<List<Map<String, dynamic>>> fetchGradeSlot(String supabaseUrl, String supabaseKey) async {
    final response = await http.get(
      Uri.parse('$apiUrl/api/admin/get_grade_slot'),
      headers: {
        "supabase-url": supabaseUrl,
        "supabase-key": supabaseKey,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // Ensure the type safety by converting to List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(data['grade_slots'] ?? []);
      
    } else {
      throw Exception('Failed to form data');
    }
  }


  Stream<List<Map<String, dynamic>>> streamGradeSlot(String supabaseUrl, String supabaseKey) async* {
    while (true) {
      try {
        final members = await fetchGradeSlot(supabaseUrl, supabaseKey);
        yield members; // Emit the list of members
      } catch (e) {
        print('Error fetching members: $e');
        yield []; // Emit an empty list on error
      }

      await Future.delayed(const Duration(seconds: 3)); // Refresh every 10 seconds
    }
  }




//ALL SCHED
  Future<List<Map<String, dynamic>>> fetchScheduleById(int scheduleId, String supabaseUrl, String supabaseKey) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/api/admin/get_all_schedule'),
      headers: {
        'Content-Type': 'application/json',
        'supabase-url': supabaseUrl,
        'supabase-key': supabaseKey,
      },
      body: json.encode({
        'schedule_id': scheduleId,  // Send customer_id in the request body
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      //print('Response data: $data');  // Debugging output

      // Check if 'members' is a list or a map
      if (data['exam_schedules'] is List) {
        // If it's already a list, return it as a List<Map<String, dynamic>>
        return List<Map<String, dynamic>>.from(data['exam_schedules']);
      } else if (data['exam_schedules'] is Map) {
        // If it's a map (single member), convert it to a list with that single map
        return [data['exam_schedules']];
      } else {
        // Return an empty list if 'members' is neither a List nor a Map
        return [];
      }
    } else {
      throw Exception('Failed to load member');
    }
  } catch (e) {
    print('Error: $e');
    return []; // Return an empty list on error
  }
}





//ADMIN ACCOUNTS
Future<List<Map<String, dynamic>>> fetchAdminForms(String supabaseUrl, String supabaseKey) async {
    final response = await http.get(
      Uri.parse('$apiUrl/api/admin/get_admin_users'),
      headers: {
        "supabase-url": supabaseUrl,
        "supabase-key": supabaseKey,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // Ensure the type safety by converting to List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(data['user'] ?? []);
      
    } else {
      throw Exception('Failed to form data');
    }
  }

  Stream<List<Map<String, dynamic>>> streamAdminForms(String supabaseUrl, String supabaseKey) async* {
    while (true) {
      try {
        final members = await fetchAdminForms(supabaseUrl, supabaseKey);
        yield members; // Emit the list of members
      } catch (e) {
        print('Error fetching members: $e');
        yield []; // Emit an empty list on error
      }

      await Future.delayed(const Duration(seconds: 3)); // Refresh every 10 seconds
    }
  }




  /*Future<List<Map<String, dynamic>>> fetchAdmissionResult(String supabaseUrl, String supabaseKey) async {
    final response = await http.get(
      Uri.parse('$apiUrl/api/admin/get_admission_for_result'),
      headers: {
        "supabase-url": supabaseUrl,
        "supabase-key": supabaseKey,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // Ensure the type safety by converting to List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(data['user'] ?? []);
      
    } else {
      throw Exception('Failed to form data');
    }
  }*/

  Future<List<Map<String, dynamic>>> fetchAdmissionResult(String supabaseUrl, String supabaseKey) async {
  final response = await http.get(
    Uri.parse('$apiUrl/api/admin/get_admission_for_result'),
    headers: {
      "supabase-url": supabaseUrl,
      "supabase-key": supabaseKey,
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    
    // Ensure the type safety by converting to List<Map<String, dynamic>>
    List<Map<String, dynamic>> members = List<Map<String, dynamic>>.from(data['user'] ?? []);

    // Filter out duplicates by admission_id
    Map<int, Map<String, dynamic>> uniqueMembers = {};

    for (var member in members) {
      int admissionId = member['admission_id'];
      if (!uniqueMembers.containsKey(admissionId)) {
        uniqueMembers[admissionId] = member;
      }
    }

    // Return the list of unique members (based on admission_id)
    return uniqueMembers.values.toList();
  } else {
    throw Exception('Failed to fetch data');
  }
}


  Stream<List<Map<String, dynamic>>> streamAdmissionResult(String supabaseUrl, String supabaseKey) async* {
  while (true) {
    try {
      // Fetch the admission forms (assuming fetchAdmissionForms is already defined)
      final members = await fetchAdmissionResult(supabaseUrl, supabaseKey);
      
      // Filter out the members where db_admission_table is null
      final filteredMembers = members.where((member) {
        // Ensure db_admission_table is not null
        return member['db_admission_table'] != null;
      }).toList(); // Convert the iterable to a list

      // Emit the filtered list of members
      yield filteredMembers;
    } catch (e) {
      print('Error fetching members: $e');
      yield []; // Emit an empty list on error
    }

    // Delay the next fetch
    await Future.delayed(const Duration(seconds: 3)); // Refresh every 3 seconds
  }
}

}
