import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/blocs/chat/chat_bloc.dart';
import 'package:instgram_clone/blocs/chat/chat_event.dart';
import 'package:instgram_clone/blocs/chat/chat_state.dart';
import 'package:instgram_clone/views/screens/ChatScreen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController searchController = TextEditingController();
  bool showSearchResults = false;

  @override
  void initState() {
    super.initState();
    // Load chats when screen initializes
    BlocProvider.of<ChatBloc>(context).add(LoadChats());
  }

  @override
  void dispose() {
    // Properly dispose controllers to prevent memory leaks
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('users')
                  .doc(_auth.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Text(
                    'Loading...',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 20.sp),
                  );
                }
                final userData = snapshot.data!.data() as Map<String, dynamic>?;
                return Text(
                  userData?['username'] ?? 'No Name',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 20.sp),
                );
              },
            ),
            const Icon(Icons.keyboard_arrow_down)
          ],
        ),
        actions: [
          // Add a new message button
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Show modal for creating new messages
              // This would typically open a user search screen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    showSearchResults = value.isNotEmpty;
                  });
                  if (value.isNotEmpty) {
                    BlocProvider.of<ChatBloc>(context).add(SearchUsers(value));
                  } else {
                    BlocProvider.of<ChatBloc>(context).add(LoadChats());
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatError) {
                  return Center(child: Text('Error: ${state.message}'));
                }

                if (state is UsersLoaded && showSearchResults) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: state.users,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No users found.'));
                      }
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final user = snapshot.data!.docs[index];
                          // Skip current user in search results
                          if (user.id == _auth.currentUser!.uid) {
                            return const SizedBox();
                          }

                          final userData = user.data() as Map<String, dynamic>;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(userData['profile'] ?? ''),
                              backgroundColor: Colors.grey.shade300,
                            ),
                            title: Text(userData['username'] ?? 'No Name'),
                            subtitle: Text(userData['bio'] ?? '',
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    receiverId: user.id,
                                    receiverUsername:
                                        userData['username'] ?? 'No Name',
                                    receiverProfile: userData['profile'] ?? '',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                }

                if (state is ChatRoomsLoaded) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: state.chatRooms,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Start a conversation by searching for users',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final chatDoc = snapshot.data!.docs[index];
                          final chatData =
                              chatDoc.data() as Map<String, dynamic>;

                          // Handle potential missing fields safely
                          final List<dynamic> participants =
                              chatData['participants'] ?? [];
                          final Map<String, dynamic> users =
                              chatData['users'] ?? {};

                          // Skip if data structure is not as expected
                          if (participants.length < 2 || users.isEmpty) {
                            return const SizedBox();
                          }

                          // Find the other user in the chat
                          String? otherUserId;
                          for (var participant in participants) {
                            if (participant != _auth.currentUser!.uid) {
                              otherUserId = participant;
                              break;
                            }
                          }

                          // Skip if can't determine other user
                          if (otherUserId == null ||
                              !users.containsKey(otherUserId)) {
                            return const SizedBox();
                          }

                          final otherUser =
                              users[otherUserId] as Map<String, dynamic>;
                          final bool hasUnread = chatData['unreadBy'] != null &&
                              (chatData['unreadBy'] as List<dynamic>)
                                  .contains(_auth.currentUser!.uid);

                          return ListTile(
                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(otherUser['profile'] ?? ''),
                                  backgroundColor: Colors.grey.shade300,
                                ),
                                // Online indicator could be added here
                              ],
                            ),
                            title: Text(
                              otherUser['username'] ?? 'No Name',
                              style: TextStyle(
                                fontWeight: hasUnread
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              chatData['lastMessage'] ?? 'No messages yet',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: hasUnread
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                                color: hasUnread
                                    ? (isDarkMode
                                        ? Colors.white
                                        : Colors.black87)
                                    : Colors.grey,
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                chatData['lastMessageTime'] != null
                                    ? Text(
                                        _formatTimestamp(
                                            chatData['lastMessageTime']),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: hasUnread
                                              ? Colors.blue
                                              : Colors.grey,
                                          fontWeight: hasUnread
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      )
                                    : const SizedBox(),
                                const SizedBox(height: 4),
                                if (hasUnread)
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue,
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    receiverId: otherUserId!,
                                    receiverUsername:
                                        otherUser['username'] ?? 'No Name',
                                    receiverProfile: otherUser['profile'] ?? '',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                }

                // Default state - show empty container
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final DateTime now = DateTime.now();
    final DateTime messageTime = timestamp.toDate();

    if (now.difference(messageTime).inDays == 0) {
      // Today, show time
      final String hour = messageTime.hour.toString().padLeft(2, '0');
      final String minute = messageTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (now.difference(messageTime).inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (now.difference(messageTime).inDays < 7) {
      // Within a week, show day name
      final List<String> days = [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun'
      ];
      return days[messageTime.weekday - 1];
    } else {
      // Show date
      final String day = messageTime.day.toString().padLeft(2, '0');
      final String month = messageTime.month.toString().padLeft(2, '0');
      return '$day/$month';
    }
  }
}
