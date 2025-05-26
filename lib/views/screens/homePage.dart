import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:instgram_clone/blocs/notification/notification_bloc.dart';
import 'package:instgram_clone/blocs/notification/notification_event.dart';
import 'package:instgram_clone/blocs/notification/notification_state.dart';

import 'package:instgram_clone/views/screens/ChatList_Screen.dart';
import 'package:instgram_clone/views/screens/NotificationsScreen.dart';
import 'package:instgram_clone/views/widgets/StoriesScreen.dart';
import 'package:instgram_clone/views/widgets/instgram_post.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // Used for direct Firestore access - should move to a repository pattern eventually
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Controls the pull-to-refresh functionality
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  // Track if we're in the initial load state
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();

    // Load notifications when the screen initializes
    context.read<NotificationBloc>().add(GetUnreadCount());

    // This should be moved to bloc eventually
    _loadPosts();
  }

  // Clean up controllers when done
  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  // Handle refresh logic - should be moved to bloc later
  void _onRefresh() async {
    // Refresh posts data
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();

    // TODO: When implementing BLoC properly, this would be:
    // context.read<PostBloc>().add(RefreshPosts());
  }

  // Initial post loading
  void _loadPosts() {
    // TODO: Replace direct Firestore access with BLoC call:
    // context.read<PostBloc>().add(LoadPosts());

    setState(() {
      _isFirstLoad = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Using the system theme for dynamic light/dark mode
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildAppBar(isDarkMode),
      body: _buildBody(),
    );
  }

  // Extracted app bar to make the build method cleaner
  AppBar _buildAppBar(bool isDarkMode) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Just swapping logo based on theme - should use SVG instead for better quality
          isDarkMode
              ? Image.asset(
                  'assets/images/instagram text logo.png',
                  width: 110.w,
                  height: 110.h,
                  fit: BoxFit.contain,
                )
              : Image.asset(
                  'assets/images/logo.jpg',
                  width: 110.w,
                  height: 110.h,
                  fit: BoxFit.contain,
                )
        ],
      ),
      actions: [
        // Notifications bell with badge - handle notification count with BLoC
        _buildNotificationButton(),

        // Messages/chat button
        IconButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ChatListScreen()));
          },
          icon: SizedBox(
              width: 20.w,
              height: 20.h,
              child: Image.asset(
                'assets/images/messenger.png',
                color: Theme.of(context).colorScheme.onSurface,
              )),
        ),
      ],
    );
  }

  // Notification button with badge extracted to separate method
  Widget _buildNotificationButton() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is UnreadCountLoaded) {
          return StreamBuilder<int>(
            stream: state.unreadCount,
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.favorite_border),
                    color: Theme.of(context).colorScheme.onSurface,
                    iconSize: 25,
                  ),
                  // Only show badge if we have unread notifications
                  if (count > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          count > 9 ? '9+' : count.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        }

        // Default icon when notification state isn't loaded yet
        return IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
          icon: const Icon(Icons.favorite_border),
          color: Theme.of(context).colorScheme.onSurface,
          iconSize: 25,
        );
      },
    );
  }

  // Main body content
  Widget _buildBody() {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      header: const WaterDropHeader(),
      child: Column(
        children: [
          // Stories carousel at the top
          StoriesScreen(),

          // Divider to separate stories from posts
          Divider(
              height: 1, thickness: 0.5, color: Colors.grey.withOpacity(0.3)),

          // Posts list - takes remaining space
          Expanded(
            child: _buildPostsList(),
          ),
        ],
      ),
    );
  }

  // Posts list with loading, empty, and error states handled
  Widget _buildPostsList() {
    // Not using BLoC yet, but here's how to structure it with Firebase directly
    return StreamBuilder(
      stream: _firebaseFirestore
          .collection('post')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        // Loading state
        if (_isFirstLoad || !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Something went wrong: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadPosts,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // Empty state
        final posts = snapshot.data!.docs;
        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/no_posts.png',
                  width: 120.w,
                  height: 120.w,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No posts yet',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Follow some accounts to see posts',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        // Posts list
        return ListView.builder(
          // Getting rid of the weird top padding
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            // Handle post rendering and user interaction
            final postData = posts[index].data();
            return InstagramPost(postData);
          },
        );
      },
    );
  }
}
