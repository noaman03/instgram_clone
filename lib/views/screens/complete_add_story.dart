import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/service/firestore.dart';
import 'package:instgram_clone/service/storage.dart';

// ignore: must_be_immutable
class CompleteAddStory extends StatefulWidget {
  final File storyFile;
  const CompleteAddStory(this.storyFile, {super.key});

  @override
  State<CompleteAddStory> createState() => _CompleteAddStoryState();
}

class _CompleteAddStoryState extends State<CompleteAddStory> {
  final captionController = TextEditingController();
  bool isLoading = false;

  Future<void> shareStory() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Upload story to Firebase Storage
      String storyUrl = await storagemethod()
          .uploadImageToStorage('stories', widget.storyFile);

      // Save story in Firestore
      await Firestore().createStory(mediaUrl: storyUrl);

      // Show success message and navigate back
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Story shared successfully!"),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error sharing story: $e"),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'New Story',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.grey),
              )
            : Column(
                children: [
                  SizedBox(height: 10.h),
                  Center(
                    child: SizedBox(
                      width: 375.w,
                      height: 600.h,
                      child: Image.file(
                        widget.storyFile,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: SizedBox(
                      width: 2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0).r,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: 40.h,
                          width: 150.w,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10).w,
                          ),
                          child: const Text(
                            'Save draft',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: shareStory,
                          child: Container(
                            alignment: Alignment.center,
                            height: 40.h,
                            width: 150.w,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10).w,
                            ),
                            child: const Text(
                              'Share',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
      ),
    );
  }
}
