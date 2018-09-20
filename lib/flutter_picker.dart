import 'dart:async';

import 'package:flutter/services.dart';
export 'Picker.dart';
export 'PickerLocalizationsDelegate.dart';

class FlutterPicker {
  static const MethodChannel _channel =
      const MethodChannel('flutter_picker');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
