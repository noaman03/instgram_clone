import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instgram_clone/util/functions/image_cache.dart';
import 'package:instgram_clone/views/screens/profile_screen.dart';
import 'package:instgram_clone/views/widgets/postwidget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final search = TextEditingController();
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  bool show = true;
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SearchBox(isDarkMode),
            if (show)
              StreamBuilder<QuerySnapshot>(
                stream: _firebaseFirestore.collection('post').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final snap = snapshot.data!.docs[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Postwidget(
                                  snap.data(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                            ),
                            child: cachedimage(
                              snap['postImage'],
                            ),
                          ),
                        );
                      },
                      childCount: snapshot.data!.docs.length,
                    ),
                    gridDelegate: SliverQuiltedGridDelegate(
                      crossAxisCount: 3,
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                      pattern: const [
                        QuiltedGridTile(2, 1),
                        QuiltedGridTile(2, 2),
                        QuiltedGridTile(1, 1),
                        QuiltedGridTile(1, 1),
                        QuiltedGridTile(1, 1),
                      ],
                    ),
                  );
                },
              ),
            if (!show)
              StreamBuilder(
                stream: _firebaseFirestore
                    .collection('users')
                    .where('username', isGreaterThanOrEqualTo: search.text)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()));
                  }
                  return SliverPadding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final snap = snapshot.data!.docs[index];
                          return Column(
                            children: [
                              SizedBox(height: 10.h),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        ProfileScreen(Uid: snap.id),
                                  ));
                                },
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 23.r,
                                      backgroundImage: NetworkImage(
                                        snap['profile'],
                                      ),
                                    ),
                                    SizedBox(width: 15.w),
                                    Text(snap['username']),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        childCount: snapshot.data!.docs.length,
                      ),
                    ),
                  );
                },
              )
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter SearchBox(bool isdarkmood) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Container(
          width: double.infinity,
          height: 36.h,
          decoration: BoxDecoration(
            color: isdarkmood
                ? const Color.fromRGBO(239, 239, 239, 0.2)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.all(
              Radius.circular(10.r),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        if (value.isNotEmpty) {
                          show = false;
                        } else {
                          show = true;
                        }
                      });
                    },
                    controller: search,
                    decoration: const InputDecoration(
                      hintText: 'Search User',
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
