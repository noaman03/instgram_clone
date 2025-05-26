import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/views/screens/add_reels.dart';
import 'package:instgram_clone/views/widgets/instgram_reels.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black, // Changed to black to match Instagram's reels UI
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Reels content
          StreamBuilder<QuerySnapshot>(
            stream: _firebaseFirestore
                .collection('reel')
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              // Empty state
              if (snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam_off_outlined,
                        color: Colors.white,
                        size: 60,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No reels available',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return PageView.builder(
                scrollDirection: Axis.vertical,
                controller: _pageController,
                itemCount: snapshot.data!.docs.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  // Pass isActive parameter to control video playback
                  return InstgramReels(
                    snapshot.data!.docs[index].data(),
                    isActive: _currentIndex == index,
                  );
                },
              );
            },
          ),

          // App bar overlay
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0.w), // Fixed padding error
                  child: Row(
                    children: [
                      Text(
                        'Reels',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w500),
                      ),
                      Icon(
                        Icons.arrow_drop_down_outlined,
                        color: Colors.white,
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          // Navigate to create reels screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddReelsscreen(),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
