import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/views/screens/complete_add_post.dart';
import 'package:photo_manager/photo_manager.dart';

class AddPostscreen extends StatefulWidget {
  const AddPostscreen({super.key});

  @override
  State<AddPostscreen> createState() => _AddPostscreenState();
}

class _AddPostscreenState extends State<AddPostscreen> {
  final List<Widget> _medialist = [];
  final List<File> path = [];
  File? _file;

  @override
  void initState() {
    super.initState();
    _fetchNewMedia();
  }

  Future<void> _fetchNewMedia() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(onlyAll: true);
      List<AssetEntity> media =
          await albums[0].getAssetListPaged(page: 0, size: 60);
      for (var asset in media) {
        if (asset.type == AssetType.image) {
          final file = await asset.file;
          if (file != null) {
            path.add(File(file.path));
            _medialist.add(FutureBuilder(
              future:
                  asset.thumbnailDataWithSize(const ThumbnailSize(200, 200)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                return Container(color: Colors.grey);
              },
            ));
          }
        }
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'New Post',
          style: TextStyle(fontSize: 15),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10).r,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CompleteAddPost(_file!),
                ));
              },
              child: const Text(
                'Next',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 375.h,
              child: _file != null
                  ? Image.file(
                      _file!,
                      fit: BoxFit.cover,
                    )
                  : const Center(child: Text('Select an image')),
            ),
            Container(
              width: double.infinity.w,
              height: 40.h,
              color: Colors.white,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0).w,
                    child: const Text(
                      'Recent',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _medialist.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 1,
                crossAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _file = path[index];
                    });
                  },
                  child: _medialist[index],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
