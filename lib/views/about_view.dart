import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = theme.cardColor;
    final bg = theme.scaffoldBackgroundColor;
    final textPrimary = theme.textTheme.bodyLarge?.color;
    final textSecondary = theme.textTheme.bodyMedium?.color;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cardBg,
        title: Text('About', style: GoogleFonts.outfit(color: textPrimary)),
      ),
      backgroundColor: bg,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('PennyPilot', style: GoogleFonts.outfit(color: textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Version 1.0.0', style: GoogleFonts.outfit(color: textSecondary)),
          const SizedBox(height: 16),
          Text('A simple offline-first personal finance tracker. Data is stored on device per-user and does not use Firebase or any cloud service by default.', style: GoogleFonts.outfit(color: textPrimary)),
        ]),
      ),
    );
  }
}

