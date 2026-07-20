import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'View/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Book'N'Glow",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF05352F),
          primary: const Color(0xFF05352F),
          secondary: const Color(0xFF9E7E45),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF9F5),
      ),
      home: const Login(),
    );
  }
}
