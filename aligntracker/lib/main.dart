import 'package:aligntracker/auth/login.dart';
import 'package:aligntracker/pages/home.dart';
import 'package:aligntracker/theme/dark_theme.dart';
import 'package:aligntracker/theme/light_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<String?> _getSessionCookie() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_cookie');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      home: FutureBuilder<String?>(
        future: _getSessionCookie(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading session"));
          } else {
            if (snapshot.data != null) {
              return const HomePage();
            } else {
              return const LoginPage();
            }
          }
        },
      ),
    );
  }
}
