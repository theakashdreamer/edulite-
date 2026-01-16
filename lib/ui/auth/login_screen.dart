import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/chat_bloc.dart';
import '../../bloc/chat_event.dart';
import '../chat_page.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final mobileCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              // 🔥 YAHI MAIN INTEGRATION HAI
              context.read<ChatBloc>().add(
                ConnectEvent(state.user.userId),
              );

              // 🔥 DIRECT CHAT PAGE OPEN
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ChatPage()),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Name",
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mobileCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Mobile Number",
                  ),
                ),
                const SizedBox(height: 24),

                if (state is AuthLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        LoginEvent(
                          mobileCtrl.text.trim(),
                          nameCtrl.text.trim(),
                        ),
                      );
                    },
                    child: const Text("LOGIN"),
                  ),

                if (state is AuthFailure)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      state.error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
              ],
            );
          },
        ),
      ),
    );
  }
}
