import 'package:flutter/material.dart';

class EmptyCommunity extends StatelessWidget {
  const EmptyCommunity({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              Icons.forum_outlined,
              size: 90,
              color: Colors.pink.shade300,
            ),

            const SizedBox(height: 20),

            const Text(
              "No conversations yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Be the first to ask a question or share your experience. "
                  "Remember, every post is anonymous.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text("Start the First Conversation"),
            ),
          ],
        ),
      ),
    );
  }
}