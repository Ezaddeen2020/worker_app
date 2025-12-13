import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/features/workers/controllers/worker_controller.dart';
import 'package:workers/features/home/controllers/home_config_controller.dart';

class SearchHome extends StatelessWidget {
  final WorkerController controller;
  final HomeConfigController configController;
  final bool isDark;
  const SearchHome({
    required this.controller,
    required this.configController,
    required this.isDark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      color: Colors.transparent,
      child: Obx(
        () => TextField(
          textAlign: TextAlign.right,
          style: TextStyle(color: isDark ? Colors.white : Color(0xFFD6C3A5)),
          decoration: InputDecoration(
            hintText: configController.config.searchHint,
            hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Color(0xFFD6C3A5)),
            prefixIcon: Icon(Icons.search, color: Color(0xFFD6C3A5)),
            filled: true,
            fillColor: isDark ? Color(0xFF353E47) : Color(0xFF434B53),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFD6C3A5), width: 1.1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFD6C3A5), width: 1.1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFFD6C3A5), width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          ),
          onChanged: (value) => controller.searchWorkers(value),
        ),
      ),
    );
  }
}
