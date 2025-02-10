import 'package:flutter/material.dart';
import 'package:trackfly/db/db_helper.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'kayit_basarili.dart';
import 'package:trackfly/styles.dart'; // Import the styles file
import 'girisyap.dart'; // Import the login page

class KullaniciKayit extends StatelessWidget {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController tcIdentityController = TextEditingController();
  final TextEditingController jobController = TextEditingController();

  KullaniciKayit({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.secondaryColor, // Use AppStyles
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppStyles.secondaryColor, // Use AppStyles
        title: const Text(
          "Kişisel Bilgilerinizi Girin",
          style: TextStyle(
            color: AppStyles.textColor, // Use AppStyles
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
            _buildHeaderButton("Kullanıcı"),
            const SizedBox(height: 20),
            _buildInputField(controller: fullNameController, hintText: "Ad Soyad", icon: Icons.person),
            const SizedBox(height: 15),
            _buildInputField(controller: usernameController, hintText: "Kullanıcı Adı", icon: Icons.account_circle),
            const SizedBox(height: 15),
            _buildInputField(controller: passwordController, hintText: "Şifre", obscureText: true, icon: Icons.lock),
            const SizedBox(height: 15),
            _buildInputField(controller: phoneController, hintText: "Telefon Numarası (+905555555555)", keyboardType: TextInputType.phone, icon: Icons.phone),
            const SizedBox(height: 15),
            _buildInputField(controller: emailController, hintText: "E-Mail", keyboardType: TextInputType.emailAddress, icon: Icons.email),
            const SizedBox(height: 15),
            _buildInputField(controller: addressController, hintText: "Adres", icon: Icons.home),
            const SizedBox(height: 15),
            _buildInputField(controller: tcIdentityController, hintText: "TC Kimlik No", icon: Icons.badge),
            const SizedBox(height: 15),
            _buildInputField(controller: jobController, hintText: "Meslek", icon: Icons.work),
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
          backgroundColor: AppStyles.buttonColor, // Use AppStyles
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppStyles.textColorWhite), // Use AppStyles
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
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppStyles.buttonColor), // Use AppStyles
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        saveUser(context);
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
        "Kayıt Ol",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppStyles.textColorWhite), // Use AppStyles
      ),
    );
  }

  void saveUser(BuildContext context) async {
    final fullName = fullNameController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final address = addressController.text.trim();
    final tcIdentity = tcIdentityController.text.trim();
    final job = jobController.text.trim();

    if (fullName.isEmpty || username.isEmpty || password.isEmpty || phone.isEmpty || email.isEmpty || address.isEmpty || tcIdentity.isEmpty || job.isEmpty) {
      showAlert(context, "Hata", "Lütfen tüm alanları doldurun!");
      return;
    }

    try {
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      await registerUser(fullName, username, hashedPassword, phone, email, address, tcIdentity, job);
      showAlert(context, "Başarılı", "Kullanıcı kaydı başarıyla tamamlandı!");
      // Kayıt başarılı olduğunda yönlendirme
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

Future<void> registerUser(String fullName, String username, String password, String phone, String email, String address, String tcIdentity, String job) async {
  final conn = await DatabaseHelper.connect();
  await conn.query(
    'INSERT INTO users (full_name, username, password, phone, email, address, tc_identity, job, user_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [fullName, username, password, phone, email, address, tcIdentity, job, 0],
  );
  await conn.close();
}
