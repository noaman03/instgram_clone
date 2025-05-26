import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instgram_clone/service/firestore.dart';
import 'package:instgram_clone/views/widgets/textfield.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File? file;
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await Firestore().getuser();
      setState(() {
        nameController.text = user.name;
        bioController.text = user.bio;
        file = File(user
            .profile); // Assuming the profile image path is stored in the user object
      });
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        file = File(pickedFile.path);
      });
    }
  }

  Future<void> saveProfile() async {
    try {
      await Firestore().createuser(
        name: nameController.text,
        email: FirebaseAuth.instance.currentUser!.email!,
        bio: bioController.text,
        profile: file?.path ?? "",
      );

      setState(() {});

      Navigator.pop(context);
    } catch (e) {
      print("Error saving profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Edit profile"),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10).w,
          child: ListView(
            children: [
              const SizedBox(height: 10),
              SizedBox(height: 10.h),
              InkWell(
                onTap: getImage,
                child: CircleAvatar(
                  radius: 36,
                  child: file != null
                      ? CircleAvatar(
                          radius: 34,
                          backgroundImage:
                              Image.file(file!, fit: BoxFit.cover).image,
                          backgroundColor: Colors.grey.shade200,
                        )
                      : CircleAvatar(
                          radius: 34,
                          backgroundImage:
                              const AssetImage('images/person.png'),
                          backgroundColor: Colors.grey.shade200,
                        ),
                ),
              ),
              SizedBox(height: 20.h),
              customtextfield(
                isDarkMode: isDarkMode,
                hintext: 'Name',
                mycontroller: nameController,
                focusNode: FocusNode(),
                obscuretext: false,
              ),
              SizedBox(height: 10.h),
              customtextfield(
                isDarkMode: isDarkMode,
                hintext: 'Bio',
                mycontroller: bioController,
                focusNode: FocusNode(),
                obscuretext: false,
              ),
              SizedBox(height: 20.h),
              MaterialButton(
                color: Colors.blue,
                height: 40.h,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10).w,
                ),
                onPressed: saveProfile,
                child: const Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
