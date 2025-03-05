import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart';
import 'CustomWidgets/CustomSideBar.dart';
import 'package:sidebarx/sidebarx.dart';

void main() {
  runApp(MyApp());
}

class PackagesTablePage extends StatefulWidget {
  @override
  _PackagesTablePageState createState() => _PackagesTablePageState();
}

class _PackagesTablePageState extends State<PackagesTablePage> {
  dynamic packages = [];
  List<dynamic> filteredPackages = [];
  final TextEditingController _searchController = TextEditingController();
  final SidebarXController _sidebarXController =
      SidebarXController(selectedIndex: 2);

  // Variable de estado para el número de filas por página.
  int _rowsPerPage = 10;

  Future<void> fetchPackages() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/paquetes'));

    if (response.statusCode == 200) {
      setState(() {
        packages = json.decode(response.body).map((package) {
          return {
            'paqueteID': package['PaqueteID'],
            'warehouseID': package['WarehouseID'] ?? 'Sin WarehouseID',
            'destinatario': package['Destinatario'],
            'destino': package['Destino'],
            'fecha': package['Fecha'] ?? 'Sin Fecha',
            'tracking': package['Tracking'] ?? 'Sin Tracking',
            'peso': package['Peso'] is int
                ? (package['Peso'] as int).toDouble()
                : package['Peso'] ?? 'Sin Peso',
            'tipo': package['Tipo'] ?? 'Sin Tipo',
            'modalidad': package['Modalidad'],
            'estatus': package['Estatus'] ?? 'Sin Estatus',
          };
        }).toList();
        filteredPackages = List.from(packages);
        print('Total registros: ${filteredPackages.length}');
      });
    } else {
      throw Exception('Error al cargar los paquetes');
    }
  }

  void _filterPackages() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredPackages = packages.where((package) {
        return package['paqueteID'].toLowerCase().contains(query) ||
            package['warehouseID']
                .toString()
                .toLowerCase()
                .contains(query) ||
            package['destinatario'].toLowerCase().contains(query) ||
            package['destino'].toLowerCase().contains(query) ||
            package['fecha'].toLowerCase().contains(query) ||
            package['tracking'].toLowerCase().contains(query) ||
            package['peso'].toString().toLowerCase().contains(query) ||
            package['tipo'].toLowerCase().contains(query) ||
            package['modalidad'].toLowerCase().contains(query) ||
            package['estatus'].toLowerCase().contains(query);
      }).toList();
      print('Registros filtrados: ${filteredPackages.length}');
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPackages();
    _searchController.addListener(_filterPackages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  PackagesDataSource _packagesDataSource() {
    return PackagesDataSource(packages: filteredPackages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página de Paquetes'),
      ),
      drawer: CustomSideBar(
        selectedIndex: 2,
        controller: _sidebarXController,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Si es posible, prueba a quitar el Padding para verificar que no esté afectando el layout
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                prefixIcon: Icon(Icons.search),
                filled: true,
              ),
              onChanged: (value) => _filterPackages(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PaginatedDataTable2(
                header: const Text('Listado de Paquetes'),
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                dataRowHeight: 60,
                headingRowHeight: 40,
                columns: const [
                  DataColumn2(label: Text('Paquete ID')),
                  DataColumn2(label: Text('Warehouse ID')),
                  DataColumn2(label: Text('Destinatario')),
                  DataColumn2(label: Text('Destino')),
                  DataColumn2(label: Text('Fecha')),
                  DataColumn2(label: Text('Tracking')),
                  DataColumn2(label: Text('Peso')),
                  DataColumn2(label: Text('Tipo')),
                  DataColumn2(label: Text('Modalidad')),
                  DataColumn2(label: Text('Estatus')),
                ],
                source: _packagesDataSource(),
                rowsPerPage: _rowsPerPage,
                availableRowsPerPage: const <int>[10, 20, 50],
                onRowsPerPageChanged: (value) {
                  setState(() {
                    _rowsPerPage = value!;
                  });
                },
                // Puedes activar los botones de primera/última página para mayor control:
                showFirstLastButtons: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PackagesDataSource extends DataTableSource {
  final List<dynamic> packages;

  PackagesDataSource({required this.packages});

  @override
  DataRow? getRow(int index) {
    if (index >= packages.length) return null;
    final package = packages[index];
    return DataRow2(
      cells: [
        DataCell(ActionChip(
          label: Text(package['paqueteID'].toString()),
          onPressed: () {
            print('ID del paquete: ${package['paqueteID']}');
          },
        )),
        DataCell(Text(package['warehouseID'].toString())),
        DataCell(Text(package['destinatario'])),
        DataCell(Text(package['destino'])),
        DataCell(Text(package['fecha'].toString())),
        DataCell(Text(package['tracking'].toString())),
        DataCell(Text(package['peso'].toString())),
        DataCell(Text(package['tipo'].toString())),
        DataCell(Text(package['modalidad'].toString())),
        DataCell(Text(package['estatus'].toString())),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => packages.length;

  @override
  int get selectedRowCount => 0;
}
