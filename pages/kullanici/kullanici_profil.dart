import 'dart:io'; // Bu satırı ekleyin
import 'package:flutter/material.dart';
import 'header.dart';
import 'footer.dart';
import '../genel/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:trackfly/db/db_helper.dart';
import 'package:trackfly/styles.dart'; // Import the styles file
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class KullaniciProfil extends StatefulWidget {
  const KullaniciProfil({super.key});

  @override
  _KullaniciProfilState createState() => _KullaniciProfilState();
}

class _KullaniciProfilState extends State<KullaniciProfil> {
  final int _selectedIndex = 3; // Profil sayfası Ayarlar sekmesi.
  Map<String, dynamic> userProfile = {}; // Kullanıcı bilgilerini tutmak için harita.
  bool isLoading = true; // Veri yüklenme durumu.
  bool isEditing = false; // Düzenleme modu.
  final Map<String, TextEditingController> controllers = {}; // Düzenleme için TextField kontrolleri.
  final Map<String, String> fieldTypes = {}; // Alan türleri.
  String? profileImageUrl; // Profil resmi URL'si.

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Kullanıcı bilgilerini veritabanından çek.
  }

  Future<void> _fetchUserProfile() async {
    try {
      final username = Provider.of<UserProvider>(context, listen: false).username;

      // Veritabanından kullanıcı bilgilerini çek.
      final conn = await DatabaseHelper.connect();
      final result = await conn.query(
        '''
        SELECT 
          full_name, 
          username, 
          phone, 
          email, 
          address, 
          tc_identity,
          age,
          job,
          profile_image
        FROM users 
        WHERE username = ?
        ''',
        [username],
      );
      await conn.close();

      if (result.isNotEmpty) {
        setState(() {
          userProfile = {
            'Ad Soyad': result.first['full_name'] ?? '',
            'Kullanıcı Adı': result.first['username'] ?? '',
            'Telefon': result.first['phone'] ?? '',
            'E-Mail': result.first['email'] ?? '',
            'Adres': result.first['address'] ?? '',
            'TC Kimlik No': result.first['tc_identity'] ?? '',
            'Yaş': result.first['age']?.toString() ?? '',
            'Meslek': result.first['job'] ?? '',
          };
          profileImageUrl = result.first['profile_image'];
          fieldTypes.addAll({
            'Ad Soyad': 'string',
            'Telefon': 'string',
            'E-Mail': 'string',
            'Adres': 'string',
            'TC Kimlik No': 'string',
            'Yaş': 'int',
            'Meslek': 'string',
          });
          _initializeControllers();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _initializeControllers() {
    userProfile.forEach((key, value) {
      if (key != 'Kullanıcı Adı') {
        controllers[key] = TextEditingController(text: value);
      }
    });
  }

  Future<void> _updateUserProfile() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final username = userProvider.username;

      final conn = await DatabaseHelper.connect();

      // Kullanıcı profilini güncelle.
      await conn.query(
        '''
        UPDATE users 
        SET 
          full_name = ?, 
          tc_identity = ?, 
          phone = ?, 
          email = ?, 
          address = ?, 
          age = ?, 
          job = ?, 
          profile_image = ? 
        WHERE username = ?
        ''',
        [
          _getNullableValue(controllers['Ad Soyad']?.text),
          _getNullableValue(controllers['TC Kimlik No']?.text),
          _getNullableValue(controllers['Telefon']?.text),
          _getNullableValue(controllers['E-Mail']?.text),
          _getNullableValue(controllers['Adres']?.text),
          _getNullableInt(controllers['Yaş']?.text),
          _getNullableValue(controllers['Meslek']?.text),
          profileImageUrl,
          username,
        ],
      );

      await conn.close();

      // Update the full name in UserProvider
      userProvider.setFullname(controllers['Ad Soyad']?.text ?? '');

      setState(() {
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil başarıyla güncellendi!")),
      );
    } catch (e) {
      print('Error updating user profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil güncellenirken bir hata oluştu!")),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final fileName = path.basename(pickedFile.path);
      final destination = 'profile_images/$fileName';

      try {
        final ref = FirebaseStorage.instance.refFromURL('gs://trackfly-52a81.firebasestorage.app').child(destination);

        // Attempt to delete the old profile image if it exists
        if (profileImageUrl != null) {
          try {
            final oldRef = FirebaseStorage.instance.refFromURL(profileImageUrl!);
            await oldRef.delete();
          } catch (e) {
            print('Error deleting old profile image: $e');
          }
        }

        await ref.putFile(File(pickedFile.path)); // Upload new profile image
        final downloadUrl = await ref.getDownloadURL();

        setState(() {
          profileImageUrl = downloadUrl;
        });

        // Update the profile image URL in UserProvider
        Provider.of<UserProvider>(context, listen: false).setProfileImageUrl(downloadUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil resmi başarıyla yüklendi!")),
        );
      } catch (e) {
        print('Error uploading profile image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil resmi yüklenirken bir hata oluştu!")),
        );
      }
    }
  }

  // Boş değerleri null olarak işleyen yardımcı fonksiyonlar.
  dynamic _getNullableValue(String? value) {
    return (value == null || value.isEmpty) ? null : value;
  }

  int? _getNullableInt(String? value) {
    return (value == null || value.isEmpty) ? null : int.tryParse(value);
  }

  @override
  Widget build(BuildContext context) {
    final fullname = Provider.of<UserProvider>(context).fullname;

    return Scaffold(
      appBar: Header(
        title: isEditing ? "Düzenle" : fullname,
        onBackPressed: () {
          if (isEditing) {
            setState(() {
              isEditing = false;
            });
          } else {
            Navigator.pop(context);
          }
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: isEditing ? _pickImage : null,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl!)
                          : const AssetImage('lib/images/profil.png') as ImageProvider,
                      child: isEditing
                          ? const Icon(Icons.camera_alt, color: Colors.white, size: 30)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ...userProfile.keys.map((key) {
                  return key == 'Kullanıcı Adı'
                      ? _buildInfoCard(key, userProfile[key])
                      : isEditing
                          ? _buildEditableInfoCard(key, controllers[key], fieldTypes[key])
                          : _buildInfoCard(key, userProfile[key]);
                }),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isEditing
            ? _updateUserProfile
            : () {
                setState(() {
                  isEditing = true;
                });
              },
        label: Text(
          isEditing ? "Kaydet" : "Düzenle",
          style: const TextStyle(color: AppStyles.textColorWhite), // Yazı rengini beyaz yapıyoruz
        ),
        icon: Icon(
          isEditing ? Icons.save : Icons.edit,
          color: AppStyles.textColorWhite, // İkon rengini beyaz yapıyoruz
        ),
        backgroundColor: isEditing ? AppStyles.activeSwitchColor : AppStyles.buttonColor, // Use AppStyles for color
      ),
      bottomNavigationBar: Footer(
        selectedIndex: _selectedIndex,
      ),
    );
  }

  Widget _buildEditableInfoCard(String title, TextEditingController? controller, String? type) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppStyles.fillColor, // Use AppStyles for color
        border: Border.all(color: AppStyles.borderColor), // Use AppStyles for color
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppStyles.textColor, // Use AppStyles for color
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: type == 'int' ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: type == 'int' ? "Yalnızca sayılar girin" : "Bilgi girin...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            enabled: title != 'Kullanıcı Adı', // Disable editing for 'Kullanıcı Adı'
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    IconData icon;
    switch (title) {
      case 'Ad Soyad':
        icon = Icons.person;
        break;
      case 'Kullanıcı Adı':
        icon = Icons.account_circle;
        break;
      case 'Telefon':
        icon = Icons.phone;
        break;
      case 'E-Mail':
        icon = Icons.email;
        break;
      case 'Adres':
        icon = Icons.home;
        break;
      case 'TC Kimlik No':
        icon = Icons.badge;
        break;
      case 'Yaş':
        icon = Icons.cake;
        break;
      case 'Meslek':
        icon = Icons.work;
        break;
      default:
        icon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppStyles.fillColor, // Use AppStyles for color
        border: Border.all(color: AppStyles.borderColor), // Use AppStyles for color
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppStyles.iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppStyles.textColor, // Use AppStyles for color
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? "Bilinmiyor" : value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.textColor, // Use AppStyles for color
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

