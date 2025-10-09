import 'package:flutter/material.dart';
import 'package:tirtha_app/presentation/themes/color.dart';

class BottomNavV1 extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavV1({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
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
          IconButton(
            icon: const Icon(Icons.home_outlined, size: 30),
            color: selectedIndex == 0 ? AppColors.secondary : Colors.grey,
            onPressed: () => onItemTapped(0),
          ),
          
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: selectedIndex == 1 ? AppColors.secondary : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.menu_book_outlined, size: 30),
              color: selectedIndex == 1 ? Colors.white : Colors.grey,
              onPressed: () => onItemTapped(1),
            ),
          ),
          
          IconButton(
            icon: const Icon(Icons.person_outline, size: 30),
            color: selectedIndex == 2 ? AppColors.secondary : Colors.grey,
            onPressed: () => onItemTapped(2),
          ),
        ],
      ),
    );
  }
}