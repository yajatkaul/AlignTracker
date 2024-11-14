import 'dart:convert';

import 'package:aligntracker/env.dart';
import 'package:aligntracker/pages/home.dart';
import 'package:aligntracker/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> _login(BuildContext context) async {
    if (isLoading) return;

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    final String username = _usernameController.text;
    final String password = _passwordController.text;

    final response = await http.post(
      Uri.parse('$serverURL/api/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'displayName': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final cookie = response.headers['set-cookie'];
      if (cookie != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('session_cookie', cookie);
      }

      if (mounted) {
        showToast(context, "Logged in successfully", true);
        isLoading = false;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      if (mounted) {
        final responseBody = jsonDecode(response.body);
        final resultMessage = responseBody['error'] ?? 'Internal Server Error';
        showToast(context, resultMessage, false);
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                height: 350,
                child: LottieBuilder.asset('assets/lottie/buslogin.json')),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Username",
                  )),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Password",
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                    onPressed: () => _login(context),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Login",
                          )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
