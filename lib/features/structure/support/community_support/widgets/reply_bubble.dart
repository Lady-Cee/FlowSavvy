import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/reply.dart';

class ReplyBubble extends StatelessWidget {
  final Reply reply;

  const ReplyBubble({
    Key? key,
    required this.reply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(
        left: 40,
        right: 10,
        top: 8,
        bottom: 8,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appColor.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: appColor.primary.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Anonymous Name
          Text(
            reply.author,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 6),

          /// Reply Content
          Text(
            reply.content,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              DateFormat('MMM d, h:mm a').format(reply.createdAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}