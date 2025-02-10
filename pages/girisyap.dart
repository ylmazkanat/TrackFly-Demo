import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackfly/db/db_helper.dart';
import 'package:trackfly/pages/genel/user_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'teldogrulama.dart';
import 'package:trackfly/styles.dart'; // Import the styles file
import 'kayit_hesap_turu_secimi.dart'; // Import the registration page
import 'sifremi_unuttum.dart'; // Import the forgot password page
import 'package:flutter/foundation.dart' show kIsWeb; // Import to check if the platform is web
import 'package:http/http.dart' as http; // Import http package for web service calls

class GirisYap extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  GirisYap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColorBlack, // Use AppStyles
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              const Text(
                "Track FLY",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Hoşgeldiniz",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Image.asset(
                'lib/images/girisyap.png',
                height: 150,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: usernameController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Kullanıcı adı",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: AppStyles.textColorWhite, // Use AppStyles
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Şifre",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: AppStyles.textColorWhite, // Use AppStyles
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String username = usernameController.text.trim();
                  String password = passwordController.text.trim();

                  if (username.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Kullanıcı adı ve şifre boş olamaz")),
                    );
                    return;
                  }

                  final userInfo = await login(username, password);

                  if (userInfo == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Kullanıcı adı veya şifre hatalı")),
                    );
                    return;
                  }

                  Provider.of<UserProvider>(context, listen: false)
                    ..setUsername(username)
                    ..setFullname(userInfo['fullname'])
                    ..setProfileImageUrl(userInfo['profileImageUrl']); // Set profile image URL

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TelefonDogrulama(
                        username: username,
                        userType: userInfo['userType'],
                      ),
                    ),
                  );
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
                  "Devam Et",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.textColorWhite, // Use AppStyles
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const KayitHesapTuruSecimi()),
                      );
                    },
                    child: const Text(
                      "Kayıt Ol",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SifremiUnuttum()),
                      );
                    },
                    child: const Text(
                      "Şifremi Unuttum",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Veritabanından kullanıcı bilgilerini alan login fonksiyonu
  Future<Map<String, dynamic>?> login(String username, String password) async {
    if (kIsWeb) {
      // Web-specific login logic using a web service
      return _webLogin(username);
    } else {
      // Non-web login logic
      try {
        final conn = await DatabaseHelper.connect();
        final result = await conn.query(
          '''
          SELECT user_type, full_name, password, profile_image 
          FROM users 
          WHERE username = ? 
          ORDER BY full_name DESC
          ''',
          [username],
        );
        await conn.close();

        if (result.isNotEmpty) {
          var dbPassword = result.first['password'];
          var bytes = utf8.encode(password);
          var digest = sha256.convert(bytes);

          if (digest.toString() == dbPassword) {
            return {
              'userType': int.tryParse(result.first['user_type'].toString()),
              'fullname': result.first['full_name'],
              'profileImageUrl': result.first['profile_image'], // Add profile image URL
            };
          } else {
            return null;
          }
        } else {
          return null;
        }
      } catch (e) {
        print('Login error: $e');
        return null;
      }
    }
  }

  Future<Map<String, dynamic>?> _webLogin(String username) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.yilmazkanat.com/login.php'), // Update with your server URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('error')) {
          return null;
        }
        return {
          'userType': int.parse(data['userType'].toString()), // Ensure userType is an int
          'fullname': data['fullname'],
          'profileImageUrl': data['profileImageUrl'],
        };
      } else {
        print('Login error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
}
