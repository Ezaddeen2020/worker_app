/// User Model - نموذج المستخدم
import '../../workers/models/worker_profile_model.dart';

class User {
  final String id;
  final String name;
  final String phone;
  final String imagePath;
  final DateTime createdAt;
  final String role; // 'client' or 'worker'
  final WorkerProfile? workerProfile;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.imagePath,
    this.role = 'client',
    this.workerProfile,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// نسخة محدثة من User
  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? imagePath,
    String? role,
    WorkerProfile? workerProfile,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      imagePath: imagePath ?? this.imagePath,
      role: role ?? this.role,
      workerProfile: workerProfile ?? this.workerProfile,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// تحويل User إلى Map (لحفظ في ملف JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'imagePath': imagePath,
      'role': role,
      'workerProfile': workerProfile?.toMap(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// إنشاء User من Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      imagePath: map['imagePath'] ?? '',
      role: map['role'] ?? 'client',
      workerProfile: map['workerProfile'] != null
          ? WorkerProfile.fromMap(Map<String, dynamic>.from(map['workerProfile']))
          : null,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// التحقق من صحة نموذج المستخدم
  bool isValid() {
    if (id.isEmpty) return false;
    if (name.isEmpty || name.length < 2) return false;
    if (phone.isEmpty || phone.length < 9) return false;
    if (imagePath.isEmpty) return false;
    if (role != 'client' && role != 'worker') return false;
    return true;
  }

  /// إنشاء مستخدم فارغ
  factory User.empty() {
    return User(id: '', name: '', phone: '', imagePath: '', role: 'client');
  }

  /// التحقق من صحة البيانات وإرجاع جميع الأخطاء
  List<String> validate() {
    final errors = <String>[];

    if (id.isEmpty) errors.add('معرف المستخدم مطلوب');
    if (name.isEmpty) errors.add('الاسم مطلوب');
    if (name.length < 2) errors.add('الاسم قصير جداً');
    if (phone.isEmpty) errors.add('رقم الهاتف مطلوب');
    if (phone.length < 9) errors.add('رقم الهاتف غير صحيح (يجب أن يكون 9 أرقام على الأقل)');
    if (imagePath.isEmpty) errors.add('الصورة مطلوبة');
    if (role != 'client' && role != 'worker') errors.add('الدور غير صحيح');

    return errors;
  }

  @override
  String toString() => 'User(id: $id, name: $name, phone: $phone, role: $role)';
}
