import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/genel/user_provider.dart'; // UserProvider sınıfını ekliyoruz
import 'pages/welcome_1.dart'; // İlk ekran
import 'package:firebase_core/firebase_core.dart';
import 'package:trackfly/firebase_options.dart'; // Stil dosyasını ekliyoruz
import 'dart:io' show Platform; // Import dart:io to check the platform
import 'package:flutter/foundation.dart' show kIsWeb; // Import to check if the platform is web
import 'package:window_size/window_size.dart' as window_size;
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import flutter_screenutil
import 'widgets/phone_container.dart'; // Import the PhoneContainer widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    _setWindowSize();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()), // Global UserProvider tanımlaması
      ],
      child: const MyApp(),
    ),
  );
}

void _setWindowSize() {
  window_size.setWindowTitle('TrackFly');
  window_size.setWindowMinSize(const Size(500, 888)); // Minimum boyut
  window_size.setWindowMaxSize(const Size(500, 888)); // Maksimum boyut
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Design size for responsive design
      builder: (context, child) {
        return PhoneContainer(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'TrackFly',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              scaffoldBackgroundColor: Colors.white, // Set background color to white
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Tüm buton yazılarını beyaz yapar
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white, // TextButton yazılarını beyaz yapar
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white, // OutlinedButton yazılarını beyaz yapar
                ),
              ),
            ),
            home: const Welcome1(), // İlk açılış ekranı
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrackFly Home Page'),
      ),
      body: const Center(
        child: Text('Welcome to TrackFly!'),
      ),
    );
  }
}
