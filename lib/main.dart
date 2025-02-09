import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:TriDot/HomeScreens/splash.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TriDotMessenger());
}

class TriDotMessenger extends StatefulWidget {
  const TriDotMessenger({super.key});

  @override
  State<TriDotMessenger> createState() => _TriDotMessengerState();
}

class _TriDotMessengerState extends State<TriDotMessenger> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              return Scaffold(
                body: Splash(snapshot: snapshot),
              );
            }));
  }
}
