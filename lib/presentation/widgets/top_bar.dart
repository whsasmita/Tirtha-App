import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/widgets/app_menu_dialog.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key});

  void _showMenuDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AppMenuDialog();
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.tablet_android, color: Colors.black, size: 28),
        onPressed: () {
          _showMenuDialog(context);
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black, size: 28),
          onPressed: () {},
        ),
      ],
    );
  }
}