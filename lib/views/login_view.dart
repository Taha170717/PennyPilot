import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../theme.dart';
import 'register_view.dart';
import 'home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _auth = Get.find<AuthController>();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              color: AppColors.cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Welcome back', style: GoogleFonts.outfit(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('Sign in to continue', style: GoogleFonts.outfit(color: AppColors.textMuted)),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _usernameController,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                        decoration: InputDecoration(labelText: 'Username', labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary)),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter username' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: GoogleFonts.outfit(color: AppColors.textPrimary),
                        decoration: InputDecoration(labelText: 'Password', labelStyle: GoogleFonts.outfit(color: AppColors.textSecondary)),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          onPressed: _loading
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate()) return;
                                  setState(() => _loading = true);
                                  final ok = await _auth.login(username: _usernameController.text.trim(), password: _passwordController.text);
                                  setState(() => _loading = false);
                                  if (ok) {
                                    Get.offAll(() => const HomeView());
                                  } else {
                                    Get.snackbar('Login Failed', 'Invalid username or password', snackPosition: SnackPosition.TOP, backgroundColor: AppColors.cardBg.withAlpha((0.9 * 255).round()), colorText: AppColors.textPrimary);
                                  }
                                },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: _loading ? const CircularProgressIndicator() : Text('Sign in', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Get.to(() => const RegisterView());
                        },
                        child: Text('Create an account', style: GoogleFonts.outfit(color: AppColors.primary)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

