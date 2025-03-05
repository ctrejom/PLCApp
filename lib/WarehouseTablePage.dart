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

class WarehouseTablePage extends StatefulWidget {
  @override
  _WarehouseTablePageState createState() => _WarehouseTablePageState();
}

class _WarehouseTablePageState extends State<WarehouseTablePage> {
  dynamic warehouses = [];
  List<dynamic> filteredWarehouses = [];
  final TextEditingController _searchController = TextEditingController();
  final SidebarXController _sidebarXController = SidebarXController(selectedIndex: 1);

    // Variable de estado para el número de filas por página.
  int _rowsPerPage = 10;

  Future<void> fetchWarehouses() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/warehouses'));

    if (response.statusCode == 200) {
      setState(() {
        warehouses = json.decode(response.body).map((warehouse) {
          return {
            'warehouseID': warehouse['WarehouseID'],
            'destinatario': warehouse['Destinatario'],
            'destino': warehouse['Destino'],
            'fecha': warehouse['Fecha'],
            'piezas': warehouse['Piezas'],
            'peso': warehouse['Peso'] is int
                ? (warehouse['Peso'] as int).toDouble()
                : warehouse['Peso'],
            'estatus': warehouse['Estatus'],
            'modalidad': warehouse['Modalidad'],
            'cargaID': warehouse['CargaID'] ?? 'Sin CargaID'
          };
        }).toList();
        filteredWarehouses = List.from(warehouses);
      });
    } else {
      throw Exception('Error al cargar los almacenes');
    }
  }

  void _filterWarehouses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredWarehouses = warehouses.where((warehouse) {
        return warehouse['warehouseID'].toLowerCase().contains(query) ||
            warehouse['destinatario'].toLowerCase().contains(query) ||
            warehouse['destino'].toLowerCase().contains(query) ||
            warehouse['fecha'].toLowerCase().contains(query) ||
            warehouse['estatus'].toLowerCase().contains(query) ||
            warehouse['modalidad'].toLowerCase().contains(query) ||
            warehouse['cargaID'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchWarehouses();
    _searchController.addListener(_filterWarehouses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Método que retorna la fuente de datos para la PaginatedDataTable2
  WarehouseDataSource _warehouseDataSource() {
    return WarehouseDataSource(warehouses: filteredWarehouses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página de Warehouses'),
      ),
      drawer: CustomSideBar(
        selectedIndex: 1,
        controller: _sidebarXController,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              onChanged: (value) => _filterWarehouses(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PaginatedDataTable2(
                header: const Text('Listado de Warehouses'),
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                dataRowHeight: 60,
                headingRowHeight: 40,
                columns: const [
                  DataColumn2(
                    label: Text('WarehouseID'),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text('Destinatario'),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text('Destino'),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text('Fecha'),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text('Piezas'),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Text('Peso'),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Text('Estatus'),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Text('Modalidad'),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Text('CargaID'),
                    size: ColumnSize.S,
                  ),
                ],
                source: _warehouseDataSource(),
                rowsPerPage: _rowsPerPage,
                availableRowsPerPage: const<int>[10,20,50],
                onRowsPerPageChanged: (value) {
                  setState(() {
                    _rowsPerPage = value!;
                  });
                },// Puedes ajustar la cantidad de filas por página
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WarehouseDataSource extends DataTableSource {
  final List<dynamic> warehouses;

  WarehouseDataSource({required this.warehouses});

  @override
  DataRow? getRow(int index) {
    if (index >= warehouses.length) return null;
    final warehouse = warehouses[index];
    return DataRow2(
      cells: [
        DataCell(ActionChip(
          label: Text(warehouse['warehouseID'].toString()),
          onPressed: () {
            print('ID del paquete: ${warehouse['warehouseID']}');
          },
        )),
        DataCell(Text(warehouse['destinatario'])),
        DataCell(Text(warehouse['destino'])),
        DataCell(Text(warehouse['fecha'].toString())),
        DataCell(Text(warehouse['piezas'].toString())),
        DataCell(Text(warehouse['peso'].toString())),
        DataCell(Text(warehouse['estatus'].toString())),
        DataCell(Text(warehouse['modalidad'])),
        DataCell(Text(warehouse['cargaID'].toString())),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => warehouses.length;

  @override
  int get selectedRowCount => 0;
}
