import 'package:flutter/material.dart';
import 'package:plcapp/PackagesTablePage.dart';
import 'HomePage.dart';
import 'WarehouseTablePage.dart';
import 'CasilleroTablePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navegación en Flutter',
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Página inicial
      routes: {
        '/': (context) => HomePage(),
        'WarehouseTablePage': (context) => WarehouseTablePage(),
        'PackagesTablePage': (context) => PackagesTablePage(),
        'CasilleroTablePage': (context) => CasilleroTablePage(),
      },
    );
  }
}
