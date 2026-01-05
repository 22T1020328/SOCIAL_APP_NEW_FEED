import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:socail/firebase_options.dart';
import 'package:socail/pages/my_app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
  }
  
  runApp(const MyApp());
}



