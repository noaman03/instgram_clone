import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/service/firestore.dart';
import 'package:instgram_clone/util/functions/image_cache.dart';
import 'package:instgram_clone/views/widgets/comment.dart';
import 'package:instgram_clone/views/widgets/like_animation.dart';

class InstagramPost extends StatefulWidget {
  final snapshot;
  const InstagramPost(this.snapshot, {super.key});

  @override
  State<InstagramPost> createState() => _InstagramPostState();
}

class _InstagramPostState extends State<InstagramPost> {
  bool isanimated = false;
  String user = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = _auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 380.w,
          height: 60.h,
          color: Theme.of(context).colorScheme.surface,
          child: ListTile(
            leading: SizedBox(
              width: 35.w,
              height: 35.h,
              child: ClipOval(
                child: cachedimage(widget.snapshot['profileImage']),
              ),
            ),
            title: Text(
              widget.snapshot['username'],
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ),
        GestureDetector(
          onDoubleTap: () {
            Firestore().like(
                like: widget.snapshot['like'],
                type: 'post',
                uid: user,
                postId: widget.snapshot['postId']);
            setState(() {
              isanimated = true;
            });
            Future.delayed(const Duration(milliseconds: 400), () {
              setState(() {
                isanimated = false;
              });
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                  width: 375.w,
                  height: 375.h,
                  child: cachedimage(widget.snapshot['postImage'])),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isanimated ? 1 : 0,
                child: LikeAnimation(
                  isAnimating: isanimated,
                  duration: const Duration(milliseconds: 400),
                  iconlike: false,
                  End: () {
                    setState(() {
                      isanimated = false;
                    });
                  },
                  child: Icon(
                    Icons.favorite,
                    size: 100.w,
                    color: Colors.red,
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          width: 380.w,
          child: Column(
            children: [
              SizedBox(
                height: 10.h,
              ),
              Row(
                children: [
                  SizedBox(
                    width: 10.w,
                  ),
                  LikeAnimation(
                    isAnimating: widget.snapshot['like'].contains(user),
                    child: IconButton(
                      onPressed: () async {
                        final updatedLikes = await Firestore().like(
                            like: widget.snapshot['like'] ?? [],
                            type: 'post',
                            uid: user,
                            postId: widget.snapshot['postId']);
                        setState(() {
                          widget.snapshot['like'] = updatedLikes;
                        });
                      },
                      icon: Icon(
                        widget.snapshot['like'].contains(user)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.snapshot['like'].contains(user)
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurface,
                        size: 24.w,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  GestureDetector(
                    onTap: () {
                      showBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: DraggableScrollableSheet(
                              maxChildSize: 0.5,
                              initialChildSize: 0.5,
                              minChildSize: 0.2,
                              builder: (context, scrollController) {
                                return Comment(
                                    widget.snapshot['postId'], 'post');
                              },
                            ),
                          );
                        },
                      );
                    },
                    child: Image.asset(
                      'assets/images/chat.png',
                      height: 20.h,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Image.asset(
                    'assets/images/send.png',
                    height: 24.h,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 26).r,
                    child: Text(
                      widget.snapshot['like'].length.toString(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  SizedBox(
                    width: 10.w,
                  ),
                  Text(
                    widget.snapshot['username'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    widget.snapshot['caption'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10).r,
                    child: Text(
                      formatDate(widget.snapshot['time'].toDate(),
                          [yyyy, '-', mm, '-', dd]),
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
