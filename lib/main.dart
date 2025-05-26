import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:instgram_clone/blocs/chat/chat_bloc.dart';
import 'package:instgram_clone/blocs/user/user_bloc.dart';
import 'package:instgram_clone/blocs/post/post_bloc.dart';
import 'package:instgram_clone/blocs/reel/reel_bloc.dart';
import 'package:instgram_clone/blocs/story/story_bloc.dart';
import 'package:instgram_clone/blocs/interaction/interaction_bloc.dart';
import 'package:instgram_clone/blocs/notification/notification_bloc.dart';
import 'package:instgram_clone/generated/l10n.dart';
import 'package:instgram_clone/util/constants/theme.dart';
import 'package:instgram_clone/util/functions/theme_provider.dart';
import 'package:instgram_clone/views/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:instgram_clone/service/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Initialize push notifications
  final pushNotificationService = PushNotificationService();
  await pushNotificationService.initialize();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(),
        ),
        BlocProvider<PostBloc>(
          create: (context) => PostBloc(),
        ),
        BlocProvider<ReelBloc>(
          create: (context) => ReelBloc(),
        ),
        BlocProvider<StoryBloc>(
          create: (context) => StoryBloc(),
        ),
        BlocProvider<InteractionBloc>(
          create: (context) => InteractionBloc(),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => ChatBloc(),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(),
        ),
      ],
      child: ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: const MyApp(),
      ),
    ),
  );
}

class DefaultFirebaseOptions {}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: const ScreenUtilInit(
          designSize: Size(375, 812), child: SplashScreen()),
      theme: Provider.of<ThemeProvider>(context).themeData,
      darkTheme: darkmode,
    );
  }
}
