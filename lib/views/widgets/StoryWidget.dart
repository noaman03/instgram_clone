import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoryWidget extends StatelessWidget {
  final Map<String, dynamic> stories;

  const StoryWidget({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    List<dynamic> otherUsersStories = stories['others'];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: otherUsersStories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Current user's story
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoryDetailScreen(
                      stories: [stories['currentUser']],
                      currentIndex: 0,
                    ),
                  ),
                );
              },
              child: StoryCircle(
                name: stories['currentUser']['username'],
                imageUrl: stories['currentUser']['profileImage'],
                isCurrentUser: true,
              ),
            );
          }
          // Other users' stories
          final story = otherUsersStories[index - 1];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StoryDetailScreen(
                    stories: otherUsersStories,
                    currentIndex: index - 1,
                  ),
                ),
              );
            },
            child: StoryCircle(
              name: story['username'],
              imageUrl: story['profileImage'],
            ),
          );
        },
      ),
    );
  }
}

class StoryCircle extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool isCurrentUser;

  const StoryCircle({
    super.key,
    required this.name,
    required this.imageUrl,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrentUser ? Colors.blue : Colors.purple,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: CircleAvatar(
                    radius: 27,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                ),
              ),
              if (isCurrentUser)
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.add,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class StoryDetailScreen extends StatefulWidget {
  final List<dynamic> stories;
  final int currentIndex;

  const StoryDetailScreen(
      {super.key, required this.stories, required this.currentIndex});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen>
    with SingleTickerProviderStateMixin {
  late int currentIndex;
  late List<dynamic> stories;
  late PageController _pageController;
  late AnimationController _animationController;
  // ignore: unused_field
  late Animation<double> _progressAnimation;
  Timer? _timer;
  bool _isPaused = false;

  final int _storyDuration = 5; // Duration in seconds

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
    stories = widget.stories;
    _pageController = PageController(initialPage: currentIndex);

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _storyDuration),
    );

    _progressAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_animationController)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _nextStory();
            }
          });

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _nextStory() {
    if (currentIndex < stories.length - 1) {
      setState(() {
        currentIndex++;
        _pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      // Close the screen after completing all stories
      Navigator.pop(context);
    }
  }

  void _previousStory() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _animationController.stop();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          final tapPosition = details.globalPosition.dx;

          _togglePause();

          if (tapPosition < screenWidth / 3) {
            // Left side tap - go to previous story
            _previousStory();
          } else if (tapPosition > (screenWidth * 2 / 3)) {
            // Right side tap - go to next story
            _nextStory();
          }
          // Center tap will just pause/resume
        },
        onLongPress: () {
          // Pause on long press
          if (!_isPaused) {
            _togglePause();
          }
        },
        onLongPressUp: () {
          // Resume on long press release
          if (_isPaused) {
            _togglePause();
          }
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 300) {
            Navigator.pop(
                context); // Close when swiped down with enough velocity
          }
        },
        child: Stack(
          children: [
            // Story content
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swiping
              itemCount: stories.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
                _animationController.reset();
                _animationController.forward();
              },
              itemBuilder: (context, index) {
                final story = stories[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: story['mediaUrl'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                    // Darken the image slightly for better text visibility
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Progress indicators at the top
            Positioned(
              top: 50,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(
                  stories.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: LinearPercentIndicator(
                        padding: EdgeInsets.zero,
                        lineHeight: 2.5,
                        percent: index < currentIndex
                            ? 1.0
                            : (index == currentIndex
                                ? _animationController.value
                                : 0.0),
                        progressColor: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        barRadius: const Radius.circular(5),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // User info
            Positioned(
              top: 60,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage:
                        NetworkImage(stories[currentIndex]['profileImage']),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      stories[currentIndex]['username'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Bottom input field and actions
            Positioned(
              bottom: 20,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText:
                            "Reply to ${stories[currentIndex]['username']}...",
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.black45,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        // Pause when user is typing
                        if (!_isPaused) {
                          _togglePause();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      // Handle like action
                    },
                  ),
                ],
              ),
            ),

            // If paused, show a pause indicator
            if (_isPaused)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.pause,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
