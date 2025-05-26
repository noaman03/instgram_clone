import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/models/user_model.dart';
import 'package:instgram_clone/service/firestore.dart';
import 'package:instgram_clone/util/functions/image_cache.dart';
import 'package:instgram_clone/util/functions/theme_provider.dart';
import 'package:instgram_clone/views/screens/editprofile_screen.dart';
import 'package:instgram_clone/views/widgets/postwidget.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  String Uid;

  ProfileScreen({super.key, required this.Uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  bool yours = false;
  List following = [];
  bool isfollow = false;
  bool isDarkMode = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getdata();
    if (_auth.currentUser!.uid == widget.Uid) {
      setState(() {
        yours = true;
      });
    }
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  getdata() async {
    DocumentSnapshot snap = await _firebaseFirestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
    List follow = (snap.data()! as dynamic)['following'];
    if (follow.contains(widget.Uid)) {
      setState(() {
        isfollow = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Row(
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: _firebaseFirestore
                    .collection('users')
                    .doc(widget.Uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text(
                      'Loading...',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 20.sp),
                    );
                  }
                  final userData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return Text(
                    userData['username'] ?? 'No Name',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  );
                },
              ),
              const Icon(Icons.keyboard_arrow_down)
            ],
          ),
          // actions: [
          //   IconButton(
          //       onPressed: () {},
          //       icon: const Icon(
          //         Icons.menu_outlined,
          //       ))
          // ],
        ),
        endDrawer: SafeArea(
          child: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading:
                      Icon(isDarkMode ? Icons.nights_stay : Icons.wb_sunny),
                  title: const Text('Toggle Theme'),
                  onTap: () {
                    Provider.of<ThemeProvider>(context, listen: false)
                        .toggltheme();
                  },
                ),
                GestureDetector(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Row(
                      children: [
                        Icon(Icons.power_settings_new),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ThemeDrawerExample(),
        body: SafeArea(
            child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: FutureBuilder(
              future: Firestore().getuser(uidd: widget.Uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return head(snapshot.data!, isDarkMode);
              },
            )),
            StreamBuilder(
              stream: _firebaseFirestore
                  .collection('post')
                  .where('uid', isEqualTo: widget.Uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()));
                }
                var postlenght = snapshot.data!.docs.length;
                return SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        var posts = snapshot.data!.docs[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    Postwidget(posts.data())));
                          },
                          child: Container(
                            child: cachedimage(posts['postImage']),
                          ),
                        );
                      },
                      childCount: postlenght,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4));
              },
            )
          ],
        )),
      ),
    );
  }

  Widget head(UserModel user, bool isdarkmode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              child: ClipOval(
                  child: SizedBox(
                width: 75.w,
                height: 75.h,
                child: cachedimage(user.profile),
              )),
            ),
            Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 35.w,
                    ),
                    Text(
                      '0',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15.sp),
                    ),
                    SizedBox(
                      width: 53.w,
                    ),
                    Text(
                      user.followers.length.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15.sp),
                    ),
                    SizedBox(
                      width: 70.w,
                    ),
                    Text(
                      user.following.length.toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15.sp),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 40.w,
                    ),
                    Text(
                      'posts',
                      style: TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 13.sp),
                    ),
                    SizedBox(
                      width: 25.w,
                    ),
                    Text(
                      'followers',
                      style: TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 13.sp),
                    ),
                    SizedBox(
                      width: 19.w,
                    ),
                    Text(
                      'following',
                      style: TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 13.sp),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.sp),
              ),
              Text(
                user.bio,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12.sp),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        if (!isfollow)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GestureDetector(
              onTap: () {
                if (!yours) {
                  Firestore().follow(uid: widget.Uid);
                  setState(() {
                    isfollow = true;
                  });
                }
              },
              child: Container(
                alignment: Alignment.center,
                height: 30,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: yours
                        ? isdarkmode
                            ? Colors.grey.shade900
                            : Colors.grey.shade100
                        : Colors.blue,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        color: yours
                            ? isdarkmode
                                ? Colors.grey.shade900
                                : Colors.grey.shade100
                            : Colors.blue)),
                child: yours
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const EditProfile(),
                            ));
                          });
                        },
                        child: Text(
                          'edit profile',
                          style: TextStyle(
                              fontSize: 14.sp,
                              color: Theme.of(context).colorScheme.onSurface),
                        ),
                      )
                    : const Text(
                        'follow',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ),
        if (isfollow)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    if (!yours) {
                      Firestore().follow(uid: widget.Uid);
                      setState(() {
                        isfollow = false;
                      });
                    }
                  },
                  child: Container(
                      alignment: Alignment.center,
                      height: 30.h,
                      width: 170.w,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(5.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Text('Unfollow')),
                ),
                SizedBox(width: 8.w),
                Container(
                  alignment: Alignment.center,
                  height: 30.h,
                  width: 170.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(5.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Text(
                    'Message',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TabBar(
              indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  insets: const EdgeInsets.symmetric(horizontal: 55)),
              unselectedLabelColor: Colors.grey.shade500,
              labelColor: Theme.of(context).colorScheme.onSurface,
              tabs: const [
                Icon(
                  Icons.grid_on,
                ),
                Icon(Icons.video_collection),
                Icon(Icons.person)
              ]),
        ),
        const SizedBox(
          height: 5,
        )
      ],
    );
  }
}
