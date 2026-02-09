import 'package:flutter/material.dart';

void main() => runApp(ClientSchedulerApp());

class ClientSchedulerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Client Scheduler',
      home: Scaffold(
        appBar: AppBar(title: Text('Client Scheduler')),
        body: Center(child: Text('Welcome to Client Scheduler')),
      ),
    );
  }
}
