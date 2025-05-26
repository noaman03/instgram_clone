import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instgram_clone/blocs/notification/notification_bloc.dart';
import 'package:instgram_clone/blocs/notification/notification_event.dart';
import 'package:instgram_clone/views/screens/login.dart';
import 'package:instgram_clone/views/widgets/navigation.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}

class _MainpageState extends State<Mainpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Initialize notification bloc when user is logged in
            BlocProvider.of<NotificationBloc>(context).add(GetUnreadCount());
            return const MyNavigation();
          } else {
            return const Login();
          }
        },
      ),
    );
  }
}
