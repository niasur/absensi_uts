import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Tambahkan ini
import 'page/main_page.dart';
import 'utils/theme_provider.dart'; // Tambahkan ini

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDikZBw60LaLvSjdsCBZggS9Kg8fW4mHlQ',
      appId: '1:357515997392:android:b5a0c4c42782d2ca4f2ed5',
      messagingSenderId: '357515997392',
      projectId: 'absensi-5e6d0',
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        cardTheme: const CardTheme(surfaceTintColor: Colors.white),
        dialogTheme: const DialogTheme(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeProvider.themeMode, // Gunakan dark/light mode sesuai toggle
      home: const MainPage(),
    );
  }
}