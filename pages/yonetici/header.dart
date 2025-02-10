import 'package:flutter/material.dart';
import 'package:trackfly/pages/yonetici/yonetici_profil.dart'; // Profil sayfasını içeren dosyanızın yolu
import 'package:trackfly/pages/yonetici/yonetici_ayarlar.dart'; // Ayarlar sayfasını içeren dosyanızın yolu
import '../genel/user_provider.dart'; // UserProvider eklendi
import 'package:provider/provider.dart';
import 'package:trackfly/styles.dart';

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
      backgroundColor: AppStyles.primaryColor, // Arkaplan rengi turuncu
      elevation: 4, // Hafif gölge
      toolbarHeight: 140, // Daha büyük bir yükseklik
      leading: onBackPressed != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppStyles.secondaryColor),
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
                MaterialPageRoute(builder: (context) => const YoneticiProfil()),
              );
            },
            child: CircleAvatar(
              radius: 35,
              backgroundColor: AppStyles.secondaryColor, // Çerçeve için beyaz arkaplan
              child: CircleAvatar(
                radius: 33, // Profil resmi için iç çap
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
                    color: AppStyles.secondaryColor,
                  ),
                  overflow: TextOverflow.ellipsis, // Uzun isimler taşmasın
                ),
                const SizedBox(height: 5),
                Text(
                  "Hoş geldiniz!",
                  style: TextStyle(
                    fontSize: 16,
                    color: AppStyles.secondaryColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppStyles.secondaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const YoneticiAyarlar()),
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
