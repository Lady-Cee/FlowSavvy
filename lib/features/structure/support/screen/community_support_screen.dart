
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../models/community_support_model.dart';
import '../../../models/reply.dart';
import '../../../providers/community_support_provider.dart';
import '../../product/screen/product_screen.dart';
// import '../../../models/reply_model.dart';
// import '../../providers/community_support_provider.dart';

class CommunitySupportScreen extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  void _submitPost(BuildContext context) {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) return;

    final newPost = CommunityPost(
      id: const Uuid().v4(),
      author: 'Anonymous',
      title: _titleController.text,
      content: _contentController.text,
      createdAt: DateTime.now(),
    );

    Provider.of<CommunitySupportProvider>(context, listen: false).addPost(newPost);
    _titleController.clear();
    _contentController.clear();
    Navigator.of(context).pop();
  }

  void _showPostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('New Community Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Content'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
          ElevatedButton(onPressed: () => _submitPost(context), child: Text('Post')),
        ],
      ),
    );
  }

  void _showReplyDialog(BuildContext context, String postId) {
    final _replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Reply'),
        content: TextField(
          controller: _replyController,
          decoration: InputDecoration(labelText: 'Your Reply'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final replyText = _replyController.text.trim();
              if (replyText.isNotEmpty) {
                final reply = Reply(
                  id: Uuid().v4(),
                  author: 'Anonymous',
                  content: replyText,
                  createdAt: DateTime.now(),
                );
                Provider.of<CommunitySupportProvider>(context, listen: false)
                    .addReplyToPost(postId, reply);
                Navigator.of(context).pop();
              }
            },
            child: Text('Reply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final posts = Provider.of<CommunitySupportProvider>(context).posts;

    return Scaffold(
      // appBar: AppBar(title: Text('Community Support')),
      appBar: AppBar(
        title: Text('Community Support'),
        actions: [
          PopupMenuButton<int>(
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.menu),
            ),
            tooltip: 'Menu',
            onSelected: (value) {
              switch (value) {
                case 0:
                  Navigator.pushNamed(context, '/product');
                  break;
                case 1:
                  Navigator.pushNamed(context, '/doctor');
                  break;
                case 2:
                  Navigator.pushNamed(context, '/counsellor');
                  break;
                case 3:
                  Navigator.pushNamed(context, '/mentalHealthProfessional');
                  break;
                case 4:
                  Navigator.pushNamed(context, '/communityAdmin');
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart, color: Colors.pink),
                    SizedBox(width: 10),
                    Text('Recommended Products'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.medical_services, color: Colors.pink),
                    SizedBox(width: 10),
                    Text('Consult a Doctor'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.support_agent, color: Colors.pink),
                    SizedBox(width: 10),
                    Text('Consult a Counsellor'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 3,
                child: Row(
                  children: [
                    Icon(Icons.health_and_safety, color: Colors.pink),
                    SizedBox(width: 10),
                    Flexible(
                        child: Text('Consult a Mental Health Professional',
                          overflow: TextOverflow.visible,
                        ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 4,
                child: Row(
                  children: [
                    Icon(Icons.apartment, color: Colors.pink),
                    SizedBox(width: 10),
                    Text('Consult a Community Admin'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: posts.isEmpty
          ? Center(child: Text('No posts yet. Be the first to share!'))
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (ctx, i) {
          final post = posts[i];
          return Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 5),
                  Text(post.content),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text('${post.likes} ❤️'),
                      IconButton(
                        icon: Icon(Icons.thumb_up),
                        onPressed: () {
                          Provider.of<CommunitySupportProvider>(context, listen: false).likePost(post.id);
                        },
                      ),
                      TextButton(
                        onPressed: () => _showReplyDialog(context, post.id),
                        child: Text('Reply'),
                      ),
                    ],
                  ),
                  if (post.replies.isNotEmpty) Divider(),
                  ...post.replies.map((reply) => Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${reply.author} replied:', style: TextStyle(fontWeight: FontWeight.w600)),
                        Text(reply.content),
                        SizedBox(height: 4),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPostDialog(context),
        child: Icon(Icons.add),
        tooltip: "Create Post",
      ),
    );
  }
}

