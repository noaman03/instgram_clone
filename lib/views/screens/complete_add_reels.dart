import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/service/firestore.dart';
import 'package:instgram_clone/service/storage.dart';
import 'package:video_player/video_player.dart';

// ignore: must_be_immutable
class CompleteAddReels extends StatefulWidget {
  File videofile;
  CompleteAddReels(this.videofile, {super.key});

  @override
  State<CompleteAddReels> createState() => _CompleteAddReelsState();
}

class _CompleteAddReelsState extends State<CompleteAddReels> {
  final caption = TextEditingController();
  late VideoPlayerController controller;
  bool islooding = false;
  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(widget.videofile)
      ..initialize().then((_) {
        setState(() {});
        controller.setLooping(true);
        controller.setVolume(1.0);
        controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'New Reel',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: SafeArea(
          child: islooding
              ? const CircularProgressIndicator(
                  color: Colors.grey,
                )
              : Column(
                  children: [
                    SizedBox(
                      height: 10.h,
                    ),
                    Center(
                      child: SizedBox(
                          width: 150.w,
                          height: 200.h,
                          child: controller.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio: controller.value.aspectRatio,
                                  child: VideoPlayer(controller),
                                )
                              : const CircularProgressIndicator(
                                  color: Colors.grey,
                                )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(10).w,
                        child: TextField(
                          decoration: InputDecoration(
                              hintText: 'Add a caption...',
                              hintStyle: TextStyle(
                                  fontSize: 10.sp, color: Colors.grey),
                              border: const UnderlineInputBorder(
                                  borderSide: BorderSide.none)),
                        ),
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
                            onTap: () async {
                              setState(() {
                                islooding = true;
                              });
                              String reelurl = await storagemethod()
                                  .uploadImageToStorage(
                                      'reel', widget.videofile);
                              await Firestore().creatreel(
                                  video: reelurl, caption: caption.text);
                            },
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
                )),
    );
  }
}
