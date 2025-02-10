import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PhoneContainer extends StatelessWidget {
  final Widget child;

  const PhoneContainer({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Center(
        child: Container(
          width: 390, // Width of iPhone 14
          height: 844, // Height of iPhone 14
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: child,
          ),
        ),
      );
    } else {
      return child;
    }
  }
}
