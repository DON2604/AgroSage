import 'package:flutter/material.dart';
import 'screens/dashboard/dashboardScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farm Genius',
      theme: ThemeData.dark(),
      home: const DashboardScreen(),
    );
  }
}