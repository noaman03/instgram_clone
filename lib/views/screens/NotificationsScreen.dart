import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/blocs/notification/notification_bloc.dart';
import 'package:instgram_clone/blocs/notification/notification_event.dart';
import 'package:instgram_clone/blocs/notification/notification_state.dart';
import 'package:instgram_clone/views/screens/profile.dart';
import 'package:instgram_clone/views/screens/view_post.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications when screen initializes
    context.read<NotificationBloc>().add(LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: () {
              context
                  .read<NotificationBloc>()
                  .add(MarkAllNotificationsAsRead());
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is NotificationsLoaded) {
            return StreamBuilder<QuerySnapshot>(
              stream: state.notifications,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No notifications yet.'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final notification = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;

                    return _buildNotificationItem(
                      context,
                      notification,
                      notificationId: snapshot.data!.docs[index].id,
                    );
                  },
                );
              },
            );
          }

          return const Center(child: Text('No notifications'));
        },
      ),
    );
  }

  Widget _buildNotificationItem(
      BuildContext context, Map<String, dynamic> notification,
      {required String notificationId}) {
    final bool isRead = notification['isRead'] ?? false;
    final String type = notification['type'];
    final Timestamp timestamp = notification['timestamp'] ?? Timestamp.now();

    String message;
    IconData icon;
    Color iconColor;

    switch (type) {
      case 'like':
        message = 'liked your post.';
        icon = Icons.favorite;
        iconColor = Colors.red;
        break;
      case 'comment':
        message =
            'commented on your post: "${notification['commentText'] ?? ''}"';
        icon = Icons.comment;
        iconColor = Colors.blue;
        break;
      case 'follow':
        message = 'started following you.';
        icon = Icons.person_add;
        iconColor = Colors.green;
        break;
      default:
        message = 'interacted with you.';
        icon = Icons.notifications;
        iconColor = Colors.orange;
    }

    return GestureDetector(
      onTap: () {
        // Mark as read first
        context
            .read<NotificationBloc>()
            .add(MarkNotificationAsRead(notificationId));

        // Then navigate based on notification type
        if (type == 'follow') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Profile(uid: notification['senderId']),
            ),
          );
        } else if (type == 'like' || type == 'comment') {
          if (notification['postId'] != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewPost(postId: notification['postId']),
              ),
            );
          }
        }
      },
      child: Container(
        color: isRead ? null : Colors.blue.withOpacity(0.1),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundImage: NetworkImage(notification['senderProfileImg']),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      children: [
                        TextSpan(
                          text: notification['senderUsername'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' $message'),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    timeago.format(timestamp.toDate()),
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            if (notification['postImg'] != null)
              SizedBox(
                width: 40.w,
                height: 40.h,
                child: Image.network(
                  notification['postImg'],
                  fit: BoxFit.cover,
                ),
              )
            else
              Icon(icon, color: iconColor),
          ],
        ),
      ),
    );
  }
}
