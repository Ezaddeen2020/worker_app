import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../features/posts/models/project_model.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import '../features/posts/services/post_service.dart';
import '../utils/image_cache_manager.dart';

class AddProjectDialog extends StatefulWidget {
  final dynamic user;
  final AuthController authController;
  final PostService postService;

  const AddProjectDialog({
    super.key,
    required this.user,
    required this.authController,
    required this.postService,
  });

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  final List<String> _selectedImages = [];
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _priceController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('addNewPost'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // معاينة الصور المختارة
            if (_selectedImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  height: 120,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_selectedImages.length, (index) {
                        return Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: FutureBuilder<ImageProvider>(
                                  future: ImageCacheManager().getCachedLocalImage(
                                    _selectedImages[index],
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: snapshot.data!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image, color: Colors.grey),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedImages.removeAt(index)),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
              ),

            // زر اختيار صور
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final imagePath = await widget.authController.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (imagePath != null) {
                        setState(() => _selectedImages.add(imagePath));
                      }
                    },
                    icon: const Icon(Icons.image),
                    label: Text('selectImage'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 5, 95, 66),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final imagePath = await widget.authController.pickImage(
                        source: ImageSource.camera,
                      );
                      if (imagePath != null) {
                        setState(() => _selectedImages.add(imagePath));
                      }
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: Text('camera'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // حقول النص
            TextField(
              controller: _titleController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'projectTitle'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 3,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'projectDescription'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'priceOptional'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.attach_money),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text('cancel'.tr),
        ),
        ElevatedButton(
          onPressed: _isPublishing
              ? null
              : () async {
                  final title = _titleController.text.trim();
                  final description = _descController.text.trim();

                  if (title.isEmpty) {
                    Get.snackbar('error'.tr, 'enterProjectTitle'.tr);
                    return;
                  }

                  if (description.isEmpty) {
                    Get.snackbar('error'.tr, 'enterProjectDescription'.tr);
                    return;
                  }

                  // التأكد من وجود userId صالح
                  final userId = widget.user.id?.toString() ?? '';
                  if (userId.isEmpty) {
                    print('AddProjectDialog: user.id is empty or null');
                    Get.snackbar('error'.tr, 'خطأ في بيانات المستخدم');
                    return;
                  }

                  final project = Project(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    workerId: userId,
                    title: title,
                    description: description,
                    images: _selectedImages,
                    price: double.tryParse(_priceController.text),
                    createdAt: DateTime.now(),
                  );

                  // Debug print
                  print(
                    'AddProjectDialog: Creating project - id: ${project.id}, workerId: ${project.workerId}, title: ${project.title}',
                  );

                  setState(() => _isPublishing = true);
                  final ok = await widget.postService.addPost(project, userId);
                  if (mounted) {
                    setState(() => _isPublishing = false);
                  }

                  if (ok) {
                    Get.back();
                    Get.snackbar('success'.tr, 'postAddedSuccessfully'.tr);
                  } else {
                    Get.snackbar('error'.tr, 'failedToAddPost'.tr);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 5, 95, 66),
            foregroundColor: Colors.white,
          ),
          child: _isPublishing
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text('publish'.tr),
        ),
      ],
    );
  }
}
