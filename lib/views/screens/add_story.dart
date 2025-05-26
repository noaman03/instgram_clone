import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instgram_clone/views/screens/complete_add_story.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isCameraInitialized = false;
  File? selectedMedia;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras != null && cameras!.isNotEmpty) {
      _cameraController =
          CameraController(cameras!.first, ResolutionPreset.high);
      await _cameraController!.initialize();
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 1080, maxWidth: 1920);

    if (pickedFile != null) {
      setState(() {
        selectedMedia = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          _isCameraInitialized && _cameraController != null
              ? CameraPreview(_cameraController!)
              : const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
          // Bottom Left Gallery Picker
          Positioned(
            bottom: 20,
            left: 20,
            child: InkWell(
              onTap: _pickFromGallery,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.8),
                ),
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  Icons.photo_library,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // Take Picture Button
          Positioned(
            bottom: 20,
            right: MediaQuery.of(context).size.width / 2 - 40,
            child: FloatingActionButton(
              onPressed: () async {
                if (_cameraController != null &&
                    _cameraController!.value.isInitialized) {
                  final XFile file = await _cameraController!.takePicture();
                  setState(() {
                    selectedMedia = File(file.path);
                  });
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompleteAddStory(selectedMedia!),
                  ),
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.camera_alt,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
