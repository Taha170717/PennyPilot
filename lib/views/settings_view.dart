import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../theme.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        title: Text('Settings', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account', style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Obx(() {
              final user = auth.currentUser;
              if (user == null) return Text('Not signed in', style: GoogleFonts.outfit(color: AppColors.textSecondary));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Username: ${user.username}', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text('Display name: ${user.displayName}', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
                ],
              );
            }),
            const SizedBox(height: 20),
            Text('App', style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              tileColor: AppColors.cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              title: Text('Theme', style: GoogleFonts.outfit(color: AppColors.textPrimary)),
              subtitle: Text('Dark (default)', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

