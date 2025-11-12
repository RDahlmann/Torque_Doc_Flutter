import 'package:flutter/services.dart';

class InputFormats {
  static final onlyNumbers = FilteringTextInputFormatter.allow(RegExp(r'[0-9]'));
  static final onlyLetters = FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'));
  static final alphanumeric = FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'));

  static LengthLimitingTextInputFormatter maxLength(int length) =>
      LengthLimitingTextInputFormatter(length);
}