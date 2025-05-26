import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/util/functions/image_cache.dart';

Widget comment_item(final snapshot, BuildContext context) {
  return ListTile(
    leading: ClipOval(
      child: SizedBox(
        height: 35.h,
        width: 35.w,
        child: cachedimage(
          snapshot['profileImage'],
        ),
      ),
    ),
    title: Text(
      snapshot['username'],
      style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface),
    ),
    subtitle: Text(
      snapshot['comment'],
      style: TextStyle(
          fontSize: 13.sp, color: Theme.of(context).colorScheme.onSurface),
    ),
  );
}
