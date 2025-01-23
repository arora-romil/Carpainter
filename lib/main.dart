import 'package:carpainter/screens/getStarted.dart';
import 'package:carpainter/screens/homePage.dart';
import 'package:carpainter/screens/loginScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/getstarted",
      routes: {
        "/": (context) => HomePage(),
        "/home": (context) => HomePage(),
        "/login": (context) => LoginPage(),
        "/getstarted": (context) => Getstarted(),
      },
    );
  }
}
