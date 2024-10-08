import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:my_template/constants.dart';
import 'package:my_template/core/auth/application/models/user.dart';
import 'package:my_template/core/auth/application/providers/auth_provider.dart';
import 'package:my_template/globals.dart';

class AuthManager {
  final BuildContext context;
  final WidgetRef ref;
  AuthManager(this.context, this.ref);

  ValueNotifier<bool> isLoading = ValueNotifier(false);

  Future<int> loginUsingPhonePassword({
    required String phone,
    required String password,
  }) async {
    ref.read(authProvider).clearUserData();
    isLoading.value = true;
    try {
      var response = await http.post(
        Uri.parse("$API_URL/auth/login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode({
          "phone": phone,
          "password": password,
        }),
      );
      isLoading.value = false;
      Map data = json.decode(response.body);
      print(response.body);

      if (response.statusCode == 200) {
        ref.read(authProvider).updateUserData(User.fromMap(data["data"]));
        return 1;
      } else {
        showToast(data["message"]);
        return -1;
      }
    } catch (error) {
      isLoading.value = false;
      showToast("An error occurred!");
      debugPrint(error.toString());
      return -1;
    }
  }

  Future<int> signUpUsingPhone({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
    required LatLng location,
    required String aadhar,
    required String state,
  }) async {
    ref.read(authProvider).clearUserData();
    isLoading.value = true;
    try {
      var response = await http.post(
        Uri.parse("$API_URL/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "role": role,
          "name": name,
          "email": email,
          "password": password,
          "phone": phone,
          "aadhar": aadhar,
          "address": {
            "state": state,
            // "city": "",
            // "street": "",
            // "zipCode": "",
          },
          "location": {
            "type": "Point",
            "coordinates": [location.latitude, location.longitude]
          }
        }),
      );
      isLoading.value = false;
      log(response.body);
      print(response.body);
      Map<String, dynamic> data = json.decode(response.body);
      log(data);

      if (response.statusCode == 200) {
        ref.read(authProvider).updateUserData(User.fromMap(data["data"]));

        return 1;
      } else {
        showToast(data["message"]);
        return -1;
      }
    } catch (err) {
      log(err, L: Level.error);
      showToast(err.toString());
      isLoading.value = false;
      return -1;
    }
  }

  Future<User?> searchForUser(String email) async {
    var response = await http.post(
      Uri.parse("$API_URL/auth/exists"),
      body: {"email": email},
    );

    if (response.body.isNotEmpty) {
      var data = json.decode(response.body);
      if (data["statusCode"] == 200) {
        return User.fromMap(data["data"]);
      }
    }
    return null;
  }
}
