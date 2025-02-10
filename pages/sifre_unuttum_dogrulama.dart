import 'package:flutter/material.dart';
import 'package:trackfly/styles.dart';
import 'package:trackfly/db/db_helper.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'girisyap.dart'; // Import the login page

class SifreUnuttumDogrulama extends StatelessWidget {
  final String email;
  final String verificationCode;
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  SifreUnuttumDogrulama({super.key, required this.email, required this.verificationCode});

  Future<void> _verifyCodeAndResetPassword(BuildContext context) async {
    final code = codeController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty || newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Yeni şifre alanları boş veya eşleşmiyor")),
      );
      return;
    }

    try {
      final conn = await DatabaseHelper.connect();
      final result = await conn.query(
        'SELECT * FROM sifre_sifirlama WHERE email = ? AND verification_code = ?',
        [email, code],
      );

      if (result.isNotEmpty) {
        final hashedPassword = sha256.convert(utf8.encode(newPassword)).toString();
        await conn.query('UPDATE users SET password = ? WHERE email = ?', [hashedPassword, email]);
        await conn.query('DELETE FROM sifre_sifirlama WHERE email = ?', [email]);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Şifre başarıyla değiştirildi!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GirisYap()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Geçersiz doğrulama kodu")),
        );
      }
      await conn.close();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bir hata oluştu!")),
      );
    }
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
                "Doğrulama Kodu",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: codeController,
                decoration: InputDecoration(
                  hintText: "Doğrulama Kodu",
                  filled: true,
                  fillColor: AppStyles.textColorWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Yeni Şifre",
                  filled: true,
                  fillColor: AppStyles.textColorWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Yeni Şifreyi Tekrar Girin",
                  filled: true,
                  fillColor: AppStyles.textColorWhite,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _verifyCodeAndResetPassword(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.buttonColor, // Use AppStyles
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Doğrula ve Şifreyi Değiştir",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.textColorWhite, // Use AppStyles
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => GirisYap()),
                ),
                child: const Text("Giriş Yap", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              Text(
                "Doğrulama kodu: $verificationCode",
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
