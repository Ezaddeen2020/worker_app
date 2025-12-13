import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsMetaSection extends StatelessWidget {
  final bool isDark;
  const SettingsMetaSection({required this.isDark, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('metaAccountsCenter'.tr, isDark),
        _buildMetaAccountsCenter(isDark),
        const SizedBox(height: 8),
        _buildSectionHeader('howToUseApp'.tr, isDark),
        // ... هنا يمكنك إضافة شرح أو روابط تعليمية ...
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    ),
  );
  Widget _buildMetaAccountsCenter(bool isDark) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? Color(0xFF1E1E1E) : Colors.grey[50],
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.all_inclusive, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'metaAccountsCenter'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Text(
                'accountCenterDescription'.tr,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[500]),
      ],
    ),
  );
}
