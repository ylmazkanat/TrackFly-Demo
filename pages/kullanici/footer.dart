import 'package:flutter/material.dart';
import 'package:trackfly/pages/kullanici/kullanici_ayarlar.dart';
import 'package:trackfly/pages/kullanici/kullanici_bildirimler.dart';
import 'package:trackfly/pages/kullanici/kullanici_iletisim.dart';
import 'package:trackfly/pages/kullanici/kullanici_yolculuklar.dart';
import 'package:trackfly/styles.dart'; // Import the styles file

class Footer extends StatelessWidget {
  final int selectedIndex;

  const Footer({
    super.key,
    required this.selectedIndex,
  });

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const KullaniciYolculuklar()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const KullaniciBildirimler()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Kullaniciiletisim()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const KullaniciAyarlar()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) => _onTabTapped(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Anasayfa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Bildirimler',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Mesajlar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Ayarlar',
        ),
      ],
      backgroundColor: AppStyles.primaryColor, // Use primary color
      selectedItemColor: AppStyles.selectedItemColor, // Use selected item color
      unselectedItemColor: AppStyles.unselectedItemColor, // Use unselected item color
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed, // Sabitlenmiş öğeler
    );
  }
}
