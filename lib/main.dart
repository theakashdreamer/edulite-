import 'package:edulite/ui/auth/bloc/auth_bloc.dart';
import 'package:edulite/ui/auth/login_screen.dart';
import 'package:edulite/ui/auth/repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'bloc/chat_bloc.dart';
import 'email/inbox_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(context.read<AuthRepository>()),
          ),
          BlocProvider<ChatBloc>(
            create: (_) => ChatBloc(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Edulite',

          /// ✅ REQUIRED for flutter_quill 11
          localizationsDelegates: const [
            FlutterQuillLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          /// ✅ REQUIRED
          supportedLocales: const [
            Locale('en'),
          ],

          theme: ThemeData(
            primaryColor: const Color(0xFF075E54),
            useMaterial3: true,
          ),

          home: InboxScreen(),
        ),
      ),
    );
  }
}
