import 'package:flutter/material.dart';
import 'package:trackfly/pages/kullanici/kullanici_profil.dart'; // Profil sayfasını içeren dosyanın yolu
import 'package:trackfly/pages/kullanici/kullanici_ayarlar.dart'; // Ayarlar sayfasını içeren dosyanın yolu
import '../genel/user_provider.dart'; // UserProvider eklendi
import 'package:provider/provider.dart';
import 'package:trackfly/styles.dart'; // Import the styles file

class Header extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;

  const Header({
    super.key,
    required this.title,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final fullname = Provider.of<UserProvider>(context).fullname;
    final profileImageUrl = Provider.of<UserProvider>(context).profileImageUrl; // Get profile image URL

    return AppBar(
      backgroundColor: AppStyles.primaryColor, // Use primary color
      elevation: 4,
      toolbarHeight: 140,
      leading: onBackPressed != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppStyles.iconColorWhite),
              onPressed: onBackPressed,
            )
          : null,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KullaniciProfil()),
              );
            },
            child: CircleAvatar(
              radius: 35,
              backgroundColor: AppStyles.avatarBackgroundColor,
              child: CircleAvatar(
                radius: 33,
                backgroundImage: profileImageUrl != null
                    ? NetworkImage(profileImageUrl)
                    : const AssetImage('lib/images/profil.png') as ImageProvider,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fullname,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppStyles.textColorWhite,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  "Hoş geldiniz!",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppStyles.textColorWhite.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppStyles.iconColorWhite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KullaniciAyarlar()),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(140);
}
