import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';

class ThemeController extends GetxController {
  static const _kKey = 'isLightTheme';
  final _box = GetStorage();
  final RxBool isLight = false.obs;

  @override
  void onInit() {
    super.onInit();
    final v = _box.read(_kKey);
    if (v is bool) isLight.value = v;
  }

  void toggle() {
    isLight.value = !isLight.value;
    _box.write(_kKey, isLight.value);
    // Also change Get's theme mode immediately if needed
    Get.changeThemeMode(isLight.value ? ThemeMode.light : ThemeMode.dark);
  }

  /// Set theme explicitly. Pass `true` for light theme, `false` for dark.
  void setTheme(bool light) {
    isLight.value = light;
    _box.write(_kKey, isLight.value);
    Get.changeThemeMode(isLight.value ? ThemeMode.light : ThemeMode.dark);
  }
}

