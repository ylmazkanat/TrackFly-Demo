import 'package:flutter/material.dart';
import 'package:trackfly/pages/surucu/surucu_profil.dart'; // Profil sayfasını içeren dosyanızın yolu
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
                MaterialPageRoute(builder: (context) => const SurucuProfil()),
              );
            },
            child: const CircleAvatar(
              radius: 35,
              backgroundColor: AppStyles.avatarBackgroundColor,
              child: CircleAvatar(
                radius: 33,
                backgroundImage: AssetImage('lib/images/profil.png'),
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
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(140);
}
