import 'package:flutter/material.dart';
import 'package:meal_planning/screens/main_screen/main_screen.dart';

class BottomNavBarWidget extends StatelessWidget {
  const BottomNavBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: navBarInd,
        builder: (BuildContext context, int val, _) {
          return BottomNavigationBar(
            currentIndex: navBarInd.value,
            selectedItemColor: Colors.green,
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.no_meals), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: ''),
            ],
            onTap: (ind) {
              navBarInd.value = ind;
              // controllerAni.forward(from: 0);
              navBarInd.notifyListeners();
            },
          );
        });
  }
}


