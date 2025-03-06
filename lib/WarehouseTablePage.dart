import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'CustomWidgets/CustomSideBar.dart';
import 'package:sidebarx/sidebarx.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warehouse Table to PDF',
      home: WarehouseTablePage(),
    );
  }
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

  // Variables para la paginación
  int _rowsPerPage = 10;
  int currentPage = 0; // Número de página (0, 1, 2, ...)

  @override
  void initState() {
    super.initState();
    fetchWarehouses();
    _searchController.addListener(_filterWarehouses);
  }

  Future<void> fetchWarehouses() async {
    final response = await http.get(Uri.parse('http://localhost:3000/warehouses'));
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
        return (warehouse['warehouseID'] ?? '')
                .toString()
                .toLowerCase()
                .contains(query) ||
            (warehouse['destinatario'] ?? '')
                .toString()
                .toLowerCase()
                .contains(query) ||
            (warehouse['destino'] ?? '')
                .toString()
                .toLowerCase()
                .contains(query) ||
            (warehouse['fecha'] ?? '')
                .toString()
                .toLowerCase()
                .contains(query) ||
            (warehouse['estatus'] ?? '')
                .toString()
                .toLowerCase()
                .contains(query) ||
            (warehouse['modalidad'] ?? '')
                .toString()
                .toLowerCase()
                .contains(query) ||
            (warehouse['cargaID'] ?? '')
                .toString()
                .toLowerCase()
                .contains(query);
      }).toList();
      // Reinicia a la primera página al filtrar
      currentPage = 0;
    });
  }

  WarehouseDataSource _warehouseDataSource() {
    return WarehouseDataSource(warehouses: filteredWarehouses);
  }

  Future<void> _generatePdf() async {
    // Calcula el índice de inicio y fin según la página actual y el número de filas por página
    int start = currentPage * _rowsPerPage;
    int end = (start + _rowsPerPage) > filteredWarehouses.length
        ? filteredWarehouses.length
        : start + _rowsPerPage;
    List<dynamic> visibleWarehouses = filteredWarehouses.sublist(start, end);

    final pdfDoc = pw.Document();

    final headers = [
      'WarehouseID',
      'Destinatario',
      'Destino',
      'Fecha',
      'Piezas',
      'Peso',
      'Estatus',
      'Modalidad',
      'CargaID'
    ];

    // Mapea los datos visibles en una lista de filas
    final data = visibleWarehouses.map((warehouse) {
      return [
        warehouse['warehouseID'].toString(),
        warehouse['destinatario'],
        warehouse['destino'],
        warehouse['fecha'].toString(),
        warehouse['piezas'].toString(),
        warehouse['peso'].toString(),
        warehouse['estatus'].toString(),
        warehouse['modalidad'],
        warehouse['cargaID'].toString(),
      ];
    }).toList();

    pdfDoc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a3,
        margin: pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return [
            // Encabezado del reporte
            pw.Text(
              "Reporte de warehouses",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            // Tabla personalizada con anchos fijos para que el texto haga wrap
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(60),  // WarehouseID
                1: const pw.FixedColumnWidth(80),  // Destinatario
                2: const pw.FixedColumnWidth(80),  // Destino
                3: const pw.FixedColumnWidth(60),  // Fecha
                4: const pw.FixedColumnWidth(40),  // Piezas
                5: const pw.FixedColumnWidth(40),  // Peso
                6: const pw.FixedColumnWidth(60),  // Estatus
                7: const pw.FixedColumnWidth(60),  // Modalidad
                8: const pw.FixedColumnWidth(60),  // CargaID
              },
              border: pw.TableBorder.all(color: PdfColors.grey),
              children: [
                // Fila de encabezados
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: PdfColors.blue),
                  children: headers.map((header) => pw.Container(
                    padding: pw.EdgeInsets.all(5),
                    child: pw.Text(
                      header,
                      style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                      softWrap: true,
                    ),
                  )).toList(),
                ),
                // Filas de datos
                ...data.map((row) {
                  return pw.TableRow(
                    children: row.map((cell) => pw.Container(
                      padding: pw.EdgeInsets.all(5),
                      child: pw.Text(
                        cell.toString(),
                        style: pw.TextStyle(fontSize: 8),
                        softWrap: true,
                      ),
                    )).toList(),
                  );
                }).toList(),
              ],
            )
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdfDoc.save(),
      name: 'Reporte_de_Warehouses.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página de Warehouses'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
          ),
        ],
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
              decoration: InputDecoration(
                labelText: 'Buscar',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                prefixIcon: Icon(Icons.search),
                filled: true,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: PaginatedDataTable2(
                header: Text('Listado de Warehouses'),
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
                availableRowsPerPage: const [10, 20, 50],
                onRowsPerPageChanged: (value) {
                  setState(() {
                    _rowsPerPage = value!;
                  });
                },
                // Convertimos el índice recibido a número de página real
                onPageChanged: (firstRowIndex) {
                  setState(() {
                    currentPage = (firstRowIndex / _rowsPerPage).floor();
                  });
                },
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
        DataCell(
          ActionChip(
            label: Text(warehouse['warehouseID'].toString()),
            onPressed: () {
              print('ID del paquete: ${warehouse['warehouseID']}');
            },
          ),
        ),
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
