import 'package:flutter/material.dart';
import 'welcome_2.dart'; // Welcome2 sayfasını dahil ettik
import 'welcome_giris.dart';
import 'package:trackfly/styles.dart'; // Import the styles file

class Welcome1 extends StatelessWidget {
  const Welcome1({super.key});

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
                      'lib/images/welcome_1.png', // Görselin doğru yolunu sağlayın
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Gerçek Zamanlı Takip ile\nHızlı Erişim',
                      style: TextStyle(
                        color: AppStyles.textColorWhite, // Use AppStyles
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Şoför ve aracınızın konumunu\nanlık olarak görün.',
                      style: TextStyle(
                        color: AppStyles.textColorWhite, // Use AppStyles
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
                          backgroundColor: AppStyles.textColorWhite, // Use AppStyles
                        ),
                        SizedBox(width: 8),
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: Color(0xFF808080), // Use AppStyles
                        ),
                        SizedBox(width: 8),
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: Color(0xFF808080), // Use AppStyles
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
                          MaterialPageRoute(builder: (context) => const Welcome2()), // Welcome2'ye yönlendiriyor
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.buttonColor, // Use AppStyles
                        foregroundColor: AppStyles.textColorWhite, // Use AppStyles
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
                  TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeGiris()),
    );
  },
  child: const Text(
    'Atla',
    style: TextStyle(
      fontSize: 16,
      color: AppStyles.textColorWhite, // Use AppStyles
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
