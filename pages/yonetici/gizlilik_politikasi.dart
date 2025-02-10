import 'package:flutter/material.dart';
import 'header.dart';
import 'footer.dart';

class GizlilikPolitikasi extends StatefulWidget {
  const GizlilikPolitikasi({super.key});

  @override
  _GizlilikPolitikasiState createState() => _GizlilikPolitikasiState();
}

class _GizlilikPolitikasiState extends State<GizlilikPolitikasi> {
  int _selectedIndex = 2; // Ayarlar sekmesi seçili.

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
            const Text(
              "Gizlilik Politikası",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Text(
                    "Track Fly olarak kullanıcılarımızın gizliliğine önem veriyoruz. "
  "Bu gizlilik politikası, uygulamamızı kullanırken toplanan verilerin işlendiğini, "
  "korunduğunu ve paylaşıldığını açıklamaktadır. Uygulamamızı kullanarak bu politikayı kabul etmiş olursunuz.\n\n"
  "Uygulamamız, kullanıcı deneyimini iyileştirmek ve hizmetlerimizi sunmak amacıyla çeşitli türlerde veri toplayabilir.\n\n"
  "Kullanıcı bilgilerinizin güvenliği bizim için önemlidir. Verilerinizin yetkisiz erişim, değiştirme veya ifşa edilmesini önlemek için uygun teknik ve organizasyonel önlemler alınır.\n\n"
  "Uygulamamız, üçüncü taraf web sitelerine veya hizmetlere bağlantılar içerebilir. Bu hizmetlerin gizlilik uygulamalarından sorumlu değiliz ve kullanıcıların ilgili politikaları incelemesini öneririz.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      height: 1.5,
                    ),
                  ),
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
