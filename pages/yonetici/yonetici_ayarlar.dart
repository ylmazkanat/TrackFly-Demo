import 'package:flutter/material.dart';
import 'package:trackfly/pages/girisyap.dart';
import 'gizlilik_politikasi.dart';
import 'package:trackfly/pages/yonetici/sifreyi_degistir.dart';
import 'header.dart';
import 'footer.dart';
import 'package:trackfly/styles.dart'; // Import the styles file

class YoneticiAyarlar extends StatefulWidget {
  const YoneticiAyarlar({super.key});

  @override
  _YoneticiAyarlarState createState() => _YoneticiAyarlarState();
}

class _YoneticiAyarlarState extends State<YoneticiAyarlar> {
  int _selectedIndex = 2; // Ayarlar sayfası seçili olarak başlatılır.

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
            // Ayarlar Başlığı
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Ayarlar",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Ayarlar Kartları
            _buildSettingItem("Şifreyi Sıfırla", Icons.key, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SifreyiDegistir()),
              );
            }),
            _buildSettingItem("Gizlilik Politikası", Icons.description, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GizlilikPolitikasi()),
              );
            }),
            _buildSettingItem("Çıkış", Icons.exit_to_app, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GirisYap()),
              );
            }),
          ],
        ),
      ),
      bottomNavigationBar: Footer(
        selectedIndex: _selectedIndex,
      ),
    );
  }

  // Ayar Kartı Yapıcı Fonksiyonu
  Widget _buildSettingItem(String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppStyles.secondaryColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppStyles.iconColor),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppStyles.textColor,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
