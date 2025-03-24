import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'flood_page.dart';
import 'selection.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      routes: {
        '/home': (context) => HomePage(),
        '/flood': (context) => FloodScreen(),
        '/selection': (context) => SelectionPage(),
      },
    );
  }
}
