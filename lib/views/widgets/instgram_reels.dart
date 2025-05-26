import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/service/firestore.dart';
import 'package:instgram_clone/util/functions/image_cache.dart';
import 'package:instgram_clone/views/screens/profile.dart';
import 'package:instgram_clone/views/widgets/comment.dart';
import 'package:instgram_clone/views/widgets/like_animation.dart';
import 'package:video_player/video_player.dart';

class InstgramReels extends StatefulWidget {
  final dynamic snapshot;
  final bool isActive;

  const InstgramReels(this.snapshot, {super.key, this.isActive = true});

  @override
  State<InstgramReels> createState() => _InstgramReelsState();
}

class _InstgramReelsState extends State<InstgramReels>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController controller;
  bool play = true;
  bool isAnimating = false;
  bool isInitialized = false;
  bool isMuted = false;
  bool showVolumeIndicator = false;
  bool isBuffering = false;
  bool hasError = false;
  String errorMessage = '';
  String user = '';

  // Animation controller for volume indicator
  late AnimationController _volumeIndicatorController;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for volume indicator
    _volumeIndicatorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Get current user ID
    user = FirebaseAuth.instance.currentUser?.uid ?? '';
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    setState(() {
      isBuffering = true;
      hasError = false;
    });

    try {
      final videoUrl = widget.snapshot['reelvideo'];
      if (videoUrl == null || videoUrl.isEmpty) {
        setState(() {
          hasError = true;
          errorMessage = 'Video URL is missing';
          isBuffering = false;
        });
        return;
      }

      controller = VideoPlayerController.network(videoUrl);

      // Add a listener to track buffering state
      controller.addListener(_videoListener);

      await controller.initialize();
      if (mounted) {
        setState(() {
          isInitialized = true;
          isBuffering = false;
          controller.setLooping(true);

          // Only play if this reel is active
          if (widget.isActive) {
            controller.play();
            play = true;
          } else {
            controller.pause();
            play = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hasError = true;
          errorMessage = 'Failed to load video';
          isBuffering = false;
        });
      }
      debugPrint('Error initializing video: $e');
    }
  }

  void _videoListener() {
    if (!mounted) return;

    final newBuffering = controller.value.isBuffering;
    if (isBuffering != newBuffering) {
      setState(() {
        isBuffering = newBuffering;
      });
    }
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
      controller.setVolume(isMuted ? 0.0 : 1.0);
      showVolumeIndicator = true;
    });

    // Show volume indicator briefly
    _volumeIndicatorController.forward(from: 0.0).then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            showVolumeIndicator = false;
          });
        }
      });
    });
  }

  @override
  void didUpdateWidget(InstgramReels oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Control video playback based on active state
    if (oldWidget.isActive != widget.isActive && isInitialized && !hasError) {
      if (widget.isActive) {
        controller.play();
        if (mounted) {
          setState(() {
            play = true;
          });
        }
      } else {
        controller.pause();
        if (mounted) {
          setState(() {
            play = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    if (isInitialized) {
      controller.removeListener(_videoListener);
      controller.dispose();
    }
    _volumeIndicatorController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (!isInitialized || hasError) return;

    setState(() {
      play = !play;
    });

    if (play) {
      controller.play();
    } else {
      controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video player with gesture detection
        GestureDetector(
          onDoubleTap: () {
            if (user.isEmpty) return;

            Firestore().like(
                like: widget.snapshot['like'] ?? [],
                type: 'reel',
                uid: user,
                postId: widget.snapshot['postId'] ?? '');
            setState(() {
              isAnimating = true;
            });
          },
          onTap: _togglePlayPause,
          onLongPress: _toggleMute,
          child: Container(
            color: Colors.black,
            child: hasError
                ? _buildErrorView()
                : !isInitialized
                    ? _buildLoadingView()
                    : Stack(
                        children: [
                          Center(
                            child: AspectRatio(
                              aspectRatio: controller.value.aspectRatio,
                              child: VideoPlayer(controller),
                            ),
                          ),
                          if (isBuffering)
                            const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
          ),
        ),

        // Video progress indicator
        if (isInitialized && !hasError)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Colors.white,
                bufferedColor: Colors.white30,
                backgroundColor: Colors.black45,
              ),
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            ),
          ),

        // Play/pause icon overlay
        if (!play && isInitialized && !hasError)
          Center(
            child: Container(
              width: 70.r,
              height: 70.r,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow,
                size: 40.r,
                color: Colors.white,
              ),
            ),
          ),

        // Volume indicator
        if (showVolumeIndicator && isInitialized && !hasError)
          Center(
            child: AnimatedOpacity(
              opacity: showVolumeIndicator ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 30.r,
                ),
              ),
            ),
          ),

        // Like animation
        Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isAnimating ? 1 : 0,
            child: LikeAnimation(
              isAnimating: isAnimating,
              duration: const Duration(milliseconds: 400),
              iconlike: false,
              End: () {
                setState(() {
                  isAnimating = false;
                });
              },
              child: Icon(
                Icons.favorite,
                size: 100.r,
                color: Colors.red,
              ),
            ),
          ),
        ),

        // Top gradient for better readability
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 100.h,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Bottom gradient for better readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 150.h,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Side action buttons (like, comment, share)
        Positioned(
          bottom: 150.h,
          right: 15.w,
          child: Column(
            children: [
              // Like button
              _buildInteractionButton(
                icon: widget.snapshot['like']?.contains(user) ?? false
                    ? Icons.favorite
                    : Icons.favorite_border,
                count: (widget.snapshot['like']?.length ?? 0).toString(),
                color: widget.snapshot['like']?.contains(user) ?? false
                    ? Colors.red
                    : Colors.white,
                onTap: () async {
                  if (user.isEmpty) return;

                  final updatedLikes = await Firestore().like(
                      like: widget.snapshot['like'] ?? [],
                      type: 'reel',
                      uid: user,
                      postId: widget.snapshot['postId'] ?? '');
                  if (mounted) {
                    setState(() {
                      widget.snapshot['like'] = updatedLikes;
                    });
                  }
                },
                isLiked: widget.snapshot['like']?.contains(user) ?? false,
              ),

              SizedBox(height: 20.h),

              // Comment button
              _buildInteractionButton(
                icon: Icons.comment,
                count: (widget.snapshot['comment']?.length ?? 0).toString(),
                onTap: () {
                  // Pause video when opening comments
                  if (isInitialized && play) {
                    controller.pause();
                    setState(() {
                      play = false;
                    });
                  }

                  showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    context: context,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: DraggableScrollableSheet(
                          maxChildSize: 0.75,
                          initialChildSize: 0.6,
                          minChildSize: 0.2,
                          builder: (context, scrollController) {
                            return Comment(
                              widget.snapshot['postId'] ?? '',
                              'reel',
                            );
                          },
                        ),
                      );
                    },
                  ).then((_) {
                    // Resume video when closing comments if it was playing before
                    if (isInitialized && widget.isActive && !play) {
                      controller.play();
                      setState(() {
                        play = true;
                      });
                    }
                  });
                },
              ),

              SizedBox(height: 20.h),

              // Share button
              _buildInteractionButton(
                icon: Icons.send,
                count: '',
                onTap: () {
                  // Share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sharing coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              SizedBox(height: 20.h),

              // Volume button
              GestureDetector(
                onTap: _toggleMute,
                child: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 28.r,
                ),
              ),
            ],
          ),
        ),

        // User info and caption at bottom
        Positioned(
          bottom: 50.h,
          left: 10.w,
          right: 80.w, // Make room for side buttons
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Username and follow button
              GestureDetector(
                onTap: () {
                  // Pause video when navigating
                  if (isInitialized && play) {
                    controller.pause();
                  }

                  // Navigate to profile
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          Profile(uid: widget.snapshot['uid'] ?? ''),
                    ),
                  );
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: 36.r,
                      height: 36.r,
                      child: ClipOval(
                        child:
                            cachedimage(widget.snapshot['profileImage'] ?? ''),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        widget.snapshot['username'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    _buildFollowButton(),
                  ],
                ),
              ),

              // Caption
              if ((widget.snapshot['caption'] ?? '').isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 10.h, left: 5.w, right: 5.w),
                  child: Text(
                    widget.snapshot['caption'] ?? '',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // Audio info
              Padding(
                padding: EdgeInsets.only(top: 8.h, left: 5.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 15.r,
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Text(
                        widget.snapshot['audioName'] ?? 'Original Audio',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 50.r,
            ),
            SizedBox(height: 16.h),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _initializeVideoPlayer,
              child: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
            ),
            SizedBox(height: 16.h),
            Text(
              'Loading reel...',
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String count,
    required VoidCallback onTap,
    Color color = Colors.white,
    bool isLiked = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: isLiked
              ? LikeAnimation(
                  isAnimating: true,
                  child: Icon(
                    icon,
                    color: color,
                    size: 30.r,
                  ),
                )
              : Icon(
                  icon,
                  color: color,
                  size: 30.r,
                ),
        ),
        if (count.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFollowButton() {
    // Skip follow button if it's the current user
    if (widget.snapshot['uid'] == user) {
      return SizedBox();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        'Follow',
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
