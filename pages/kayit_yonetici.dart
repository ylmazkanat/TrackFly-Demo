import 'package:flutter/material.dart';
import 'package:trackfly/db/db_helper.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'kayit_basarili.dart';
import 'package:trackfly/styles.dart'; // Import the styles file
import 'girisyap.dart'; // Import the login page

class YoneticiKayit extends StatelessWidget {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  // final TextEditingController departmentController = TextEditingController(); // Remove department controller

  YoneticiKayit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.secondaryColor, // Use AppStyles for color
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppStyles.secondaryColor, // Use AppStyles for color
        title: const Text(
          "Yönetici Bilgilerinizi Girin",
          style: TextStyle(
            color: AppStyles.textColor, // Use AppStyles for color
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _buildHeaderButton("Yönetici"),
            const SizedBox(height: 20),
            _buildInputField(controller: fullNameController, hintText: "Ad Soyad", icon: Icons.person),
            const SizedBox(height: 15),
            _buildInputField(controller: usernameController, hintText: "Kullanıcı Adı", icon: Icons.account_circle),
            const SizedBox(height: 15),
            _buildInputField(controller: passwordController, hintText: "Şifre", obscureText: true, icon: Icons.lock),
            const SizedBox(height: 15),
            _buildInputField(controller: phoneController, hintText: "Telefon Numarası (+905555555555)", keyboardType: TextInputType.phone, icon: Icons.phone),
            const SizedBox(height: 20),
            _buildSaveButton(context),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GirisYap()),
              ),
              child: const Text("Giriş Yap", style: TextStyle(color: AppStyles.textColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton(String title) {
    return Center(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppStyles.buttonColor, // Use AppStyles for color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppStyles.textColorWhite), // Use AppStyles for color
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey), // Use AppStyles for color
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null, // Use AppStyles for color
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppStyles.borderColor), // Use AppStyles for color
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppStyles.buttonColor), // Use AppStyles for color
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        saveManager(context);
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
        "Kayıt Ol",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppStyles.textColorWhite), // Use AppStyles for color
      ),
    );
  }

  void saveManager(BuildContext context) async {
    final fullName = fullNameController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();
    // final department = departmentController.text.trim(); // Remove department field

    if (fullName.isEmpty || username.isEmpty || password.isEmpty || phone.isEmpty) {
      showAlert(context, "Hata", "Lütfen tüm alanları doldurun!");
      return;
    }

    try {
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      await registerManager(fullName, username, hashedPassword, phone);
      showAlert(context, "Başarılı", "Yönetici kaydı başarıyla tamamlandı!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const KayitBasariliPage()),
      );
    } catch (e) {
      showAlert(context, "Hata", "Kayıt sırasında bir hata oluştu: $e");
    }
  }

  void showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Tamam"),
            ),
          ],
        );
      },
    );
  }
}

Future<void> registerManager(String fullName, String username, String password, String phone) async {
  final conn = await DatabaseHelper.connect();
  await conn.query(
    'INSERT INTO users (full_name, username, password, phone, user_type) VALUES (?, ?, ?, ?, ?)',
    [fullName, username, password, phone, 2],
  );
  await conn.close();
}
