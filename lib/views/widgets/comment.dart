import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/service/firestore.dart';
import 'package:instgram_clone/views/widgets/comment_item.dart';

// ignore: must_be_immutable
class Comment extends StatefulWidget {
  String type;
  String uid;
  Comment(this.type, this.uid, {super.key});

  @override
  State<Comment> createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  final comment = TextEditingController();
  final firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.r), topRight: Radius.circular(25.r)),
        child: Container(
            color: Theme.of(context).colorScheme.surface,
            height: 200.h,
            child: Stack(children: [
              Positioned(
                top: 8.h,
                left: 140.w,
                child: Center(
                  child: Column(
                    children: [
                      Container(
                          width: 40.w,
                          height: 3.h,
                          color: Theme.of(context).colorScheme.onSurface),
                      SizedBox(
                        height: 3.h,
                      ),
                      const Text(
                        'Comments',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
              ),
              StreamBuilder(
                stream: firestore
                    .collection(widget.type)
                    .doc(widget.uid)
                    .collection('comment')
                    .snapshots(),
                builder: (context, snapshot) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        return comment_item(
                            snapshot.data!.docs[index].data(), context);
                      },
                      itemCount: snapshot.data == null
                          ? 0
                          : snapshot.data!.docs.length,
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                  height: 60.h,
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.surface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // SizedBox(
                      //   width: 35.w,
                      //   height: 35.h,
                      //   child: ClipOval(
                      //     child: cachedimage(),
                      //   ),
                      // ),
                      Container(
                        height: 45.h,
                        width: 350.w,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(25.r)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5).r,
                          child: TextField(
                            controller: comment,
                            maxLines: 4,
                            decoration: InputDecoration(
                                hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w400),
                                hintText: 'Add a comment',
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    if (comment.text.isNotEmpty) {
                                      Firestore().comments(
                                          comment: comment.text,
                                          type: widget.type,
                                          uidd: widget.uid);
                                    }
                                  },
                                  icon: const Icon(Icons.send),
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ])));
  }
}
