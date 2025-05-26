import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instgram_clone/service/firebase_auth.dart';
import 'package:instgram_clone/views/screens/login.dart';
import 'package:instgram_clone/views/widgets/textfield.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  File? file;
  final TextEditingController name = TextEditingController();
  final TextEditingController bio = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmpassword = TextEditingController();
  final FocusNode nameF = FocusNode();
  final FocusNode bioF = FocusNode();
  final FocusNode emailF = FocusNode();
  final FocusNode passwordF = FocusNode();
  final FocusNode confirmpasswordF = FocusNode();

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    name.dispose();
    bio.dispose();
    email.dispose();
    password.dispose();
    confirmpassword.dispose();
    nameF.dispose();
    bioF.dispose();
    emailF.dispose();
    passwordF.dispose();
    confirmpasswordF.dispose();
    super.dispose();
  }

  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();

    // Show a dialog to choose image source
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

    // If the user cancels the dialog, return early
    if (source == null) return;

    // Pick the image
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        file = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(10).w,
            child: ListView(
              children: [
                const SizedBox(
                    // height: 100,s
                    ),
                isDarkMode
                    ? Image.asset(
                        'assets/images/igdartmoood.jpg',
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.contain,
                      )
                    : Image.asset(
                        'assets/images/iglightmoood.jpg',
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.contain,
                      ),
                SizedBox(
                  height: 10.h,
                ),
                InkWell(
                  onTap: () async {
                    await getImage();
                  },
                  child: CircleAvatar(
                      radius: 36,
                      child: file != null
                          ? CircleAvatar(
                              radius: 34,
                              backgroundImage: Image.file(
                                file!,
                                fit: BoxFit.cover,
                              ).image,
                              backgroundColor: Colors.grey.shade200,
                            )
                          : CircleAvatar(
                              radius: 34,
                              backgroundImage:
                                  const AssetImage('images/person.png'),
                              backgroundColor: Colors.grey.shade200,
                            )),
                ),
                SizedBox(
                  height: 20.h,
                ),
                customtextfield(
                    isDarkMode: isDarkMode,
                    hintext: 'Name',
                    mycontroller: name,
                    focusNode: nameF,
                    obscuretext: false),
                SizedBox(
                  height: 10.h,
                ),
                customtextfield(
                    isDarkMode: isDarkMode,
                    hintext: 'Bio',
                    mycontroller: bio,
                    focusNode: bioF,
                    obscuretext: false),
                SizedBox(
                  height: 10.h,
                ),
                customtextfield(
                    isDarkMode: isDarkMode,
                    hintext: 'Email',
                    mycontroller: email,
                    focusNode: emailF,
                    obscuretext: false),
                SizedBox(
                  height: 10.h,
                ),
                customtextfield(
                    isDarkMode: isDarkMode,
                    hintext: "Password",
                    focusNode: passwordF,
                    mycontroller: password,
                    obscuretext: true),
                SizedBox(
                  height: 10.h,
                ),
                customtextfield(
                    isDarkMode: isDarkMode,
                    hintext: "Confirm Password",
                    mycontroller: confirmpassword,
                    focusNode: confirmpasswordF,
                    obscuretext: true),
                SizedBox(
                  height: 20.h,
                ),
                MaterialButton(
                  color: Colors.blue,
                  height: 40.h,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10).w),
                  onPressed: () async {
                    await Authentication().signup(
                        name: name.text,
                        email: email.text,
                        password: password.text,
                        confirmPassword: confirmpassword.text,
                        bio: bio.text,
                        profile: file ?? File(''));
                  },
                  child: const Text(
                    'signup',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('have an account?'),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const Login(),
                          ));
                        },
                        child: Text(
                          'login',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface),
                        ))
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
