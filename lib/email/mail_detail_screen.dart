import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'entity/mail_model.dart';

class MailDetailScreen extends StatelessWidget {
  final MailModel mail;

  const MailDetailScreen({super.key, required this.mail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(mail.sender)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          mail.subject,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
