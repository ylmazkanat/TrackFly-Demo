import 'package:flutter/material.dart';
import 'welcome_3.dart'; // Welcome3 sayfasını dahil ettik
import 'welcome_giris.dart';
import 'package:trackfly/styles.dart'; // Import the styles file

class Welcome2 extends StatelessWidget {
  const Welcome2({super.key});

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
                      'lib/images/welcome_2.png', // Replace with your actual image
                      height: 200,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Bekleme Sürelerini Azaltın',
                      style: TextStyle(
                        color: AppStyles.textColorWhite, // Use AppStyles
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Entegre uçuş bilgileriyle havalimanında \ngereksiz beklemeden kurtulun.',
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
                          backgroundColor: Color(0xFF808080),
                        ),
                        SizedBox(width: 8),
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: Colors.white,
                        ),
                        SizedBox(width: 8),
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: Color(0xFF808080),
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
                          MaterialPageRoute(builder: (context) => const Welcome3()), // Welcome3'e yönlendiriyor
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
