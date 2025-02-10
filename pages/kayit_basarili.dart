import 'package:flutter/material.dart';
import 'dart:async'; // Zamanlayıcı için gerekli
import 'girisyap.dart';
import 'package:trackfly/styles.dart'; // Import the styles file

class KayitBasariliPage extends StatefulWidget {
  const KayitBasariliPage({super.key});

  @override
  _KayitBasariliPageState createState() => _KayitBasariliPageState();
}

class _KayitBasariliPageState extends State<KayitBasariliPage> {
  @override
  void initState() {
    super.initState();

    // 5 saniye sonra giriş sayfasına yönlendir
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GirisYap()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor, // Use AppStyles for color
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 120,
                color: AppStyles.activeSwitchColor, // Use AppStyles for color
              ),
              const SizedBox(height: 20),
              const Text(
                'Kayıt Başarılı!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.textColor, // Use AppStyles for color
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Hesabınız başarıyla oluşturuldu. Yönlendiriliyorsunuz...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppStyles.textColor, // Use AppStyles for color
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Giriş yap sayfasına manuel yönlendirme
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => GirisYap()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.buttonColor, // Use AppStyles for color
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  'Giriş Yap',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppStyles.textColorWhite, // Use AppStyles for color
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
