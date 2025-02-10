import 'package:flutter/material.dart';
import 'header.dart';
import 'footer.dart';
import '../genel/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:trackfly/db/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:trackfly/styles.dart'; // Import the styles file

class SurucuBildirimler extends StatefulWidget {
  const SurucuBildirimler({super.key});

  @override
  _SurucuBildirimlerState createState() => _SurucuBildirimlerState();
}

class _SurucuBildirimlerState extends State<SurucuBildirimler> {
  final int _selectedIndex = 1; // Bildirimler sekmesi aktif.
  List<dynamic> _notifications = [];
  bool isLoading = true; // Veri yüklenme durumu.
  String userType = '0'; // Varsayılan olarak kullanıcı

  @override
  void initState() {
    super.initState();
    _fetchNotifications(); // Bildirimleri veritabanından çek.
  }

  Future<void> _fetchNotifications() async {
    try {
      final conn = await DatabaseHelper.connect();
      final result = await conn.query('SELECT * FROM notifications WHERE user_type = ?', ['1']);
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

  void _sendNotification(String description, String relatedInfo) async {
    try {
      final username = Provider.of<UserProvider>(context, listen: false).username;
      final conn = await DatabaseHelper.connect();

      // Null kontrolü yaparak veritabanına gönderim
      await conn.query(
        '''
        INSERT INTO notifications (description, user_type, user_username, related_info) 
        VALUES (?, ?, ?, ?)
        ''',
        [
          description.isEmpty ? null : description, // Eğer boşsa null gönder
          userType,
          username,
          relatedInfo.isEmpty ? null : relatedInfo, // Eğer boşsa null gönder
        ],
      );
      await conn.close();
      _fetchNotifications(); // Bildirimleri güncelle
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bildirim başarıyla gönderildi!")),
      );
    } catch (e) {
      print('Error sending notification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bildirim gönderilirken bir hata oluştu!")),
      );
    }
  }

  void _showSendNotificationDialog() {
    String description = '';
    String relatedInfo = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yeni Bildirim Gönder', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8, // Set width to 80% of the screen
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      relatedInfo = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Başlık',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Padding for better appearance
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (value) {
                      description = value;
                    },
                    maxLines: 4, // TextField will expand to 4 lines
                    decoration: const InputDecoration(
                      labelText: 'Açıklama',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Padding for better appearance
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: userType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Kullanıcı Tipi',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Padding for better appearance
                    ),
                    items: const [
                      DropdownMenuItem(value: '0', child: Text('Kullanıcı')),
                      DropdownMenuItem(value: '1', child: Text('Sürücü')),
                      DropdownMenuItem(value: '2', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        userType = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _sendNotification(description, relatedInfo);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: AppStyles.buttonColor, // Button color
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Gönder', style: TextStyle(fontWeight: FontWeight.bold, color: AppStyles.textColorWhite)),
            ),
          ],
        );
      },
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
                  // Row to place the title and the button side by side
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Bildirimlerin",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppStyles.textColor,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _showSendNotificationDialog,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                        ),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _notifications.isEmpty
                      ? const Column(
                          children: [
                            Text(
                              "Bildirim bulunamadı",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              return _buildNotificationCard(
                                notification['related_info'], // Başlık
                                notification['description'],
                                formatDateTime(notification['change_date']),
                                notification['id'],
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

  Widget _buildNotificationCard(String relatedInfo, String message, String time, int id) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStyles.secondaryColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications, color: AppStyles.iconColorOrange),
              const SizedBox(width: 8),
              Text(
                relatedInfo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppStyles.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
