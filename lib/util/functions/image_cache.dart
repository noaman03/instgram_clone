import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class cachedimage extends StatelessWidget {
  String? imageURL;
  cachedimage(this.imageURL, {super.key});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: imageURL!,
      progressIndicatorBuilder: (context, url, progress) {
        return Container(
          child: Padding(
            padding: const EdgeInsets.all(110),
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  value: progress.progress,
                  color: Colors.grey,
                  strokeWidth: 3.0),
            ),
          ),
        );
      },
      errorWidget: (context, url, error) => Container(
        color: Colors.amber,
      ),
    );
  }
}
