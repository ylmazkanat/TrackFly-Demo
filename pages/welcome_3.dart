import 'package:flutter/material.dart';
import 'welcome_giris.dart'; // WelcomeGiris sayfasını dahil ettik
import 'package:trackfly/styles.dart'; // Import the styles file

class Welcome3 extends StatelessWidget {
  const Welcome3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColorBlack, // Use AppStyles
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Image.asset(
                      'lib/images/welcome_3.png', // Replace with your actual image
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Kolay İletişim ile Hızlı\nKoordinasyon',
                      style: TextStyle(
                        color: AppStyles.textColorWhite, // Use AppStyles
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Şoför ve karşılamacıya tek dokunuşla ulaşın,\nvalizinize uygun araba seçin kolayca plan yapın.',
                      style: TextStyle(
                        color: AppStyles.textColorWhite, // Grey text color
                        fontSize: 16,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: Color(0xFF808080),
                        ),
                        SizedBox(width: 8),
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: Color(0xFF808080),
                        ),
                        SizedBox(width: 8),
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: AppStyles.textColorWhite, // Use AppStyles
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WelcomeGiris()), // WelcomeGiris sayfasına yönlendiriyor
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.buttonColor, // Use AppStyles
                        foregroundColor: Colors.white, // White text color
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Devam Et',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
