import 'package:flutter/material.dart';
import 'header.dart';
import 'footer.dart';
import 'package:trackfly/db/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:trackfly/styles.dart'; // Import the styles file

class KullaniciBildirimler extends StatefulWidget {
  const KullaniciBildirimler({super.key});

  @override
  _KullaniciBildirimlerState createState() => _KullaniciBildirimlerState();
}

class _KullaniciBildirimlerState extends State<KullaniciBildirimler> {
  final int _selectedIndex = 1; // Bildirimler sekmesi aktif.
  List<dynamic> _notifications = [];
  bool isLoading = true; // Veri yüklenme durumu.

  @override
  void initState() {
    super.initState();
    _fetchNotifications(); // Bildirimleri veritabanından çek.
  }

  Future<void> _fetchNotifications() async {
    try {
      final conn = await DatabaseHelper.connect();
      final result = await conn.query('SELECT * FROM notifications WHERE user_type = ?', ['0']);
      await conn.close();

      setState(() {
        _notifications = result.map((row) {
          return {
            'id': row['id'],
            'related_info': row['related_info']?.toString() ?? '', // Convert to String
            'description': row['description']?.toString() ?? '',   // Convert to String
            'change_date': row['change_date'].toString(),
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching notifications: $e');
      setState(() {
        isLoading = false;
      });
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bildirimler Başlığı
                  const Text(
                    "Bildirimlerin",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppStyles.textColor, // Use AppStyles for color
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Bildirim Kartları
                  Expanded(
                    child: _notifications.isEmpty
                        ? const Center(
                            child: Text(
                              "Bildirim bulunamadı",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppStyles.textColorGrey, // Use AppStyles for color
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              return _buildNotificationCard(
                                notification['related_info'], // Başlık
                                notification['description'],
                                formatDateTime(notification['change_date']),
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

  // Bildirim Kartı Yapıcı Fonksiyonu
  Widget _buildNotificationCard(String relatedInfo, String message, String time) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStyles.secondaryColor, // Use AppStyles for color
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppStyles.borderColor), // Use AppStyles for color
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
            children: [
              const Icon(Icons.notifications, color: AppStyles.buttonColor), // Use AppStyles for color
              const SizedBox(width: 8),
              Text(
                relatedInfo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.textColor, // Use AppStyles for color
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppStyles.textColor, // Use AppStyles for color
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: AppStyles.textColorGrey, // Use AppStyles for color
            ),
          ),
        ],
      ),
    );
  }

  String formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString);
      final formattedDate = DateFormat('dd.MM.yyyy').format(dateTime);
      final formattedTime = DateFormat('HH.mm').format(dateTime);
      return '$formattedTime - $formattedDate';
    } catch (e) {
      return 'Geçersiz tarih formatı';
    }
  }
}
