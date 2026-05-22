import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:job_app/app/app.dart';
import 'package:job_app/features/auth/screens/login_screen.dart';
import 'package:job_app/features/jobs/screens/candidate_home_screen.dart';
import 'package:job_app/core/storage/token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ← Pré-cacher les frames pendant l'init
  await Future.wait([
    initializeDateFormatting('fr_FR', null),
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  ]);

  bool hasToken = false;
  try {
    hasToken = await TokenStorage.hasSession();
  } catch (_) {
    // flutter_secure_storage Web Crypto can fail on first launch or HTTP —
    // treat as no session and show the login screen.
  }
  final Widget initialScreen =
      hasToken ? const CandidateHomeScreen() : const LoginScreen();

  runApp(
    ProviderScope(
      child: App(initialScreen: initialScreen),
    ),
  );
}
