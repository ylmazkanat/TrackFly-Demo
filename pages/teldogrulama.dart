import 'package:flutter/material.dart';
import 'package:trackfly/styles.dart'; // Import the styles file
import 'yonetici/yonetici_anasayfa.dart';
import 'surucu/surucu_yolculuklar.dart';
import 'kullanici/kullanici_yolculuklar.dart';

class TelefonDogrulama extends StatelessWidget {
  final String username;
  final int userType;

  TelefonDogrulama({super.key, required this.username, required this.userType});

  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.secondaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppStyles.secondaryColor,
        automaticallyImplyLeading: false,
        title: const Text(
          "Güvenlik Kodu",
          style: TextStyle(
            color: AppStyles.textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Güvenlik Kodunu Giriniz",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppStyles.textColor,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 50,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 3) {
                        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                String pinCode = _controllers.map((controller) => controller.text).join();
                if (pinCode == "1234") {
                  if (userType == 2) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const YoneticiAnasayfa(),
                      ),
                    );
                  } else if (userType == 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SurucuYolculuklar(),
                      ),
                    );
                  } else if (userType == 0) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KullaniciYolculuklar(),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Geçersiz Güvenlik Kodu")),
                  );
                }
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
                "Devam Et",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.textColorWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
