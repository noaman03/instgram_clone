import 'package:flutter/material.dart';
import 'package:instgram_clone/views/widgets/instgram_post.dart';

class Postwidget extends StatelessWidget {
  final snapshot;
  const Postwidget(this.snapshot, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: InstagramPost(snapshot)),
    );
  }
}
