import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:job_app/app/app.dart';
import 'package:job_app/features/jobs/screens/jobs_list_screen.dart';
import 'package:job_app/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JobApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.violet),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'PlusJakartaSans',
      ),
      home: const JobsListScreen(), // ✅ démarre direct ici
    );
  }
}