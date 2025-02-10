import 'package:flutter/material.dart';
import 'package:trackfly/db/db_helper.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'kayit_basarili.dart';
import 'package:trackfly/styles.dart'; // Import the styles file
import 'girisyap.dart'; // Import the login page

class SurucuKayit extends StatelessWidget {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController taxiPlateController = TextEditingController();

  SurucuKayit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.secondaryColor, // Use AppStyles
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppStyles.secondaryColor, // Use AppStyles
        title: const Text(
          "Sürücü Bilgilerinizi Girin",
          style: TextStyle(color: AppStyles.textColor, fontSize: 24, fontWeight: FontWeight.bold), // Use AppStyles
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            _buildHeaderButton("Sürücü"),
            const SizedBox(height: 20),
            _buildInputField(controller: fullNameController, hintText: "Ad Soyad", icon: Icons.person),
            const SizedBox(height: 15),
            _buildInputField(controller: usernameController, hintText: "Kullanıcı Adı", icon: Icons.account_circle),
            const SizedBox(height: 15),
            _buildInputField(controller: passwordController, hintText: "Şifre", obscureText: true, icon: Icons.lock),
            const SizedBox(height: 15),
            _buildInputField(controller: phoneController, hintText: "Telefon Numarası (+905555555555)", icon: Icons.phone),
            const SizedBox(height: 15),
            _buildInputField(controller: taxiPlateController, hintText: "Taksi Plakası", icon: Icons.local_taxi),
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

  Widget _buildHeaderButton(String title) => ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppStyles.buttonColor, // Use AppStyles
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(title, style: const TextStyle(fontSize: 16, color: AppStyles.textColorWhite, fontWeight: FontWeight.bold)), // Use AppStyles
      );

  Widget _buildInputField({required TextEditingController controller, required String hintText, bool obscureText = false, IconData? icon}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => saveDriver(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppStyles.buttonColor, // Use AppStyles
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text("Kayıt Ol", style: TextStyle(color: AppStyles.textColorWhite, fontSize: 16, fontWeight: FontWeight.bold)), // Use AppStyles
    );
  }

  void saveDriver(BuildContext context) async {
    final fullName = fullNameController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();
    final taxiPlate = taxiPlateController.text.trim(); // Add taxi plate

    if (fullName.isEmpty || username.isEmpty || password.isEmpty || phone.isEmpty || taxiPlate.isEmpty) {
      showAlert(context, "Hata", "Lütfen tüm alanları doldurun!");
      return;
    }

    try {
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      await registerDriver(fullName, username, hashedPassword, phone, taxiPlate); // Pass taxi plate
      showAlert(context, "Başarılı", "Sürücü kaydı başarıyla tamamlandı!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const KayitBasariliPage()),
      );
    } catch (e) {
      showAlert(context, "Hata", "Kayıt sırasında hata oluştu: $e");
    }
  }

  Future<void> registerDriver(String fullName, String username, String password, String phone, String taxiPlate) async {
    final conn = await DatabaseHelper.connect();
    await conn.query(
      'INSERT INTO users (full_name, username, password, phone, user_type, taxi_plate) VALUES (?, ?, ?, ?, ?, ?)',
      [fullName, username, password, phone, 1, taxiPlate], // Include taxi plate
    );
    await conn.close();
  }

  void showAlert(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tamam"))],
      ),
    );
  }
}
