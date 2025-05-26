import 'package:flutter/material.dart';

class customtextfield extends StatelessWidget {
  final String hintext;
  final TextEditingController mycontroller;
  final FocusNode focusNode;
  final bool obscuretext;
  final bool isDarkMode;

  const customtextfield(
      {super.key,
      required this.isDarkMode,
      required this.hintext,
      required this.mycontroller,
      required this.obscuretext,
      required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: mycontroller,
      focusNode: focusNode,
      obscureText: obscuretext,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        hintText: hintext,
        filled: true,
        fillColor: isDarkMode
            ? const Color.fromRGBO(239, 239, 239, 0.2)
            : Colors.grey.shade300,
      ),
    );
  }
}
