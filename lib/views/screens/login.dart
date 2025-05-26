import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/service/firebase_auth.dart';
import 'package:instgram_clone/views/screens/signup.dart';
import 'package:instgram_clone/views/widgets/textfield.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  FocusNode email_F = FocusNode();
  TextEditingController password = TextEditingController();
  FocusNode password_F = FocusNode();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10).w,
          child: ListView(
            children: [
              SizedBox(
                height: 200.h,
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
                height: 20.h,
              ),
              customtextfield(
                isDarkMode: isDarkMode,
                hintext: "Email",
                mycontroller: email,
                focusNode: email_F,
                obscuretext: false,
              ),
              SizedBox(
                height: 20.h,
              ),
              customtextfield(
                isDarkMode: isDarkMode,
                hintext: "Password",
                mycontroller: password,
                focusNode: password_F,
                obscuretext: true,
              ),
              SizedBox(
                height: 50.h,
              ),
              MaterialButton(
                color: Colors.blue,
                height: 40.h,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10).w,
                ),
                onPressed: () async {
                  await Authentication().login(
                    email: email.text,
                    password: password.text,
                  );
                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Do not have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const Signup(),
                      ));
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
