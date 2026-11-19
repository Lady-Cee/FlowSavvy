import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/community_support_provider.dart';

class CreatePostDialog extends StatefulWidget {
  final String userId;

  const CreatePostDialog({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitPost() {

    final text = _controller.text.trim();

    if (text.isEmpty) return;

    Provider.of<CommunitySupportProvider>(
      context,
      listen: false,
    ).addPost(
      userId: widget.userId,
      content: text,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    final appColor = Theme.of(context).colorScheme;

    return AlertDialog(

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      title: const Text(
        "How are you feeling today?",
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Text(
            "Share your experience, ask a question or encourage another girl. Your identity will remain anonymous.",
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: _controller,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: "Type here...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),

      actions: [

        TextButton(
          onPressed: (){
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),

        ElevatedButton.icon(

          style: ElevatedButton.styleFrom(
            backgroundColor: appColor.primary,
          ),

          onPressed: _submitPost,

          icon: const Icon(Icons.send),

          label: const Text(
            "Post",
          ),
        ),
      ],
    );
  }
}

//
//
// Backend Developer
// Your backend developer doesn't need to change this UI.
// The only thing they'll ensure is that userId comes from Firebase Authentication, for example:
// userId: FirebaseAuth.instance.currentUser!.uid,