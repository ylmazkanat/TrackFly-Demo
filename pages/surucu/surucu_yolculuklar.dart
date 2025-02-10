import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'header.dart';
import 'footer.dart';
import '../genel/user_provider.dart';
import 'package:trackfly/styles.dart'; // Import the styles file
import 'package:trackfly/db/db_helper.dart';
import 'surucu_yolculuk_detay.dart'; // Import the detail page
import 'package:http/http.dart' as http; // HTTP isteği için ekledik

class SurucuYolculuklar extends StatefulWidget {
  const SurucuYolculuklar({super.key});

  @override
  _SurucuYolculuklarState createState() => _SurucuYolculuklarState();
}

class _SurucuYolculuklarState extends State<SurucuYolculuklar> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _journeys = [];

  @override
  void initState() {
    super.initState();
    _fetchJourneys();
  }

  Future<void> _fetchJourneys() async {
    try {
      final username = Provider.of<UserProvider>(context, listen: false).username;
      final conn = await DatabaseHelper.connect();
      print("Bağlantı sağlandı. Kullanıcı adı: $username");

      final results = await conn.query(
        'SELECT id, yolcu_username, pnr, driver_username, route_start_location, route_end_location, route_end_taksi, route_end_taksi_yazili, estimated_duration, actual_start_time, actual_end_time, status FROM journeys WHERE driver_username = ?',
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

  Future<void> _triggerPhpCode() async {
    final url = Uri.parse('https://api.yilmazkanat.com/update_journeys.php'); // PHP script'in URL'si
    try {
      final response = await http.get(url); // GET isteği gönder
      if (response.statusCode == 200) {
        print("PHP kodu başarılı bir şekilde çalıştırıldı!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Yolculuklar başarıyla güncellendi!")),
        );
        _fetchJourneys(); // Yolculukları tekrar çek
      } else {
        print("Hata: ${response.statusCode}");
      }
    } catch (e) {
      print("Bir hata oluştu: $e");
    }
  }

  Future<Map<String, dynamic>?> _getPassengerInfo(String username) async {
    try {
      final conn = await DatabaseHelper.connect();
      final results = await conn.query(
        "SELECT full_name, profile_image FROM users WHERE username = ?",
        [username],
      );
      if (results.isNotEmpty) {
        return results.first.fields;
      }
    } catch (e) {
      print('Veritabanı hatası: $e');
    }
    return null;
  }

  String _formatTime(dynamic time) {
    try {
      if (time is String) {
        final parts = time.split(':');
        return '${parts[0]}:${parts[1]}';
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

  void _showProfileImagePopup(String? profileImageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image(
              image: profileImageUrl != null
                  ? NetworkImage(profileImageUrl)
                  : const AssetImage('lib/images/profil.png') as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullname = Provider.of<UserProvider>(context).fullname;

    return Scaffold(
      appBar: Header(
        title: fullname,
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Yolcularım Başlığı ve Güncelle Butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Yolcularım",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
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
            Expanded(
              child: _journeys.isEmpty
                  ? const Center(
                      child: Text(
                        "Henüz yolculuğunuz bulunmamaktadır.",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _journeys.length,
                      itemBuilder: (context, index) {
                        final journey = _journeys[index];
                        DateTime actualEndTime;
                        try {
                          actualEndTime = DateTime.parse(journey['actual_end_time']).toLocal();
                        } catch (_) {
                          print("Tarih hatalı: ${journey['actual_end_time']}");
  actualEndTime = journey['actual_end_time']; // Hatalı durumda orijinal değer atanıyor
                        }
                        return FutureBuilder<Map<String, dynamic>?>(
                          future: _getPassengerInfo(journey['yolcu_username']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            final passengerInfo = snapshot.data;
                            final fullName = passengerInfo?['full_name'] ?? "Belirtilmemiş";
                            final profileImageUrl = passengerInfo?['profile_image'];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SurucuYolculukDetay(
                                      journey: journey,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(8),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => _showProfileImagePopup(profileImageUrl),
                                          child: CircleAvatar(
                                            radius: 25,
                                            backgroundImage: profileImageUrl != null
                                                ? NetworkImage(profileImageUrl)
                                                : const AssetImage('lib/images/profil.png') as ImageProvider,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                fullName,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppStyles.textColor,
                                                ),
                                              ),
                                              Text(
                                                "${journey['route_start_location']} - ${journey['route_end_taksi_yazili']}",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.person, color: AppStyles.iconColor),
                                      ],
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
                        );
                      },
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
