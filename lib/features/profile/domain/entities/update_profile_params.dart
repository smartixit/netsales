import 'dart:io';

import 'package:equatable/equatable.dart';

/// معاملات تحديث الملف الشخصي.
class UpdateProfileParams extends Equatable {
  const UpdateProfileParams({
    required this.userId,
    this.fullName,
    this.phoneNumber,
    this.email,
  });

  final int userId;
  final String? fullName;
  final String? phoneNumber;
  final String? email;

  @override
  List<Object?> get props => [userId, fullName, phoneNumber, email];
}

/// معاملات رفع الصورة الشخصية.
class UpdateAvatarParams extends Equatable {
  const UpdateAvatarParams({required this.userId, required this.avatar});

  final int userId;
  final File avatar;

  @override
  List<Object?> get props => [userId, avatar.path];
}
