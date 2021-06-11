import 'package:flutter/material.dart';
import 'dart:async';
import 'package:nhttp/nhttp.dart' as nhttp;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  Future<void> _getData() async {
    final nhttp.Response response = await nhttp.get("https://jsonplaceholder.typicode.com/albums/1");
    print('response');
    print(response.bodyBytes);
    print(response.statusCode);
    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              OutlinedButton(
                child: Text("GET"),
                onPressed: () async => _getData(),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
