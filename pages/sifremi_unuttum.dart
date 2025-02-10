import 'package:flutter/material.dart';
import 'package:trackfly/styles.dart'; // Import the styles file
import 'girisyap.dart'; // Import the login page
import 'package:trackfly/db/db_helper.dart'; // Import the database helper
import 'dart:math'; // Import dart:math for random number generation
import 'sifre_unuttum_dogrulama.dart'; // Import the verification page

class SifremiUnuttum extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  SifremiUnuttum({super.key});

  Future<void> _sendPasswordResetEmail(BuildContext context, String email) async {
    try {
      final conn = await DatabaseHelper.connect();
      final result = await conn.query(
        'SELECT username FROM users WHERE email = ?',
        [email],
      );

      if (result.isNotEmpty) {
        final username = result.first['username'];
        final verificationCode = _generateVerificationCode();
        await conn.query(
          'INSERT INTO sifre_sifirlama (email, verification_code) VALUES (?, ?)',
          [email, verificationCode],
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SifreUnuttumDogrulama(email: email, verificationCode: verificationCode),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("E-posta adresi sistemde bulunamadı!")),
        );
      }
      await conn.close();
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bir hata oluştu!")),
      );
    }
  }

  String _generateVerificationCode() {
    const length = 6;
    const chars = '0123456789';
    final random = Random();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColorBlack,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              const Text(
                "Şifremi Unuttum",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                "Lütfen e-posta adresinizi girin",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              const Icon(Icons.lock_reset, size: 150, color: Colors.white),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "E-posta adresi",
                  filled: true,
                  fillColor: AppStyles.textColorWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final email = emailController.text.trim();
                  if (email.isNotEmpty) {
                    _sendPasswordResetEmail(context, email);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("E-posta adresi boş olamaz")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.buttonColor, // Use AppStyles
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Şifreyi Sıfırla",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.textColorWhite, // Use AppStyles
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GirisYap())),
                child: const Text("Giriş Yap", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
