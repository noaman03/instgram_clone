import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/blocs/user/user_bloc.dart';
import 'package:instgram_clone/blocs/user/user_event.dart';
import 'package:instgram_clone/blocs/user/user_state.dart';
import 'package:instgram_clone/views/screens/view_post.dart';

class Profile extends StatefulWidget {
  final String uid;

  const Profile({Key? key, required this.uid}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isFollowing = false;
  bool isLoading = true;
  int postCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkFollowingStatus();
    _countPosts();
  }

  Future<void> _loadUserData() async {
    context.read<UserBloc>().add(GetUser(userId: widget.uid));
  }

  Future<void> _checkFollowingStatus() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      List following = (userDoc.data() as Map<String, dynamic>)['following'];
      setState(() {
        isFollowing = following.contains(widget.uid);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error checking follow status: $e");
    }
  }

  Future<void> _countPosts() async {
    try {
      QuerySnapshot postsSnapshot = await _firestore
          .collection('post')
          .where('uid', isEqualTo: widget.uid)
          .get();

      setState(() {
        postCount = postsSnapshot.docs.length;
      });
    } catch (e) {
      print("Error counting posts: $e");
    }
  }

  void _toggleFollow() {
    context.read<UserBloc>().add(FollowUser(widget.uid));
    setState(() {
      isFollowing = !isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = widget.uid == _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (isCurrentUser)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigate to settings
              },
            ),
        ],
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is UserLoaded) {
            final user = state.user;
            return Column(
              children: [
                SizedBox(height: 16.h),
                // Profile header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40.r,
                        backgroundImage: NetworkImage(user.profile),
                      ),
                      SizedBox(width: 24.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              user.bio,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Stats row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(postCount, 'Posts'),
                      _buildStatColumn(user.followers.length, 'Followers'),
                      _buildStatColumn(user.following.length, 'Following'),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Follow/Edit Profile button
                if (!isCurrentUser)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isFollowing ? Colors.grey[300] : Colors.blue,
                        foregroundColor:
                            isFollowing ? Colors.black : Colors.white,
                        minimumSize: Size(double.infinity, 36.h),
                      ),
                      child: Text(isFollowing ? 'Following' : 'Follow'),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to edit profile
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, 36.h),
                      ),
                      child: const Text('Edit Profile'),
                    ),
                  ),

                SizedBox(height: 16.h),

                // Divider
                const Divider(height: 1),

                // Posts grid
                Expanded(
                  child: FutureBuilder<QuerySnapshot>(
                    future: _firestore
                        .collection('post')
                        .where('uid', isEqualTo: widget.uid)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No posts yet'));
                      }

                      return GridView.builder(
                        padding: EdgeInsets.all(2.w),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 2.w,
                          mainAxisSpacing: 2.h,
                        ),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final post = snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                          return InkWell(
                            onTap: () {
                              // Navigate to post detail
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewPost(
                                    postId: post['postId'],
                                  ),
                                ),
                              );
                            },
                            child: Image.network(
                              post['postImage'],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('User not found'));
        },
      ),
    );
  }

  Widget _buildStatColumn(int count, String label) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label),
      ],
    );
  }
}
