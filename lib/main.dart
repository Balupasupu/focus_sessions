import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/quote_provider.dart';
import 'providers/session_history_provider.dart';
import 'providers/timer_provider.dart';
import 'screens/home_screen.dart';
import 'services/quote_service.dart';
import 'services/session_storage_service.dart';

Future<void> main() async {
  // Needed because we use a plugin (SharedPreferences) before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final historyProvider = SessionHistoryProvider(
    storage: SessionStorageService(prefs),
  );
  await historyProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        // .value because we created the provider ourselves above.
        ChangeNotifierProvider.value(value: historyProvider),
        // Starts loading the daily quote as soon as the app starts.
        ChangeNotifierProvider(
          create: (_) => QuoteProvider(ZenQuotesService())..fetchQuote(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focus Sessions',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}