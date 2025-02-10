import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../genel/header.dart';
import '../genel/footer.dart';
import '../genel/user_provider.dart';
import '/db/db_helper.dart';
import 'package:trackfly/styles.dart'; // Import the styles file
import 'package:crypto/crypto.dart'; // Import crypto package
import 'dart:convert'; // Import dart:convert for utf8 encoding

class SifreyiDegistir extends StatefulWidget {
  const SifreyiDegistir({super.key});

  @override
  _SifreyiDegistirState createState() => _SifreyiDegistirState();
}

class _SifreyiDegistirState extends State<SifreyiDegistir> {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  int _selectedIndex = 3; // Ayarlar sekmesi seçili.

  Future<void> _changePassword(String username, String currentPassword, String newPassword) async {
    try {
      final conn = await DatabaseHelper.connect();

      // Mevcut şifreyi doğrula
      final result = await conn.query(
        'SELECT password FROM users WHERE username = ? AND password = ?',
        [username, sha256.convert(utf8.encode(currentPassword)).toString()],
      );

      if (result.isEmpty) {
        // Mevcut şifre yanlış
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mevcut şifre yanlış!")),
        );
        await conn.close();
        return;
      }

      // Yeni şifreyi hashle ve güncelle
      final hashedNewPassword = sha256.convert(utf8.encode(newPassword)).toString();
      await conn.query(
        'UPDATE users SET password = ? WHERE username = ?',
        [hashedNewPassword, username],
      );
      await conn.close();

      // Başarı mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifre başarıyla değiştirildi!")),
      );

      // Şifre değiştirme tamamlandıktan sonra alanları temizle
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } catch (e) {
      print('Error changing password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifre değiştirme sırasında bir hata oluştu!")),
      );
    }
  }

  void _onTabTapped(int index) {
    if (index != _selectedIndex) {
      setState(() => _selectedIndex = index);
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/anasayfa');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/iletisim');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/ayarlar');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<UserProvider>(context).username; // Kullanıcı adı alınıyor

    return Scaffold(
      appBar:  Header(
        title: "TrackFly",
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Şifreyi Sıfırla",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppStyles.textColor,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Mevcut Şifre",
                filled: true,
                fillColor: AppStyles.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Yeni Şifre",
                filled: true,
                fillColor: AppStyles.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Yeni Şifreyi Tekrar Girin",
                filled: true,
                fillColor: AppStyles.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String currentPassword = currentPasswordController.text.trim();
                String newPassword = newPasswordController.text.trim();
                String confirmPassword = confirmPasswordController.text.trim();

                if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Tüm alanları doldurun!")),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Yeni şifreler eşleşmiyor!")),
                  );
                  return;
                }

                // Şifre değiştirme işlemi
                _changePassword(username, currentPassword, newPassword);
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
                "Değiştir",
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
      bottomNavigationBar: Footer(
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
