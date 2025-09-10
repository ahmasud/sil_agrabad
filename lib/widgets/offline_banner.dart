import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.orange.shade200,
      padding: const EdgeInsets.all(8),
      child: const Text(
        "⚠️ Offline Mode: Showing cached data",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black87),
      ),
    );
  }
}
