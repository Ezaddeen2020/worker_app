/// Auth Models - نماذج المصادقة

/// نموذج طلب تسجيل الدخول
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return {'email': email, 'password': password};
  }

  bool isValid() {
    return email.isNotEmpty && password.isNotEmpty;
  }
}

/// نموذج طلب التسجيل
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String role;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    this.role = 'client',
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'password': password, 'phone': phone, 'role': role};
  }

  bool isValid() {
    return name.isNotEmpty && email.isNotEmpty && password.isNotEmpty && phone.isNotEmpty;
  }
}

/// نموذج استجابة المصادقة
class AuthResponse {
  final bool success;
  final String? token;
  final String? refreshToken;
  final String? message;
  final Map<String, dynamic>? userData;

  AuthResponse({required this.success, this.token, this.refreshToken, this.message, this.userData});

  factory AuthResponse.fromMap(Map<String, dynamic> map) {
    return AuthResponse(
      success: map['success'] ?? map['status'] == 'success',
      token: map['token'] ?? map['data']?['token'],
      refreshToken: map['refresh_token'] ?? map['data']?['refresh_token'],
      message: map['message'],
      userData: map['user'] ?? map['data']?['user'],
    );
  }

  factory AuthResponse.failure(String message) {
    return AuthResponse(success: false, message: message);
  }
}

/// نموذج طلب إعادة تعيين كلمة المرور
class ResetPasswordRequest {
  final String token;
  final String newPassword;

  ResetPasswordRequest({required this.token, required this.newPassword});

  Map<String, dynamic> toMap() {
    return {'token': token, 'password': newPassword};
  }
}

/// نموذج طلب نسيت كلمة المرور
class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({required this.email});

  Map<String, dynamic> toMap() {
    return {'email': email};
  }
}
