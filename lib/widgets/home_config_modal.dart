import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../features/home/controllers/home_config_controller.dart';
import '../features/home/models/home_config_model.dart';

/// Home Configuration Modal - نافذة إعدادات الصفحة الرئيسية
class HomeConfigModal extends StatefulWidget {
  @override
  _HomeConfigModalState createState() => _HomeConfigModalState();
}

class _HomeConfigModalState extends State<HomeConfigModal> {
  late HomeConfigController configController;
  late HomeConfig tempConfig;

  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _categoryControllers = [];

  @override
  void initState() {
    super.initState();
    configController = Get.find<HomeConfigController>();
    tempConfig = configController.config;

    // Initialize category controllers
    for (var category in tempConfig.categories) {
      if (category.name != 'الكل') {
        _categoryControllers.add(TextEditingController(text: category.name));
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _categoryControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('homeConfig'.tr),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: 'headerTitleLabel'.tr,
                  initialValue: tempConfig.headerTitle,
                  onChanged: (value) => tempConfig = tempConfig.copyWith(headerTitle: value),
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: 'headerSubtitleLabel'.tr,
                  initialValue: tempConfig.headerSubtitle,
                  onChanged: (value) => tempConfig = tempConfig.copyWith(headerSubtitle: value),
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: 'searchHintLabel'.tr,
                  initialValue: tempConfig.searchHint,
                  onChanged: (value) => tempConfig = tempConfig.copyWith(searchHint: value),
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: 'featuredWorkersTitleLabel'.tr,
                  initialValue: tempConfig.featuredWorkersTitle,
                  onChanged: (value) =>
                      tempConfig = tempConfig.copyWith(featuredWorkersTitle: value),
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: 'categoriesTitleLabel'.tr,
                  initialValue: tempConfig.categoriesTitle,
                  onChanged: (value) => tempConfig = tempConfig.copyWith(categoriesTitle: value),
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: 'allWorkersTitleLabel'.tr,
                  initialValue: tempConfig.allWorkersTitle,
                  onChanged: (value) => tempConfig = tempConfig.copyWith(allWorkersTitle: value),
                ),
                SizedBox(height: 16),
                _buildTextField(
                  label: 'emptyResultsMessageLabel'.tr,
                  initialValue: tempConfig.emptyResultsMessage,
                  onChanged: (value) =>
                      tempConfig = tempConfig.copyWith(emptyResultsMessage: value),
                ),
                SizedBox(height: 24),
                Text('categoriesLabel'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ...List.generate(_categoryControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _categoryControllers[index],
                            decoration: InputDecoration(
                              labelText: '${'categoryLabel'.tr} ${index + 1}',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'pleaseEnterCategoryName'.tr;
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeCategory(index),
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _addCategory,
                  icon: Icon(Icons.add),
                  label: Text('addCategory'.tr),
                ),
                SizedBox(height: 16),
                Text('themeColorsLabel'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Container(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: tempConfig.themeColors.length,
                    itemBuilder: (context, index) {
                      final colorConfig = tempConfig.themeColors[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(colorConfig.name, style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('cancel'.tr)),
        ElevatedButton(onPressed: _saveConfig, child: Text('saveChanges'.tr)),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'pleaseFillThisField'.tr;
        }
        return null;
      },
    );
  }

  void _addCategory() {
    setState(() {
      _categoryControllers.add(TextEditingController());
    });
  }

  void _removeCategory(int index) {
    setState(() {
      _categoryControllers[index].dispose();
      _categoryControllers.removeAt(index);
    });
  }

  void _saveConfig() {
    if (_formKey.currentState!.validate()) {
      // Collect category names
      final categoryNames = _categoryControllers
          .map((controller) => controller.text)
          .where((text) => text.isNotEmpty)
          .toList();

      // Update categories in config
      final updatedCategories = [
        CategoryConfig(name: 'الكل', displayName: 'الكل', icon: 'all'),
        ...categoryNames.map(
          (name) => CategoryConfig(name: name, displayName: name, icon: _getIconForCategory(name)),
        ),
      ];

      tempConfig = tempConfig.copyWith(categories: updatedCategories);

      // Save the configuration
      configController.saveConfig(tempConfig);

      Get.snackbar('success'.tr, 'dataUpdatedSuccessfully'.tr);
      Navigator.of(context).pop();
    }
  }

  String _getIconForCategory(String category) {
    final categoryIcons = {
      'كهربائي': 'electrician',
      'نجار': 'carpenter',
      'حداد': 'blacksmith',
      'سباك': 'plumber',
      'دهان': 'painter',
      'بناء': 'builder',
      'تكييف': 'ac',
      'ميكانيكي': 'mechanic',
    };

    return categoryIcons[category] ?? 'worker';
  }
}
