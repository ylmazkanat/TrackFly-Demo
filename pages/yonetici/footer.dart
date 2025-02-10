import 'package:flutter/material.dart';
import 'package:trackfly/pages/yonetici/yonetici_anasayfa.dart';
import 'package:trackfly/pages/yonetici/yonetici_iletisim.dart';
import 'package:trackfly/pages/yonetici/yonetici_ayarlar.dart';
import 'package:trackfly/styles.dart';

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
          MaterialPageRoute(builder: (context) => const YoneticiAnasayfa()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const YoneticiIletisim()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const YoneticiAyarlar()),
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
          icon: Icon(Icons.list),
          label: 'İletişim',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Ayarlar',
        ),
      ],
      backgroundColor: AppStyles.primaryColor, // Arkaplan rengi turuncu
      selectedItemColor: AppStyles.secondaryColor, // Seçili öğe rengi beyaz
      unselectedItemColor: AppStyles.secondaryColor70, // Seçili olmayan öğe rengi beyazın tonu
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed, // Sabitlenmiş öğeler
    );
  }
}
