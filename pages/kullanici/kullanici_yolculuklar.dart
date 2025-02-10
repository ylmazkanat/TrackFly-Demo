import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http; // HTTP isteği için ekledik
import 'header.dart';
import 'footer.dart';
import '../genel/user_provider.dart';
import 'kullanici_yololustur.dart';
import 'kullanici_yolculuk_detay.dart'; // Detay sayfası için import
import 'package:trackfly/db/db_helper.dart';
import 'package:trackfly/styles.dart'; // Import the styles file

class KullaniciYolculuklar extends StatefulWidget {
  const KullaniciYolculuklar({super.key});

  @override
  _KullaniciYolculuklarState createState() => _KullaniciYolculuklarState();
}

class _KullaniciYolculuklarState extends State<KullaniciYolculuklar> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _journeys = [];

  @override
  void initState() {
    super.initState();
    _fetchJourneys();
  }

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

  Future<void> _fetchJourneys() async {
    try {
      final username = Provider.of<UserProvider>(context, listen: false).username;
      final conn = await DatabaseHelper.connect();
      print("Bağlantı sağlandı. Kullanıcı adı: $username");

      final results = await conn.query(
        'SELECT id, yolcu_username, pnr, driver_username, route_start_location, route_end_location, route_end_taksi, route_end_taksi_yazili, estimated_duration, actual_start_time, actual_end_time, status FROM journeys WHERE yolcu_username = ?',
        [username],
      );

      print("Sorgu sonuçları: ${results.length} adet kayıt bulundu.");
      setState(() {
        _journeys = results.map((row) => row.fields).toList();
      });

      await conn.close();
    } catch (e) {
      print("Hata: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Yolculuklar alınırken bir hata oluştu: $e")),
      );
    }
  }

  // Helper function to format the time as "HH:mm"
  String _formatTime(dynamic time) {
    try {
      if (time is String) {
        final parts = time.split(':');
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      } else if (time is Duration) {
        final hours = time.inHours;
        final minutes = time.inMinutes.remainder(60);
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      } else {
        return time.toString();
      }
    } catch (_) {
      return 'Belirtilmemiş';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _calculateRemainingTime(DateTime actualEndTime, String status) {
    final currentTime = DateTime.now().toUtc().add(const Duration(hours: 3));
    final difference = actualEndTime.difference(currentTime);

    if (status == "İndi") {
      return 'İndi';
    } else if (difference.isNegative) {
      return '0 saat 0 dakika kaldı';
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      return '$hours saat $minutes dakika kaldı';
    }
  }

  // PHP script'ini çalıştıran fonksiyon
  Future<void> _triggerPhpCode() async {
    final url = Uri.parse('https://api.yilmazkanat.com/update_journeys.php'); // PHP script'in URL'si
    try {
      final response = await http.get(url); // GET isteği gönder
      if (response.statusCode == 200) {
        print("PHP kodu başarılı bir şekilde çalıştırıldı!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Yolculuklar başarıyla güncellendi!")),
        );
        _fetchJourneys();
      } else {
        print("Hata: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Güncelleme sırasında bir hata oluştu: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Bir hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Güncelleme sırasında bir hata oluştu: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullname = Provider.of<UserProvider>(context).fullname;

    return Scaffold(
      appBar: Header(
        title: fullname,
        onBackPressed: () {
          Navigator.pop(context); // Geri dönüş işlevi
        },
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Yolculuklar Başlığı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Yolculuklarım",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.textColor, // Use AppStyles for color
                  ),
                ),
                // Güncelle Butonu
                ElevatedButton(
                  onPressed: () {
                    _triggerPhpCode(); // PHP kodunu çalıştıran fonksiyonu çağır
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.buttonColor, // Use AppStyles for color
                  ),
                  child: const Text("Güncelle"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Yolculuk Bilgileri
            Expanded(
              child: _journeys.isEmpty
                  ? const Center(
                      child: Text(
                        "Henüz yolculuğunuz bulunmamaktadır.",
                        style: TextStyle(fontSize: 14, color: AppStyles.textColor), // Use AppStyles for color
                      ),
                    )
                  : ListView.builder(
                      itemCount: _journeys.length,
                      itemBuilder: (context, index) {
                        final journey = _journeys[index];
                        DateTime actualEndTime;
                        DateTime actualStartTime;
                        try {
  actualEndTime = DateTime.parse(journey['actual_end_time']).toLocal();
} catch (_) {
  print("Tarih hatalı: ${journey['actual_end_time']}");
  actualEndTime = journey['actual_end_time']; // Hatalı durumda orijinal değer atanıyor
}

try {
  actualStartTime = DateTime.parse(journey['actual_start_time']).toLocal();
} catch (_) {
  print("Tarih hatalı: ${journey['actual_start_time']}");
  actualStartTime = journey['actual_start_time']; // Hatalı durumda orijinal değer atanıyor
}
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => KullaniciYolculukDetay(
                                  journey: journey,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppStyles.secondaryColor, // Use AppStyles for color
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppStyles.shadowColorOpacity, // Use AppStyles for color
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        journey['route_end_location'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppStyles.textColor, // Use AppStyles for color
                                        ),
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                    Text(
                                      "PNR: ${journey['pnr']}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  journey['route_end_taksi_yazili'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppStyles.textColor, // Use AppStyles for color
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      "İniş Saati (Tahmini): ${_formatTime(journey['estimated_duration'])}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "Durum: ${journey['status']}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.timer, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Kalan Süre: ${_calculateRemainingTime(actualEndTime, journey['status'])}",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // Yolculuk Planla Butonu
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const KullaniciYolculukOlusturma()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.buttonColor, // Use AppStyles for color
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "Yolculuğunu Planla 🥳",
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppStyles.textColorWhite), // Use AppStyles for color
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Footer(
        selectedIndex: _selectedIndex,
        
      ),
    );
  }
}
