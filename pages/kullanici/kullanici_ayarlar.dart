import 'package:flutter/material.dart';
import 'package:trackfly/pages/girisyap.dart';
import '../genel/genel_gizlilik_politikasi.dart';
import 'header.dart';
import 'footer.dart';
import 'sifre_degistir.dart'; // Şifre değiştir sayfasını içeren dosya
import 'kullanici_hakkimda.dart';

class KullaniciAyarlar extends StatefulWidget {
  const KullaniciAyarlar({super.key});

  @override
  _KullaniciAyarlarState createState() => _KullaniciAyarlarState();
}

class _KullaniciAyarlarState extends State<KullaniciAyarlar> {
  int _selectedIndex = 3; // Ayarlar sekmesi aktif olarak ayarlandı.

  void _onTabTapped(int index) {
    if (index != _selectedIndex) {
      setState(() => _selectedIndex = index);
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/anasayfa');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/bildirimler');
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
      appBar: Header(
        title: "Mustafa AKIN",
        onBackPressed: () {
          Navigator.pop(context); // Geri dönüş işlevi
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            _buildSettingItem("Hakkımda", Icons.info, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KullaniciHakkimda()),
              );
            }),
            _buildSettingItem("Gizlilik Politikası", Icons.description, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GenelGizlilikPolitikasi()),
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
        color: Colors.white,
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
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
