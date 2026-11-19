import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/community_support_provider.dart';
import '../widgets/community_header.dart';
import '../widgets/community_post_card.dart';
import '../widgets/create_post_dialog.dart';
import '../widgets/empty_community.dart';

class CommunitySupportScreen extends StatefulWidget {
  const CommunitySupportScreen({Key? key}) : super(key: key);

  @override
  State<CommunitySupportScreen> createState() =>
      _CommunitySupportScreenState();
}

class _CommunitySupportScreenState extends State<CommunitySupportScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<CommunitySupportProvider>(
        context,
        listen: false,
      ).loadPosts();
    });
  }

  void _createPost() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    showDialog(
      context: context,
      builder: (_) => CreatePostDialog(
        userId: user.uid,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommunitySupportProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Community Support"),
        actions: [
          PopupMenuButton<int>(
            icon: const Padding(
              padding: EdgeInsets.all(8.0),
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
                  Navigator.pushNamed(
                      context, '/mentalHealthProfessional');
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
                  children: const [
                    Icon(Icons.shopping_cart, color: Colors.pink),
                    SizedBox(width: 10),
                    Text('Recommended Products'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: const [
                    Icon(Icons.medical_services, color: Colors.pink),
                    SizedBox(width: 10),
                    Text('Consult a Doctor'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: Row(
                  children: const [
                    Icon(Icons.support_agent, color: Colors.pink),
                    SizedBox(width: 10),
                    Text('Consult a Counsellor'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 3,
                child: Row(
                  children: const [
                    Icon(Icons.health_and_safety,
                        color: Colors.pink),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Consult a Mental Health Professional',
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 4,
                child: Row(
                  children: const [
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

      body: RefreshIndicator(
        onRefresh: () async {
          await provider.refreshPosts();
        },
        child: provider.isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : provider.posts.isEmpty
            ? ListView(
          children: const [
            SizedBox(height: 20),
            CommunityHeader(),
            SizedBox(height: 50),
            EmptyCommunity(),
          ],
        )
            : ListView(
          padding: const EdgeInsets.only(bottom: 90),
          children: [
            const CommunityHeader(),
            const SizedBox(height: 10),

            ...provider.posts.map(
                  (post) => CommunityPostCard(
                post: post,
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPost,
        backgroundColor: Colors.pink,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          "Share",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}