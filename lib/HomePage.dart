import 'package:flutter/material.dart';
import 'package:plcapp/main.dart';
import 'CustomWidgets/CustomSideBar.dart';
import 'package:sidebarx/sidebarx.dart';

void main() {
  runApp(MyApp());
}

class HomePage extends StatelessWidget {
  final SidebarXController _sidebarXController = SidebarXController(selectedIndex: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      drawer: CustomSideBar(
        selectedIndex: 0,
        controller: _sidebarXController,
      ),
      body: Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}

