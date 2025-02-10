import 'package:flutter/material.dart';
import 'girisyap.dart';
import 'package:trackfly/styles.dart'; // Import the styles file

class GirisHesapTuru extends StatelessWidget {
  const GirisHesapTuru({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColorBlack, // Dark background color
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'lib/images/kayit_hesap_turu.png', // Görselinizi buraya ekleyin
                  height: 200,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nasıl devam etmek istiyorsunuz?',
                  style: TextStyle(
                    color: AppStyles.textColorWhite, // Use AppStyles for color
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Sürücü, yolcu, karşılama Uzmanı, yönetici olarak giriş yapabilirsiniz, devam etmek için birini seçin',
                    style: TextStyle(
                      color: AppStyles.textColorWhite70, // Use AppStyles for color
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GirisYap()), // KullaniciKayit sayfasına yönlendirme
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.buttonColor, // Use AppStyles for color
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Kullanıcı Girişi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppStyles.textColorWhite, // Use AppStyles for color
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GirisYap()), // KullaniciKayit sayfasına yönlendirme
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.buttonColor, // Use AppStyles for color
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Sürücü Girişi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppStyles.textColorWhite, // Use AppStyles for color
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GirisYap()), // KullaniciKayit sayfasına yönlendirme
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.buttonColor, // Use AppStyles for color
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Yönetici Girişi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppStyles.textColorWhite, // Use AppStyles for color
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
