import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContactChip extends StatelessWidget {
  final String contact;
  const ContactChip({super.key, required this.contact});

  void copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: contact));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Copied: $contact")));
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const Icon(Icons.copy, size: 16, color: Colors.blue),
      label: Text(contact,
          style: const TextStyle(fontSize: 12, color: Colors.black87)),
      onPressed: () => copyToClipboard(context),
    );
  }
}
