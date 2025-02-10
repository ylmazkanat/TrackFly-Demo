import 'package:flutter/material.dart';
import 'surucu/surucu_yolculuklar.dart';
import 'yonetici/yonetici_anasayfa.dart';
import 'kullanici/kullanici_yolculuklar.dart';

class GirisBasarili extends StatelessWidget {
  final String userType; // Kullanıcı tipi
  const GirisBasarili({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (userType == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const YoneticiAnasayfa()),
        );
      } else if (userType == "surucu") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SurucuYolculuklar()),
        );
      } else if (userType == "kullanici") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const KullaniciYolculuklar()),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Başarıyla Giriş Yaptınız.",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "Yönlendiriliyor...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
