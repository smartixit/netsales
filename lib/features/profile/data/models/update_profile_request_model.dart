import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

/// نموذج طلب تحديث الملف الشخصي للمستخدم المصادَق.
///
/// يُرسَل إلى: PUT /api/v1/users/{id}
/// الحقول اختيارية بالكامل (PATCH semantics) — يُرسَل ما تغيّر فقط.
class UpdateProfileRequestModel {
  const UpdateProfileRequestModel({
    this.fullName,
    this.phoneNumber,
    this.email,
    this.avatar,
  });

  final String? fullName;
  final String? phoneNumber;
  final String? email;

  /// الصورة الشخصية الجديدة — إن أُرفقت تُرسَل في نفس الطلب.
  final File? avatar;

  bool get hasAvatar => avatar != null;

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{};

    if (fullName != null && fullName!.isNotEmpty) {
      map['user_full_name'] = fullName;
    }
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      map['user_phone_number'] = phoneNumber;
    }
    if (email != null) {
      map['user_email'] = email!.isEmpty ? '' : email;
    }
    if (avatar != null) {
      map['user_profile_logo'] = await MultipartFile.fromFile(
        avatar!.path,
        filename: p.basename(avatar!.path),
      );
    }

    return FormData.fromMap(map);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (fullName != null && fullName!.isNotEmpty) 'user_full_name': fullName,
      if (phoneNumber != null && phoneNumber!.isNotEmpty)
        'user_phone_number': phoneNumber,
      if (email != null) 'user_email': email,
    };
  }
}
