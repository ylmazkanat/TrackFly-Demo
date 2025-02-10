import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'header.dart';
import 'footer.dart';
import '../genel/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:trackfly/db/db_helper.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trackfly/styles.dart'; // Import the styles file

class YoneticiIletisim extends StatefulWidget {
  const YoneticiIletisim({super.key});

  @override
  _YoneticiIletisimState createState() => _YoneticiIletisimState();
}

class _YoneticiIletisimState extends State<YoneticiIletisim> {
  final int _selectedIndex = 1; // İletişim sayfası seçili olarak başlatılır.
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
      final result = await conn.query('SELECT * FROM notifications');
      await conn.close();

      setState(() {
        _notifications = result.map((row) {
          return {
            'id': row['id'],
            'related_info': row['related_info']?.toString() ?? '', // Convert to String
            'description': row['description']?.toString() ?? '',   // Convert to String
            'change_date': row['change_date'].toString(),
            'user_type': row['user_type'].toString(), // Add user_type
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
                backgroundColor: AppStyles.buttonColor, // Use AppStyles
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Gönder', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
        title: "X TURİZM ULAŞIM A.Ş",
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
                  // Mesajlar Başlığı
                  const Text(
                    "Mesajların",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Mesaj Kartı
                  GestureDetector(
                    onTap: () async {
                      const url = 'https://wa.me/+905465464364';
                      try {
                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("WhatsApp uygulaması açılamadı!")),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppStyles.secondaryColor, // Use AppStyles
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppStyles.borderColor), // Use AppStyles
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
                              Icon(Icons.message, size: 20, color: AppStyles.iconColor), // Use AppStyles
                              SizedBox(width: 8),
                              Text(
                                "Whatsapp’a Gitmek İçin Tıklayın.",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppStyles.textColor, // Use AppStyles
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Divider(color: Colors.grey),
                          SizedBox(height: 10),
                          Center(
                            child: Text(
                              "Sevgi ile Kalın 🥳🥳",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppStyles.textColor, // Use AppStyles
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Row to place the title and the button side by side
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Bildirimlerin",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppStyles.textColor, // Use AppStyles
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _showSendNotificationDialog,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(12),
                          backgroundColor: AppStyles.buttonColor, // Use AppStyles
                        ),
                        child: const Icon(Icons.add, color: AppStyles.iconColorWhite), // Use AppStyles
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
                                color: AppStyles.textColorGrey, // Use AppStyles
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
                                notification['user_type'], // Pass user_type
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

  Widget _buildNotificationCard(String relatedInfo, String description, String time, int id, String userType) {
    String userTypeText;
    switch (userType) {
      case '0':
        userTypeText = 'Kullanıcılar';
        break;
      case '1':
        userTypeText = 'Sürücüler';
        break;
      case '2':
        userTypeText = 'Yöneticiler';
        break;
      default:
        userTypeText = 'Bilinmiyor';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStyles.secondaryColor, // Use AppStyles
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppStyles.borderColor), // Use AppStyles
        boxShadow: const [
          BoxShadow(
            color: AppStyles.shadowColorOpacity, // Use AppStyles
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
              const Icon(Icons.notifications, color: AppStyles.iconColorOrange), // Use AppStyles
              const SizedBox(width: 8),
              Text(
                relatedInfo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
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
          const SizedBox(height: 4),
          Text(
            'Bildirim Grubu: $userTypeText',
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
