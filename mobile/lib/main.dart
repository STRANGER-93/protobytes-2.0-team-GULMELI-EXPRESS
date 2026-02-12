import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String result = "Press button";

  Future<void> testApi() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8000/api/"),
    );

    setState(() {
      result = response.body;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(result),
              ElevatedButton(
                onPressed: testApi,
                child: const Text("Call API"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
