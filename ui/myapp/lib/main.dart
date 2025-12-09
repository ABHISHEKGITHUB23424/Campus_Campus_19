import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/api_client.dart';
import 'core/token_storage.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'timetable_page.dart';
import 'prof_shell.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize core services before running app
  await TokenStorage.initialize();
  await ApiClient.initialize();

  runApp(const ProviderScope(child: CampusConnectApp()));
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CampusConnect',
      theme: ThemeData.dark().copyWith(
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E1E1E),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1F1F1F),
    foregroundColor: Colors.white,
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(Color(0xFF2D2D2D)),
      foregroundColor: WidgetStatePropertyAll(Colors.white),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      ),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFF1E1E1E),
    border: OutlineInputBorder(),
    hintStyle: TextStyle(color: Colors.grey),
  ),
  expansionTileTheme: const ExpansionTileThemeData(
    collapsedBackgroundColor: Color(0xFF1E1E1E),
    backgroundColor: Color(0xFF1E1E1E),
    iconColor: Colors.white,
    collapsedIconColor: Colors.white,
    textColor: Colors.white,
    collapsedTextColor: Colors.white,
  ),
  listTileTheme: const ListTileThemeData(
    tileColor: Color(0xFF1E1E1E),
    textColor: Colors.white,
    iconColor: Colors.white,
  ),
),

      // Start at login page
      initialRoute: '/home',
      routes: {
       
        '/home': (context) => const HomePage(),
      },
    );
  }
}