import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'header.dart';
import 'footer.dart';
import '../genel/user_provider.dart';
import '/db/db_helper.dart';
import 'package:trackfly/styles.dart'; // Import the styles file

class KullaniciHakkimda extends StatefulWidget {
  const KullaniciHakkimda({super.key});

  @override
  _KullaniciHakkimdaState createState() => _KullaniciHakkimdaState();
}

class _KullaniciHakkimdaState extends State<KullaniciHakkimda> {
  int _selectedIndex = 3; // Ayarlar sekmesi aktif olarak ayarlandı.
  Map<String, dynamic> userProfile = {}; // Kullanıcı bilgilerini saklamak için
  bool isLoading = true; // Veri yüklenme durumu
  bool isEditing = false; // Düzenleme durumu
  final TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Kullanıcı bilgilerini veritabanından çek
  }

  Future<void> _fetchUserProfile() async {
    try {
      final username = Provider.of<UserProvider>(context, listen: false).username;

      // Veritabanından kullanıcı bilgilerini çek
      final conn = await DatabaseHelper.connect();
      final result = await conn.query(
        '''
        SELECT 
          full_name, 
          bio
        FROM users 
        WHERE username = ?
        ''',
        [username],
      );
      await conn.close();

      if (result.isNotEmpty) {
        setState(() {
          userProfile = {
            'full_name': result.first['full_name'] ?? 'Bilinmiyor',
            'bio': result.first['bio'] ?? 'Hakkında bilgi yok.',
          };
          bioController.text = userProfile['bio']; // Düzenleme kutusuna varsayılan değer
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false; // Veri bulunamadıysa yüklenmeyi durdur
        });
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateBio(String newBio) async {
    try {
      final username = Provider.of<UserProvider>(context, listen: false).username;

      // Veritabanında kullanıcı biyografisini güncelle
      final conn = await DatabaseHelper.connect();
      await conn.query(
        'UPDATE users SET bio = ? WHERE username = ?',
        [newBio, username],
      );
      await conn.close();

      setState(() {
        userProfile['bio'] = newBio; // Yeni biyografiyi güncelle
        isEditing = false; // Düzenleme modunu kapat
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Biyografi başarıyla güncellendi!")),
      );
    } catch (e) {
      print('Error updating bio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Biyografi güncellenirken bir hata oluştu!")),
      );
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
    final fullname = userProfile['full_name'] ?? 'Bilinmiyor';

    return Scaffold(
      appBar: Header(
        title: fullname,
        onBackPressed: () {
          Navigator.pop(context); // Geri dönüş işlevi
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Veri yükleniyor
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hakkımda Başlığı
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Hakkımda",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppStyles.textColor, // Use AppStyles for color
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Hakkımda Kartı
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profil Resmi ve Ad Soyad
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage('lib/images/profil.png'),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              fullname,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Açıklama veya Düzenleme Alanı
                        isEditing
                            ? TextField(
                                controller: bioController,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  hintText: "Biyografinizi buraya yazın...",
                                ),
                              )
                            : Text(
                                userProfile['bio'] ?? 'Hakkında bilgi yok.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                        const SizedBox(height: 10),
                        // Düzenle veya Kaydet Butonu
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: isEditing
                                ? () {
                                    _updateBio(bioController.text); // Güncelleme işlemi
                                  }
                                : () {
                                    setState(() {
                                      isEditing = true; // Düzenleme moduna geç
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEditing ? AppStyles.buttonColor : AppStyles.buttonColor,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Küçük boyut
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              isEditing ? "Kaydet" : "Düzenle",
                              style: const TextStyle(
                                fontSize: 14, // Küçük yazı boyutu
                                color: Colors.white, // Yazı rengi beyaz
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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
