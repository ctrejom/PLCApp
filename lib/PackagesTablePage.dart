import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // Importa el paquete pdf
import 'package:printing/printing.dart'; // Importa el paquete printing para la vista previa e impresión del PDF
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
      title: 'Packages Table to PDF',
      home: PackagesTablePage(),
    );
  }
}

class PackagesTablePage extends StatefulWidget {
  @override
  _PackagesTablePageState createState() => _PackagesTablePageState();
}

class _PackagesTablePageState extends State<PackagesTablePage> {
  dynamic packages = [];
  List<dynamic> filteredPackages = [];
  final TextEditingController _searchController = TextEditingController();
  final SidebarXController _sidebarXController = SidebarXController(selectedIndex: 2);

  // Variables para la paginación
  int _rowsPerPage = 10;
  int currentPage = 0; // Para rastrear la página actual mostrada

  @override
  void initState() {
    super.initState();
    fetchPackages();
    _searchController.addListener(_filterPackages);
  }

  // Función para obtener los paquetes desde la API
  Future<void> fetchPackages() async {
    final response = await http.get(Uri.parse('http://localhost:3000/paquetes'));
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

  // Función para filtrar los paquetes según el texto ingresado
  void _filterPackages() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredPackages = packages.where((package) {
        return package['paqueteID'].toLowerCase().contains(query) ||
            package['warehouseID'].toString().toLowerCase().contains(query) ||
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

  // Fuente de datos para la tabla
  PackagesDataSource _packagesDataSource() {
    return PackagesDataSource(packages: filteredPackages);
  }

  // Función para generar el PDF solo con los datos que se muestran en la página actual
  Future<void> _generatePdf() async {
    // Calcula el índice de inicio y fin según la página actual y el número de filas por página
    int start = currentPage * _rowsPerPage;
    int end = (start + _rowsPerPage) > filteredPackages.length
        ? filteredPackages.length
        : start + _rowsPerPage;
    List<dynamic> visiblePackages = filteredPackages.sublist(start, end);

    final pdfDoc = pw.Document();

    // Encabezados de la tabla en el PDF
    final headers = [
      'Paquete ID',
      'Warehouse ID',
      'Destinatario',
      'Destino',
      'Fecha',
      'Tracking',
      'Peso',
      'Tipo',
      'Modalidad',
      'Estatus'
    ];

    // Mapea los datos visibles en una lista de filas para la tabla
    final data = visiblePackages.map((package) {
      return [
        package['paqueteID'].toString(),
        package['warehouseID'].toString(),
        package['destinatario'],
        package['destino'],
        package['fecha'].toString(),
        package['tracking'].toString(),
        package['peso'].toString(),
        package['tipo'].toString(),
        package['modalidad'].toString(),
        package['estatus'].toString(),
      ];
    }).toList();

    pdfDoc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a3,
        margin: pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return [
            // Título del reporte
            pw.Text(
              "Reporte de packages",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            // Tabla personalizada con anchos fijos para que el texto haga wrap
            pw.Table(
              columnWidths: {
                0: pw.FixedColumnWidth(60),  // Paquete ID
                1: pw.FixedColumnWidth(60),  // Warehouse ID
                2: pw.FixedColumnWidth(80),  // Destinatario
                3: pw.FixedColumnWidth(80),  // Destino
                4: pw.FixedColumnWidth(60),  // Fecha
                5: pw.FixedColumnWidth(80),  // Tracking
                6: pw.FixedColumnWidth(40),  // Peso
                7: pw.FixedColumnWidth(40),  // Tipo
                8: pw.FixedColumnWidth(60),  // Modalidad
                9: pw.FixedColumnWidth(60),  // Estatus
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

    // Muestra la vista previa del PDF para imprimir o guardar
    await Printing.layoutPdf(
      onLayout: (format) async => pdfDoc.save(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página de Paquetes'),
        actions: [
          // Botón en el AppBar para generar el PDF
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
          ),
        ],
      ),
      drawer: CustomSideBar(
        selectedIndex: 2,
        controller: _sidebarXController,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo de búsqueda para filtrar los paquetes
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
            // Tabla paginada que muestra los paquetes
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
                availableRowsPerPage: const [10, 20, 50],
                onRowsPerPageChanged: (value) {
                  setState(() {
                    _rowsPerPage = value!;
                  });
                },
                // Actualiza la página actual cuando se navega entre páginas
                onPageChanged: (firstRowIndex) {
                  setState(() {
                    currentPage = (firstRowIndex / _rowsPerPage).floor();
                  });
                },
                showFirstLastButtons: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Clase que define la fuente de datos para la tabla paginada
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
