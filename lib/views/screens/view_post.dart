import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/blocs/interaction/interaction_bloc.dart';
import 'package:instgram_clone/blocs/interaction/interaction_event.dart';
import 'package:instgram_clone/blocs/interaction/interaction_state.dart';
import 'package:instgram_clone/views/screens/profile.dart';
import 'package:timeago/timeago.dart' as timeago;

class ViewPost extends StatefulWidget {
  final String postId;

  const ViewPost({Key? key, required this.postId}) : super(key: key);

  @override
  State<ViewPost> createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();
  bool isLiked = false;
  bool isLoading = true;
  Map<String, dynamic>? postData;

  @override
  void initState() {
    super.initState();
    _loadPostData();
  }

  Future<void> _loadPostData() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot postDoc =
          await _firestore.collection('post').doc(widget.postId).get();

      if (postDoc.exists) {
        setState(() {
          postData = postDoc.data() as Map<String, dynamic>;
          isLiked =
              (postData?['like'] as List).contains(_auth.currentUser!.uid);
          isLoading = false;
        });

        // Load comments
        context.read<InteractionBloc>().add(
              LoadComments(
                type: 'post',
                contentId: widget.postId,
              ),
            );
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error loading post: $e");
    }
  }

  void _toggleLike() {
    context.read<InteractionBloc>().add(
          ToggleLike(
            type: 'post',
            contentId: widget.postId,
          ),
        );

    setState(() {
      isLiked = !isLiked;
    });
  }

  void _postComment() {
    if (_commentController.text.isNotEmpty) {
      context.read<InteractionBloc>().add(
            AddComment(
              comment: _commentController.text,
              type: 'post',
              contentId: widget.postId,
            ),
          );
      _commentController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : postData == null
              ? const Center(child: Text('Post not found'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post header
                      ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Profile(uid: postData!['uid']),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(postData!['profileImage']),
                          ),
                        ),
                        title: Text(postData!['username']),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            // Show options
                          },
                        ),
                      ),

                      // Post image
                      AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          postData!['postImage'],
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Actions row
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isLiked ? Colors.red : null,
                              ),
                              onPressed: _toggleLike,
                            ),
                            IconButton(
                              icon: const Icon(Icons.comment_outlined),
                              onPressed: () {
                                // Focus comment field
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                _commentController.clear();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.send_outlined),
                              onPressed: () {
                                // Share post
                              },
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.bookmark_border),
                              onPressed: () {
                                // Save post
                              },
                            ),
                          ],
                        ),
                      ),

                      // Likes count
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          '${(postData!['like'] as List).length} likes',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      // Caption
                      if (postData!['caption'] != null &&
                          postData!['caption'].toString().isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 4.h),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                              children: [
                                TextSpan(
                                  text: postData!['username'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: ' '),
                                TextSpan(text: postData!['caption']),
                              ],
                            ),
                          ),
                        ),

                      // Timestamp
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 4.h),
                        child: Text(
                          timeago.format(
                              (postData!['time'] as Timestamp).toDate()),
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),

                      const Divider(),

                      // Comments section
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          'Comments',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),

                      BlocBuilder<InteractionBloc, InteractionState>(
                        builder: (context, state) {
                          if (state is InteractionLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (state is CommentsLoaded) {
                            return StreamBuilder<QuerySnapshot>(
                              stream: state.comments,
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (snapshot.data!.docs.isEmpty) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child:
                                        Center(child: Text('No comments yet')),
                                  );
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    final comment = snapshot.data!.docs[index]
                                        .data() as Map<String, dynamic>;

                                    return ListTile(
                                      leading: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Profile(
                                                  uid: comment['uid'] ?? ''),
                                            ),
                                          );
                                        },
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              comment['profileImage']),
                                          radius: 15.r,
                                        ),
                                      ),
                                      title: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: comment['username'],
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const TextSpan(text: ' '),
                                            TextSpan(text: comment['comment']),
                                          ],
                                        ),
                                      ),
                                      subtitle: comment['timestamp'] != null
                                          ? Text(
                                              timeago.format(
                                                  (comment['timestamp']
                                                          as Timestamp)
                                                      .toDate()),
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            )
                                          : null,
                                      dense: true,
                                    );
                                  },
                                );
                              },
                            );
                          }

                          return const SizedBox();
                        },
                      ),

                      SizedBox(height: 60.h), // Space for comment input field
                    ],
                  ),
                ),
      bottomSheet: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16.r,
              backgroundImage: NetworkImage(
                // This should be current user's profile image
                postData?['profileImage'] ?? '',
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            TextButton(
              onPressed: _postComment,
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
