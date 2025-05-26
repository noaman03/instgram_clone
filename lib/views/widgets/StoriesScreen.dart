import 'package:flutter/material.dart';
import 'package:instgram_clone/service/firestore.dart';
import 'package:instgram_clone/views/widgets/StoryWidget.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Firestore().fetchStories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error loading stories'));
        } else if (!snapshot.hasData || snapshot.data!['others'].isEmpty) {
          return const Center(child: Text('No stories available'));
        }

        // Pass the fetched data to StoryWidget
        return StoryWidget(stories: snapshot.data!);
      },
    );
  }
}
