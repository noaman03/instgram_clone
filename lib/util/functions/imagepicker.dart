// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class Imagepicker {
//   final ImagePicker _picker = ImagePicker();

//   Future<File?> uploadfile(BuildContext context) async {
//     try {
//       ImageSource? source = await _showPickerDialog(context);
//       if (source == null) return null;
//       final XFile? pickedImage = await _picker.pickImage(source: source);
//       if (pickedImage == null) return null;
//       return File(pickedImage.path);
//     } catch (e) {
//       print("Error picking image: $e");
//       return null;
//     }
//   }

//   Future<ImageSource?> _showPickerDialog(BuildContext context) async {
//     return showDialog<ImageSource>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Select Image Source'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.photo_library),
//                 title: const Text('Gallery'),
//                 onTap: () {
//                   Navigator.of(context).pop(ImageSource.gallery);
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.camera_alt),
//                 title: const Text('Camera'),
//                 onTap: () {
//                   Navigator.of(context).pop(ImageSource.camera);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }


