import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/views/screens/complete_add_reels.dart';
import 'package:photo_manager/photo_manager.dart';

class AddReelsscreen extends StatefulWidget {
  const AddReelsscreen({super.key});

  @override
  State<AddReelsscreen> createState() => _AddReelsscreenState();
}

class _AddReelsscreenState extends State<AddReelsscreen> {
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
          await PhotoManager.getAssetPathList(type: RequestType.video);
      List<AssetEntity> media =
          await albums[0].getAssetListPaged(page: 0, size: 60);
      for (var asset in media) {
        if (asset.type == AssetType.video) {
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
                    child: Stack(
                      children: [
                        Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          width: double.infinity.w,
                          height: double.infinity.h,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0).w,
                            child: Text(
                              _formatDuration(asset.videoDuration),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Container(color: Colors.grey);
              },
            ));
          }
        }
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  String _formatDuration(Duration duration) {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  int indexx = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          'New reel',
          style: TextStyle(fontSize: 15),
        ),
        elevation: 0,
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: _medialist.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 3,
                  mainAxisSpacing: 4,
                  mainAxisExtent: 250),
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      setState(() {
                        indexx = index;
                        _file = path[index];
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CompleteAddReels(_file!),
                        ));
                      });
                    },
                    child: _medialist[index]);
              },
            ),
          )
        ],
      )),
    );
  }
}
