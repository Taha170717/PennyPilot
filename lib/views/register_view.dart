import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import 'home_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayController = TextEditingController();
  final AuthController _auth = Get.find<AuthController>();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.scaffoldBackgroundColor;
    final cardBg = theme.cardColor;
    final textPrimary = theme.textTheme.bodyLarge?.color;
    final textSecondary = theme.textTheme.bodyMedium?.color;
    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
             child: Card(
               color: cardBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Create account', style: GoogleFonts.outfit(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _displayController,
                        style: GoogleFonts.outfit(color: textPrimary),
                        decoration: InputDecoration(labelText: 'Full name', labelStyle: GoogleFonts.outfit(color: textSecondary)),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _usernameController,
                        style: GoogleFonts.outfit(color: textPrimary),
                        decoration: InputDecoration(labelText: 'Username', labelStyle: GoogleFonts.outfit(color: textSecondary)),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter username' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: GoogleFonts.outfit(color: textPrimary),
                        decoration: InputDecoration(labelText: 'Password', labelStyle: GoogleFonts.outfit(color: textSecondary)),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter password' : null,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary),
                          onPressed: _loading
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate()) return;
                                  setState(() => _loading = true);
                                  final ok = await _auth.register(
                                    username: _usernameController.text.trim(),
                                    password: _passwordController.text,
                                    displayName: _displayController.text.trim(),
                                  );
                                  setState(() => _loading = false);
                                  if (ok) {
                                     Get.offAll(() => const HomeView());
                                     Get.snackbar('Welcome', 'Account created', snackPosition: SnackPosition.TOP, backgroundColor: cardBg.withAlpha((0.9 * 255).round()), colorText: textPrimary);
                                  } else {
                                    Get.snackbar('Registration Failed', 'Username already taken', snackPosition: SnackPosition.TOP, backgroundColor: cardBg.withAlpha((0.9 * 255).round()), colorText: textPrimary);
                                  }
                                },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            child: _loading ? const CircularProgressIndicator() : Text('Create account', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text('Back to login', style: GoogleFonts.outfit(color: textSecondary)),
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

