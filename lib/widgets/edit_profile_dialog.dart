import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import '../utils/image_cache_manager.dart';

class EditProfileDialog extends StatefulWidget {
  final dynamic user;
  final AuthController authController;

  const EditProfileDialog({super.key, required this.user, required this.authController});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  String? _selectedImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _selectedImagePath = widget.user.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            _buildHeader(isDark),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(height: 20),

                    // Profile Picture Section
                    _buildProfilePictureSection(isDark),

                    SizedBox(height: 32),

                    // Form Fields
                    _buildFormFields(isDark),

                    SizedBox(height: 24),

                    // Save Button
                    _buildSaveButton(isDark),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 18, color: isDark ? Colors.white : Colors.black87),
            ),
          ),

          // Title in center
          Expanded(
            child: Text(
              'تعديل الملف الشخصي',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),

          // Empty space for balance
          SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection(bool isDark) {
    return Column(
      children: [
        // Profile Picture with gradient border
        GestureDetector(
          onTap: _showImagePickerOptions,
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFCAF45),
                      Color(0xFFF77737),
                      Color(0xFFE1306C),
                      Color(0xFFC13584),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                padding: EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Color(0xFF1E1E1E) : Colors.white,
                  ),
                  padding: EdgeInsets.all(2),
                  child: ClipOval(child: _buildProfileImage(_selectedImagePath, 90)),
                ),
              ),

              // Camera icon overlay
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(0xFF0095F6),
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? Color(0xFF1E1E1E) : Colors.white, width: 2),
                  ),
                  child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12),

        // Change photo button
        GestureDetector(
          onTap: _showImagePickerOptions,
          child: Text(
            'تغيير الصورة',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0095F6)),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields(bool isDark) {
    return Column(
      children: [
        // Name Field
        _buildTextField(
          controller: _nameController,
          label: 'الاسم',
          icon: Icons.person_outline,
          isDark: isDark,
        ),

        SizedBox(height: 16),

        // Phone Field
        _buildTextField(
          controller: _phoneController,
          label: 'رقم الهاتف',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          isDark: isDark,
        ),

        SizedBox(height: 16),

        // User type info (read-only)
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF262626) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 5, 95, 66).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.user.role == 'worker' ? Icons.engineering : Icons.person,
                  color: Color.fromARGB(255, 5, 95, 66),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('نوع الحساب', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    SizedBox(height: 2),
                    Text(
                      widget.user.role == 'worker' ? 'عامل محترف' : 'عميل',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.lock_outline, size: 16, color: Colors.grey[500]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF262626) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          floatingLabelStyle: TextStyle(color: Color(0xFF0095F6), fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.grey[600], size: 22),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF0095F6),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          disabledBackgroundColor: Colors.grey[400],
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text('حفظ التغييرات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showImagePickerOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),

                Text(
                  'تغيير صورة الملف الشخصي',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 24),

                // Camera option
                _buildImageOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'التقاط صورة',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                  isDark: isDark,
                ),

                // Gallery option
                _buildImageOption(
                  icon: Icons.photo_library_outlined,
                  label: 'اختيار من المعرض',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                  isDark: isDark,
                ),

                // Remove photo option (if has photo)
                if (_selectedImagePath != null && _selectedImagePath!.isNotEmpty)
                  _buildImageOption(
                    icon: Icons.delete_outline,
                    label: 'إزالة الصورة الحالية',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImagePath = null;
                      });
                    },
                    isDark: isDark,
                    isDestructive: true,
                  ),

                SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.1)
              : (isDark ? Color(0xFF262626) : Colors.grey[100]),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : (isDark ? Colors.white : Colors.black87),
          size: 22,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: isDestructive ? Colors.red : (isDark ? Colors.white : Colors.black),
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final imagePath = await widget.authController.pickImage(source: source);
    if (imagePath != null) {
      setState(() {
        _selectedImagePath = imagePath;
      });
    }
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    // التحقق من الاسم
    if (name.isEmpty || name.length < 2) {
      Get.snackbar(
        'خطأ',
        'الرجاء إدخال اسم صحيح (حرفان على الأقل)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    // التحقق من رقم الهاتف
    if (phone.isEmpty || phone.length < 9) {
      Get.snackbar(
        'خطأ',
        'الرجاء إدخال رقم هاتف صحيح (9 أرقام على الأقل)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    // التحقق من أن الهاتف يحتوي على أرقام فقط
    if (!RegExp(r'^[0-9+\-\s]+$').hasMatch(phone)) {
      Get.snackbar(
        'خطأ',
        'رقم الهاتف يجب أن يحتوي على أرقام فقط',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    // إغلاق النافذة فوراً
    Get.back();

    // تنفيذ الحفظ في الخلفية
    widget.authController.updateUser(name: name, phone: phone, imagePath: _selectedImagePath);
  }

  Widget _buildProfileImage(String? imagePath, double size) {
    if (imagePath != null && imagePath.isNotEmpty) {
      return FutureBuilder<ImageProvider>(
        future: ImageCacheManager().getCachedLocalImage(imagePath),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image: snapshot.data!, fit: BoxFit.cover),
              ),
            );
          } else {
            return _buildPlaceholder(size);
          }
        },
      );
    }
    return _buildPlaceholder(size);
  }

  Widget _buildPlaceholder(double size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? Colors.grey[800] : Colors.grey[300],
      ),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }
}
