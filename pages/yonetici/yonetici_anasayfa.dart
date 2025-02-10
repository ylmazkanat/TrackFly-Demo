import 'package:flutter/material.dart';
import 'header.dart';
import 'footer.dart';
import 'yonetici_surucu_konumu.dart';  // DriverLocationsPage sayfasını ekle
import 'package:trackfly/styles.dart'; // Import the styles file

class YoneticiAnasayfa extends StatefulWidget {
  const YoneticiAnasayfa({super.key});

  @override
  _YoneticiAnasayfaState createState() => _YoneticiAnasayfaState();
}

class _YoneticiAnasayfaState extends State<YoneticiAnasayfa> {
  int _selectedIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
            // Sürücüleri Gör Butonu
            GestureDetector(
              onTap: () {
                // DriverLocationsPage sayfasına yönlendirme
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DriverLocationsPage(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: AppStyles.buttonColor, // Use AppStyles
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Sürücüleri Gör",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: AppStyles.iconColorWhite), // Use AppStyles
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Başlık
            const Text(
              "Mali Raporlar ve Müşteri Şikayetleri",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppStyles.textColor, // Use AppStyles
              ),
            ),
            const SizedBox(height: 10),
            // Bilgilendirme Kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppStyles.secondaryColor, // Use AppStyles
                border: Border.all(color: AppStyles.buttonColor), // Use AppStyles
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: AppStyles.shadowColorOpacity, // Use AppStyles
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.fiber_manual_record, size: 10, color: AppStyles.iconColorOrange), // Use AppStyles
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Müşteri Şikayetleri, uygulamamızı kullanan şirketlerin sürücü bilgileri sayfasında belirtilen mail adresinize düşmektedir.",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.fiber_manual_record, size: 10, color: AppStyles.iconColorOrange), // Use AppStyles
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Mali raporlarınız ise araçta ödemede kullanılan tek tip pos cihazı tarafından kontrol edilmekte olup ilgili muhasebe uzmanınız tarafından raporlaştırılacaktır.",
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "Bilginize 🥳🥳",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppStyles.backgroundColor, // Set background color to white
      bottomNavigationBar: Footer(
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
