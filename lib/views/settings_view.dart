import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find<AuthController>();
    final ThemeController themeCtrl = Get.find<ThemeController>();
    final theme = Theme.of(context);
    final textPrimaryColor = theme.textTheme.bodyLarge?.color ?? const Color(0xFF0B1220);
    final textSecondaryColor = theme.textTheme.bodyMedium?.color ?? const Color(0xFF4B5563);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        title: Text('Settings', style: GoogleFonts.outfit(color: textPrimaryColor)),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account', style: GoogleFonts.outfit(color: textPrimaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Obx(() {
              final user = auth.currentUser;
               if (user == null) return Text('Not signed in', style: GoogleFonts.outfit(color: textSecondaryColor));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('Username: ${user.username}', style: GoogleFonts.outfit(color: textPrimaryColor)),
                  const SizedBox(height: 6),
                   Text('Display name: ${user.displayName}', style: GoogleFonts.outfit(color: textPrimaryColor)),
                ],
              );
            }),
            const SizedBox(height: 20),
            Text('App', style: GoogleFonts.outfit(color: textPrimaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Obx(() => ListTile(
              tileColor: theme.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Text('Theme', style: GoogleFonts.outfit(color: textPrimaryColor)),
              subtitle: Text(themeCtrl.isLight.value ? 'Light' : 'Dark', style: GoogleFonts.outfit(color: textSecondaryColor)),
              onTap: () {
                // Open dialog where user can explicitly choose theme
                Get.dialog(AlertDialog(
                  backgroundColor: theme.cardColor,
                  title: Text('Select Theme', style: GoogleFonts.outfit(color: textPrimaryColor)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() => RadioListTile<bool>(
                        value: true,
                        groupValue: themeCtrl.isLight.value,
                        onChanged: (v) {
                          if (v != null) {
                            themeCtrl.setTheme(true);
                            Get.back();
                          }
                        },
                        title: Text('Light', style: GoogleFonts.outfit(color: textPrimaryColor)),
                      )),
                      Obx(() => RadioListTile<bool>(
                        value: false,
                        groupValue: themeCtrl.isLight.value,
                        onChanged: (v) {
                          if (v != null) {
                            themeCtrl.setTheme(false);
                            Get.back();
                          }
                        },
                        title: Text('Dark', style: GoogleFonts.outfit(color: textPrimaryColor)),
                      )),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Close', style: GoogleFonts.outfit(color: textSecondaryColor)),
                    )
                  ],
                ));
              },
            )),
          ],
        ),
      ),
    );
  }
}

