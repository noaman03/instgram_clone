import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instgram_clone/blocs/chat/chat_bloc.dart';
import 'package:instgram_clone/blocs/chat/chat_event.dart';
import 'package:instgram_clone/blocs/chat/chat_state.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverUsername;
  final String receiverProfile;

  const ChatScreen({
    required this.receiverId,
    required this.receiverUsername,
    required this.receiverProfile,
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load messages when screen initializes
    BlocProvider.of<ChatBloc>(context).add(LoadMessages(widget.receiverId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      BlocProvider.of<ChatBloc>(context).add(
        SendMessage(
          receiverId: widget.receiverId,
          message: _messageController.text,
        ),
      );
      _messageController.clear();

      // Scroll to bottom after sending message
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.receiverProfile),
              radius: 16,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.receiverUsername,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_outlined),
            onPressed: () {
              // Implement call functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {
              // Implement video call functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatError) {
                  return Center(child: Text('Error: ${state.message}'));
                }

                if (state is MessagesLoaded) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: state.messages,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!.docs;

                      if (messages.isEmpty) {
                        return const Center(
                          child: Text(
                            'No messages yet. Send a message to start chatting!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: messages.length,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemBuilder: (context, index) {
                          final message =
                              messages[index].data() as Map<String, dynamic>;
                          bool isMe = message['senderId'] ==
                              BlocProvider.of<ChatBloc>(context).currentUserId;

                          // Check if we have a timestamp, default to now if missing
                          Timestamp timestamp =
                              message['timestamp'] ?? Timestamp.now();
                          String timeString = formatDate(
                            timestamp.toDate(),
                            [h, ":", mm, " ", am],
                          );

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                    top: 5,
                                    bottom: 2,
                                    left: isMe ? 80 : 10,
                                    right: isMe ? 10 : 80,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Colors.blue
                                        : isDarkMode
                                            ? Colors.grey.shade700
                                            : Colors.grey.shade200,
                                    borderRadius:
                                        BorderRadius.circular(16).copyWith(
                                      bottomLeft: isMe
                                          ? const Radius.circular(16)
                                          : const Radius.circular(4),
                                      bottomRight: isMe
                                          ? const Radius.circular(4)
                                          : const Radius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    message['text'] ?? '',
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white
                                          : isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: isMe ? 0 : 12,
                                    right: isMe ? 12 : 0,
                                    bottom: 8,
                                  ),
                                  child: Text(
                                    timeString,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, -1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_outlined),
                  onPressed: () {
                    // Implement image sending
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDarkMode
                          ? const Color(0xFF1D1E20)
                          : const Color(0xffF0F0F0),
                      hintText: 'Message...',
                      hintStyle: TextStyle(
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 5,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.blue,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
