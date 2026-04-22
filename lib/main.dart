import 'package:flutter/material.dart';

void main() {
  runApp(const SaveWiseApp());
}

class SaveWiseApp extends StatelessWidget {
  const SaveWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SaveWise',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SaveWise Dashboard"),
      ),
      body: const Center(
        child: Text(
          "Welcome to SaveWise 💰",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}