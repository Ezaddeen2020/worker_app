import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF121212) : Colors.grey[50],
      appBar: null,
      body: Center(
        child: Text(
          'favoritesPageTitle'.tr,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Color.fromARGB(255, 223, 216, 216) : Colors.black,
          ),
        ),
      ),
    );
  }
}
