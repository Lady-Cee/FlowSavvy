import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/community_post.dart';
import '../providers/community_support_provider.dart';
import 'reply_bubble.dart';

class CommunityPostCard extends StatelessWidget {
  final CommunityPost post;

  const CommunityPostCard({
    Key? key,
    required this.post,
  }) : super(key: key);

  void _showReplyDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reply"),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "Write your reply...",
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Send"),
            onPressed: () {
              if (controller.text.trim().isEmpty) return;

              final user = FirebaseAuth.instance.currentUser;

              if (user == null) {
                Navigator.pop(context);
                return;
              }

              final provider = Provider.of<CommunitySupportProvider>(
                context,
                listen: false,
              );

              provider.addReply(
                postId: post.id,
                userId: user.uid,
                author: provider.generateAnonymousName(),
                content: controller.text.trim(),
              );

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    Provider.of<CommunitySupportProvider>(context, listen: false);

    final appColor = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// User
            Row(
              children: [

                CircleAvatar(
                  radius: 22,
                  backgroundColor: appColor.primary,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        post.author,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),

                      Text(
                        DateFormat(
                          'MMM d, h:mm a',
                        ).format(post.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            /// Post content
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 15),

            Divider(),

            Row(
              children: [

                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  color: Colors.red,
                  onPressed: () {
                    provider.likePost(post.id);
                  },
                ),

                Text("${post.likes}"),

                const SizedBox(width: 20),

                TextButton.icon(
                  icon: const Icon(Icons.reply),
                  label: const Text("Reply"),
                  onPressed: () {
                    _showReplyDialog(context);
                  },
                ),
              ],
            ),

            if (post.replies.isNotEmpty)
              const Divider(),

            ...post.replies.map(
                  (reply) => ReplyBubble(
                reply: reply,
              ),
            ),
          ],
        ),
      ),
    );
  }
}