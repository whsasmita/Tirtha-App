import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';

class BottomNavV2 extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavV2({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home (Indeks 0)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: selectedIndex == 0 ? AppColors.secondary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.home_outlined, size: 30),
              color: selectedIndex == 0 ? Colors.white : Colors.grey,
              onPressed: () => onItemTapped(0),
            ),
          ),
          
          // Edukasi (Indeks 1)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: selectedIndex == 1 ? AppColors.secondary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.menu_book_outlined, size: 30),
              color: selectedIndex == 1 ? Colors.white : Colors.grey,
              onPressed: () => onItemTapped(1),
            ),
          ),
          
          // Kuis (Indeks 2) - Dilingkari
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: selectedIndex == 2 ? AppColors.secondary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.help_outline, size: 30),
              color: selectedIndex == 2 ? Colors.white : Colors.grey,
              onPressed: () => onItemTapped(2),
            ),
          ),
        ],
      ),
    );
  }
}