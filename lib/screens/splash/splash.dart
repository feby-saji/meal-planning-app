import 'package:flutter/material.dart';
import 'package:meal_planning/hive_db/db_functions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      HiveDb().getLoggedInUser(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Text('splash'),
    );
  }
}
