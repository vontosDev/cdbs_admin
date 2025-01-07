import 'package:cdbs_admin/shared/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    _checkSession();
  }

  Future<http.Response> _login(String email, String password) {
    String url = 'https://donboscoapi.vercel.app/api/admin/login_account';
    return http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'supabase-url': supabaseUrl, // Add Supabase URL
        'supabase-key': supabaseKey, // Add Supabase Key
      },
      body: json.encode({'email': email, 'password': password}),
    );
  }

  /*void _checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getInt('uid');
      final adminType = prefs.getString('adminType');
      final departmentId = prefs.getInt('departmentId');
      final firstName = prefs.getString('firstName');
      final middleName = prefs.getString('middleName');
      final lastName = prefs.getString('lastName');
      final email = prefs.getString('email');
      final department = prefs.getString('department');

      if (uid != null &&
          adminType != null &&
          departmentId != null &&
          firstName != null &&
          middleName != null &&
          lastName != null &&
          email != null &&
          email != department) {
        emit(AuthSuccess(
            uid: uid,
            adminType: adminType,
            departmentId: departmentId,
            firstName: firstName,
            middleName: middleName,
            lastName: lastName,
            email: email,
            department: department!));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      emit(AuthFailure('Failed to check session: $e'));
    }
  }*/

  void _checkSession() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getInt('uid');
    final adminType = prefs.getString('adminType');
    final departmentId = prefs.getInt('departmentId');
    final firstName = prefs.getString('firstName');
    final middleName = prefs.getString('middleName');
    final lastName = prefs.getString('lastName');
    final email = prefs.getString('email');
    final department = prefs.getString('department');

    // Check if all values are null
    if (uid == null &&
        adminType == null &&
        departmentId == null &&
        firstName == null &&
        middleName == null &&
        lastName == null &&
        email == null &&
        department == null) {
      // Clear SharedPreferences if all values are null
      await prefs.clear();
      emit(AuthInitial());
    } else if (uid != null &&
        adminType != null &&
        departmentId != null &&
        firstName != null &&
        middleName != null &&
        lastName != null &&
        email != null &&
        department != null) {
      // Emit AuthSuccess if all required values are present
      emit(AuthSuccess(
          uid: uid,
          adminType: adminType,
          departmentId: departmentId,
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
          email: email,
          department: department));
    } else {
      // Emit AuthInitial for incomplete data
      emit(AuthInitial());
    }
  } catch (e) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(AuthFailure('Failed1 to check session: $e'));
  }
}


  @override
  void onChange(Change<AuthState> change) {
    super.onChange(change);
    print('AuthBloc - $change');
  }

  void _onAuthLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final email = event.email;
      final password = event.password;
      // Email validation using regex
      if (!RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
          .hasMatch(email)) {
        emit(AuthFailure('Invalid Email address'));
        return;
      }
      if (password.length < 6) {
        emit(AuthFailure('Password cannot be less than 6 characters'));
        return;
      }

      final response = await _login(email, password);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] == "Login successful") {
          final user = data['user'];

          // Save session in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('uid', user['admin_id']);
          await prefs.setString('adminType', user['db_admin_type']['admin_type']);
          await prefs.setString('firstName', user['first_name']);
          await prefs.setString('middleName', user['middle_name']);
          await prefs.setString('lastName', user['last_name']);
          await prefs.setString('email', user['email_address']);
          await prefs.setString('department', user['db_admin_department']['department']);
          await prefs.setInt('departmentId', user['department_id']);

          // Emit success state with user data

          print("ADMINTYPE: ${user['admin_type']}");
          emit(AuthSuccess(
            uid: user['admin_id'],
            adminType: user['db_admin_type']['admin_type'],
            firstName: user['first_name'],
            middleName: user['middle_name'],
            lastName: user['last_name'],
            email: user['email_address'],
            department: user['db_admin_department']['department'],
            departmentId: user['department_id'],
          ));
        } else {
          emit(AuthFailure('Login failed'));
        }
      } else {
        emit(AuthFailure('Error: ${response.statusCode}'));
      }
    } catch (e) {
      emit(AuthFailure('1 ${e.toString()}'));
    }
  }

  void _onAuthLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('uid');
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
