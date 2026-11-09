import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

String _toInternational(String raw) {
  var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('0')) digits = '234${digits.substring(1)}';
  return digits;
}

Future<void> _open(BuildContext context, Uri uri) async {
  final ok = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
    webOnlyWindowName: '_blank', // new tab on web, so the app stays open
  );
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open contact option')),
    );
  }
}

Future<void> contactProfessional(BuildContext context, String contact) async {
  final value = contact.trim();

  // Links and emails open directly
  if (value.startsWith('http')) return _open(context, Uri.parse(value));
  if (value.contains('@')) {
    return _open(context, Uri(scheme: 'mailto', path: value));
  }

  final digits = _toInternational(value);
  final whatsapp = Uri.parse('https://wa.me/$digits');

  // Web: WhatsApp only
  if (kIsWeb) return _open(context, whatsapp);

  // Mobile: let the user choose
  showModalBottomSheet(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.call, color: Colors.pink),
            title: const Text('Call'),
            onTap: () {
              Navigator.pop(sheetContext);
              _open(context, Uri(scheme: 'tel', path: '+$digits'));
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat, color: Colors.green),
            title: const Text('WhatsApp'),
            onTap: () {
              Navigator.pop(sheetContext);
              _open(context, whatsapp);
            },
          ),
        ],
      ),
    ),
  );
}