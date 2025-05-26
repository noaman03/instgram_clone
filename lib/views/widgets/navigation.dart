import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instgram_clone/blocs/notification/notification_bloc.dart';
import 'package:instgram_clone/blocs/notification/notification_event.dart';
import 'package:instgram_clone/views/screens/add.dart';
import 'package:instgram_clone/views/screens/explore_screen.dart';
import 'package:instgram_clone/views/screens/homePage.dart';
import 'package:instgram_clone/views/screens/profile_screen.dart';
import 'package:instgram_clone/views/screens/reels_screen.dart';

class MyNavigation extends StatefulWidget {
  const MyNavigation({super.key});

  @override
  State<MyNavigation> createState() => _MyNavigationState();
}

class _MyNavigationState extends State<MyNavigation> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const Homepage(),
      const ExploreScreen(),
      const addpage(),
      const ReelsScreen(),
      ProfileScreen(
        Uid: _auth.currentUser!.uid,
      ),
    ];
    // Still initialize notifications for the home page icon
    context.read<NotificationBloc>().add(GetUnreadCount());
  }

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
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.onSurface,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_box_outlined,
              size: 30,
            ),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_creation_outlined),
            label: 'Reels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
