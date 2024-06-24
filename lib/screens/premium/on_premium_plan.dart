import 'package:flutter/material.dart';

class OnPremiumPlanScreen extends StatelessWidget {
  const OnPremiumPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Premium Plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(child: Text('You are alrady on Premium')),
        ],
      ),
    );
  }
}
