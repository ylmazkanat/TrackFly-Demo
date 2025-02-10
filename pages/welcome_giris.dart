import 'package:flutter/material.dart';
import 'kayit_hesap_turu_secimi.dart'; 
import 'giris_hesap_turu_secimi.dart';
import 'package:trackfly/styles.dart'; // Import the styles file

class WelcomeGiris extends StatelessWidget {
  const WelcomeGiris({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColorBlack, // Dark background color
      body: Stack(
        children: [
          // Full-screen background image
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              'lib/images/welcome_giris.png', // Görselinizi buraya ekleyin
              fit: BoxFit.cover,
            ),
          ),
          // Content on top of the image
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(flex: 2),
              // Title text
              const Padding(
                padding: EdgeInsets.only(top: 300), // Görselin altına kaydırmak için üstten boşluk ekleyin
                child: Center(
                  child: Text(
                    'Track FLY',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: AppStyles.textColorWhite,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 1),
              // Buttons at the bottom
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GirisHesapTuru()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.buttonColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Giriş Yap',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppStyles.textColorWhite,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const KayitHesapTuruSecimi()), // Yönlendirme işlemi
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.buttonColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'Kayıt Ol',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppStyles.textColorWhite,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
