import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/service/firestore.dart';
import 'package:instgram_clone/service/storage.dart';

class CompleteAddPost extends StatefulWidget {
  final File _file;
  const CompleteAddPost(this._file, {super.key});

  @override
  State<CompleteAddPost> createState() => _CompleteAddPostState();
}

class _CompleteAddPostState extends State<CompleteAddPost> {
  final caption = TextEditingController();
  bool islooding = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'New Post',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: SafeArea(
        child: islooding
            ? const Center(
                child: CircularProgressIndicator(
                color: Colors.black,
              ))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10).w,
                    child: Center(
                      child: Container(
                        width: 165.w,
                        height: 200.h,
                        decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(10).w,
                            image: DecorationImage(
                                image: FileImage(widget._file),
                                fit: BoxFit.cover)),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(10).w,
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: 'Write a caption...',
                            hintStyle:
                                TextStyle(fontSize: 10.sp, color: Colors.grey),
                            border: const UnderlineInputBorder(
                                borderSide: BorderSide.none)),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10).w,
                        child: SizedBox(
                          width: double.infinity.w,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: const BorderRadius.all(
                                            Radius.circular(8))
                                        .w),
                                backgroundColor: Colors.blue,
                              ),
                              onPressed: () async {
                                setState(() {
                                  islooding = true;
                                });
                                String postUrl = await storagemethod()
                                    .uploadImageToStorage('post', widget._file);
                                await Firestore().creatpost(
                                    postimage: postUrl, caption: caption.text);
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'Share',
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      )
                    ],
                  )
                ],
              ),
      ),
    );
  }
}
