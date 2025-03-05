import 'package:flutter/material.dart';
import 'package:plcapp/CasilleroTablePage.dart';
import 'package:sidebarx/sidebarx.dart';
import '../HomePage.dart';
import '../WarehouseTablePage.dart'; // Define o crea una página para "Paquetes"
import '../PackagesTablePage.dart'; // Define o crea una página para "Almacenes"

class CustomSideBar extends StatelessWidget {
  final int selectedIndex;
  final SidebarXController controller;

  const CustomSideBar({
    Key? key,
    required this.selectedIndex,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150, // Ancho fijo para que no tape toda la pantalla
      child: SidebarX(
        controller: controller,
        theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xFF2E2E48),
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: Color(0xFF464667),
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        hoverTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFF2E2E48)),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(0xFF5F5FA7).withOpacity(0.6).withOpacity(0.37),
          ),
          gradient: const LinearGradient(
            colors: [Color(0xFF3E3E61), Color(0xFF2E2E48)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: SidebarXTheme(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        width: 950,
        decoration: BoxDecoration(
          color: const Color(0xFF2E2E48),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
        // Aquí se definen los items con sus respectivos onTap
        items: [
          SidebarXItem(
            icon: Icons.home,
            label: 'Home',
            onTap: () {
              debugPrint('Home tapped');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          SidebarXItem(
            icon: Icons.warehouse,
            label: 'Warehouse',
            onTap: () {
              debugPrint('Warehouse tapped');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WarehouseTablePage()),
              );
            },
          ),
          SidebarXItem(
            icon: Icons.local_shipping,
            label: 'Paquetes',
            onTap: () {
              debugPrint('Paquetes tapped');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PackagesTablePage()),
              );
            },
          ),
          SidebarXItem(
            icon: Icons.person_pin_rounded,
            label: 'Casilleros',
            onTap: (){
              debugPrint('Casilleros tapped');
              Navigator.push(context, MaterialPageRoute(builder: (context) => CasilleroTablePage()));
            }
          )
        ],
      ),
    );
  }
}
