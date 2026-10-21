import 'package:flutter/widgets.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class FormValidators {
  FormValidators._();

  static FormFieldValidator<String> _transform(
    String Function(String value) transformer,
    FormFieldValidator<String> validator,
  ) {
    return (value) => validator(value == null ? null : transformer(value));
  }

  static FormFieldValidator<String> required({String? fieldName}) {
    return FormBuilderValidators.required(
      errorText: fieldName == null ? 'هذا الحقل مطلوب.' : '$fieldName مطلوب.',
    );
  }

  static FormFieldValidator<String> nameValidator({
    String? fieldName,
    int minWordsCount = 4,
    int maxWordsCount = 6,
    bool isRequired = true,
  }) {
    return _transform(
      (value) => value.trim(),
      FormBuilderValidators.compose([
        if (isRequired) required(fieldName: fieldName),
        FormBuilderValidators.minWordsCount(
          minWordsCount,
          errorText: 'الاسم يجب ان يكون مكون من $minWordsCount كلمة على الاقل',
          checkNullOrEmpty: false,
        ),
        FormBuilderValidators.maxWordsCount(
          maxWordsCount,
          errorText: 'الاسم يجب ان يكون مكون من $maxWordsCount كلمة على الاكثر',
          checkNullOrEmpty: false,
        ),
      ]),
    );
  }

  static FormFieldValidator<String> phoneValidator({
    String? fieldName,
    bool isRequired = true,
    int minLength = 9,
    int maxLength = 9,
    String startsWith = '7',
  }) {
    return _transform(
      (value) => value.replaceAll(' ', ''),
      FormBuilderValidators.compose([
        if (isRequired) required(fieldName: fieldName),
        FormBuilderValidators.startsWith(
          startsWith,
          errorText: 'رقم الجوال يجب ان يبدأ بـ $startsWith',
          checkNullOrEmpty: false,
        ),
        FormBuilderValidators.phoneNumber(checkNullOrEmpty: false),
        FormBuilderValidators.minLength(
          minLength,
          errorText: 'رقم الجوال يجب ان يكون مكون من $minLength رقم على الاقل',
          checkNullOrEmpty: false,
        ),
        FormBuilderValidators.maxLength(
          maxLength,
          errorText: 'رقم الجوال يجب ان يكون مكون من $maxLength رقم على الاكثر',
          checkNullOrEmpty: false,
        ),
      ]),
    );
  }

  static FormFieldValidator<String> otpValidator({
    String? fieldName,
    int length = 6,
    bool isRequired = true,
  }) {
    return _transform(
      (value) => value.replaceAll(' ', ''),
      FormBuilderValidators.compose([
        if (isRequired) required(fieldName: fieldName ?? 'رمز التحقق'),
        FormBuilderValidators.equalLength(
          length,
          errorText: 'رمز التحقق يجب أن يتكون من $length أرقام',
          checkNullOrEmpty: false,
        ),
        FormBuilderValidators.numeric(
          errorText: 'رمز التحقق يجب أن يحتوي على أرقام فقط',
          checkNullOrEmpty: false,
        ),
      ]),
    );
  }

  static FormFieldValidator<String> addressValidator({
    String? fieldName,
    int minWordsCount = 1,
    int maxWordsCount = 255,
    bool isRequired = false,
  }) {
    return _transform(
      (value) => value.trim(),
      FormBuilderValidators.compose([
        if (isRequired) required(fieldName: fieldName),
        FormBuilderValidators.minWordsCount(
          minWordsCount,
          errorText:
              'العنوان يجب ان يكون مكون من $minWordsCount كلمة على الاقل',
          checkNullOrEmpty: false,
        ),
        FormBuilderValidators.maxWordsCount(
          maxWordsCount,
          errorText:
              'العنوان يجب ان يكون مكون من $maxWordsCount كلمة على الاكثر',
          checkNullOrEmpty: false,
        ),
      ]),
    );
  }

  static FormFieldValidator<String> passwordValidator({
    String? fieldName,
    int minLength = 8,
    bool isRequired = true,
  }) {
    return _transform(
      (value) => value.replaceAll(' ', ''),
      FormBuilderValidators.compose([
        if (isRequired) required(fieldName: fieldName),
        FormBuilderValidators.minLength(
          minLength,
          errorText: 'كلمة المرور يجب ان تكون مكون من $minLength حرف على الاقل',
          checkNullOrEmpty: false,
        ),
        FormBuilderValidators.password(
          minLength: minLength,
          checkNullOrEmpty: false,
        ),
      ]),
    );
  }

  static FormFieldValidator<String> confirmPasswordValidator({
    String? fieldName,
    required TextEditingController passwordController,
    bool isRequired = true,
  }) {
    return _transform(
      (value) => value.replaceAll(' ', ''),
      FormBuilderValidators.compose([
        if (isRequired) required(fieldName: fieldName),
        (value) {
          final cleanPassword = passwordController.text.replaceAll(' ', '');
          return value == cleanPassword ? null : 'كلمة المرور غير متطابقة';
        },
      ]),
    );
  }

  static FormFieldValidator<String> emailValidator({
    String? fieldName,
    bool isRequired = true,
  }) {
    return _transform(
      (value) => value.replaceAll(' ', ''),
      FormBuilderValidators.compose([
        if (isRequired) required(fieldName: fieldName),
        FormBuilderValidators.email(checkNullOrEmpty: false),
      ]),
    );
  }

  static FormFieldValidator<String> descriptionValidator({
    String? fieldName,
    int minLength = 3,
    int maxLength = 255,
    bool isRequired = true,
  }) {
    return _transform(
      (value) => value.trim(),
      FormBuilderValidators.compose([
        if (isRequired) required(fieldName: fieldName),
        FormBuilderValidators.minLength(
          minLength,
          errorText:
              '${fieldName ?? 'الوصف'} يجب ان يكون مكون من $minLength حرف على الاقل',
          checkNullOrEmpty: false,
        ),
        FormBuilderValidators.maxLength(
          maxLength,
          errorText:
              '${fieldName ?? 'الوصف'} يجب ان يكون مكون من $maxLength حرف على الاكثر',
          checkNullOrEmpty: false,
        ),
      ]),
    );
  }

  static FormFieldValidator<String> integerValidator({
    String? fieldName,
    bool isRequired = true,
  }) {
    return FormBuilderValidators.compose([
      if (isRequired) required(fieldName: fieldName),
      FormBuilderValidators.integer(
        errorText: '$fieldName يجب ان يكون عدد صحيح',
        checkNullOrEmpty: false,
      ),
    ]);
  }

  static FormFieldValidator<String> doubleValidator({
    String? fieldName,
    bool isRequired = true,
  }) {
    return FormBuilderValidators.compose([
      if (isRequired) required(fieldName: fieldName),
      FormBuilderValidators.float(
        errorText: '$fieldName يجب ان يكون عدد عشري',
        checkNullOrEmpty: false,
      ),
    ]);
  }

  static FormFieldValidator<String> amountValidator({
    String? fieldName,
    bool isRequired = true,
    double minValue = 0,
    double? maxValue,
    int decimalPlaces = 2,
  }) {
    final name = fieldName ?? 'المبلغ';
    return _transform(
      (value) => value.replaceAll(',', '').trim(),
      FormBuilderValidators.compose([
        if (isRequired) required(fieldName: name),
        FormBuilderValidators.float(
          errorText: '$name يجب ان يكون رقم صحيح',
          checkNullOrEmpty: false,
        ),
        if (minValue != double.negativeInfinity)
          FormBuilderValidators.min(
            minValue,
            errorText: '$name يجب ان يكون اكبر من $minValue',
            checkNullOrEmpty: false,
          ),
        if (maxValue != null)
          FormBuilderValidators.max(
            maxValue,
            errorText: '$name يجب ان يكون اقل من $maxValue',
            checkNullOrEmpty: false,
          ),
        (value) {
          if (value == null || value.isEmpty) return null;
          final parts = value.split('.');
          if (parts.length == 2 && parts[1].length > decimalPlaces) {
            return '$name لا يقبل اكثر من $decimalPlaces منازل عشرية';
          }
          return null;
        },
      ]),
    );
  }

  static FormFieldValidator<String> percentageValidator({
    String? fieldName,
    bool isRequired = true,
  }) {
    return FormBuilderValidators.compose([
      if (isRequired) required(fieldName: fieldName),
      FormBuilderValidators.integer(
        errorText: '$fieldName يجب ان يكون نسبة مئوية صحيحة',
        checkNullOrEmpty: false,
      ),
    ]);
  }

  static FormFieldValidator<String> customTextValidator({
    String? Function(String?)? validator,
    String? fieldName,
    String? startsWith,
    int? minLength = 1,
    int? maxLength = 255,
    int? minWordsCount = 1,
    int? maxWordsCount,
    bool isRequired = true,
  }) {
    return FormBuilderValidators.compose([
      if (isRequired) required(fieldName: fieldName),
      if (minWordsCount != null)
        FormBuilderValidators.minWordsCount(
          minWordsCount,
          checkNullOrEmpty: false,
          errorText: '$fieldName يجب ان يكون $minWordsCount كلمة على الاقل',
        ),
      if (maxWordsCount != null)
        FormBuilderValidators.maxWordsCount(
          maxWordsCount,
          checkNullOrEmpty: false,
          errorText: '$fieldName يجب ان يكون $maxWordsCount كلمة على الاكثر',
        ),
      if (minLength != null)
        FormBuilderValidators.minLength(
          minLength,
          checkNullOrEmpty: false,
          errorText: '$fieldName يجب ان يكون $minLength حرف على الاقل',
        ),
      if (maxLength != null)
        FormBuilderValidators.maxLength(
          maxLength,
          checkNullOrEmpty: false,
          errorText: '$fieldName يجب ان يكون $maxLength حرف على الاكثر',
        ),
      if (startsWith != null)
        FormBuilderValidators.startsWith(
          startsWith,
          checkNullOrEmpty: false,
          errorText: '$fieldName يجب ان يبدأ بـ $startsWith',
        ),
      validator != null
          ? _transform((value) => value.trim(), validator)
          : (value) => null,
    ]);
  }
}
