import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/views/screens/add_post.dart';
import 'package:instgram_clone/views/screens/add_reels.dart';
import 'package:instgram_clone/views/screens/add_story.dart';

class addpage extends StatefulWidget {
  const addpage({super.key});

  @override
  State<addpage> createState() => _AddPageState();
}

class _AddPageState extends State<addpage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const StoryScreen(),
    const AddPostscreen(),
    const AddReelsscreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _screens,
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: 10,
              right: _selectedIndex == 0 ? 100 : 150,
              child: Container(
                width: 120.w,
                height: 30.h,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20).w,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _onItemTapped(0);
                      },
                      child: Text(
                        'Story',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color:
                              _selectedIndex == 0 ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _onItemTapped(1);
                      },
                      child: Text(
                        'Post',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color:
                              _selectedIndex == 0 ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _onItemTapped(2);
                      },
                      child: Text(
                        'Reels',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color:
                              _selectedIndex == 1 ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
