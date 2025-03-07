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
  runApp(MaterialApp(
    home: ChargeTablePage(),
  ));
}

class ChargeTablePage extends StatefulWidget {
  @override
  _ChargeTablePageState createState() => _ChargeTablePageState();
}

class _ChargeTablePageState extends State<ChargeTablePage> {
  dynamic charges = [];
  List<dynamic> filteredCharges = [];
  final TextEditingController _searchController = TextEditingController();
  final SidebarXController _sidebarXController = SidebarXController(selectedIndex: 4);

  // Variables para la paginación
  int _rowsPerPage = 10;
  int currentPage = 0; // Número de página (0, 1, 2, ...)

  @override
  void initState() {
    super.initState();
    fetchCharges();
    _searchController.addListener(_filterCharges);
  }

  Future<void> fetchCharges() async {
    final response = await http.get(Uri.parse('http://localhost:3000/cargas'));
    if (response.statusCode == 200) {
      setState(() {
        charges = json.decode(response.body).map((charge) {
          return {
            'cargaID': charge['CargaID'],
            'estatus': charge['Estatus'],
            'fechainicial': charge['FechaInicial'],
            'fechafinal': charge['FechaFinal'],
            'entregainicial': charge['EntregaInicial'],
            'entregafinal': charge['EntregaFinal'],
            'peso': charge['Peso'] is int
                ? (charge['Peso'] as int).toDouble()
                : charge['Peso'],
            'modalidad': charge['Modalidad'],
          };
        }).toList();
        filteredCharges = List.from(charges);
      });
    } else {
      throw Exception('Error al cargar los registros');
    }
  }

  void _filterCharges() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredCharges = charges.where((charge) {
        return charge['cargaID']
                .toString()
                .toLowerCase()
                .contains(query) ||
            charge['estatus']
                .toLowerCase()
                .contains(query) ||
            charge['fechainicial']
                .toString()
                .toLowerCase()
                .contains(query) ||
            charge['fechafinal']
                .toString()
                .toLowerCase()
                .contains(query) ||
            charge['entregainicial']
                .toString()
                .toLowerCase()
                .contains(query) ||
            charge['entregafinal']
                .toString()
                .toLowerCase()
                .contains(query) ||
            charge['peso']
                .toString()
                .toLowerCase()
                .contains(query) ||
            charge['modalidad']
                .toLowerCase()
                .contains(query);
      }).toList();
      // Reinicia a la primera página al filtrar
      currentPage = 0;
    });
  }

  ChargeDataSource _chargeDataSource() {
    return ChargeDataSource(charges: filteredCharges);
  }

  Future<void> _generatePdf() async {
    // Calcula el índice de inicio y fin según la página actual y el número de filas por página
    int start = currentPage * _rowsPerPage;
    int end = (start + _rowsPerPage) > filteredCharges.length
        ? filteredCharges.length
        : start + _rowsPerPage;
    List<dynamic> visibleCharges = filteredCharges.sublist(start, end);

    final pdfDoc = pw.Document();

    final headers = [
      'CargaID',
      'Estatus',
      'Fecha Inicial',
      'Fecha Final',
      'Entrega Inicial',
      'Entrega Final',
      'Peso',
      'Modalidad',
    ];

    // Mapea los datos visibles en una lista de filas para la tabla
    final data = visibleCharges.map((charge) {
      return [
        charge['cargaID'],
        charge['estatus'],
        charge['fechainicial'],
        charge['fechafinal'],
        charge['entregainicial'],
        charge['entregafinal'],
        charge['peso'],
        charge['modalidad'],
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
              "Reporte de cargas",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            // Tabla personalizada con anchos fijos para que el texto haga wrap
            pw.Table(
              columnWidths: {
                0: pw.FixedColumnWidth(50),
                1: pw.FixedColumnWidth(50),
                2: pw.FixedColumnWidth(100),
                3: pw.FixedColumnWidth(100),
                4: pw.FixedColumnWidth(100),
                5: pw.FixedColumnWidth(100),
                6: pw.FixedColumnWidth(50),
                7: pw.FixedColumnWidth(100),
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
      name: 'Reporte_de_cargas.pdf',
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
        title: Text('Página de cargas'),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                prefixIcon: Icon(Icons.search),
                filled: true,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: PaginatedDataTable2(
                header: Text('Listado de cargas'),
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                dataRowHeight: 60,
                headingRowHeight: 40,
                columns: const [
                  DataColumn2(label: Text('CargaID')),
                  DataColumn2(label: Text('Estatus')),
                  DataColumn2(label: Text('Fecha Inicial')),
                  DataColumn2(label: Text('Fecha Final')),
                  DataColumn2(label: Text('Entrega Inicial')),
                  DataColumn2(label: Text('Entrega Final')),
                  DataColumn2(label: Text('Peso')),
                  DataColumn2(label: Text('Modalidad')),
                ],
                source: _chargeDataSource(),
                rowsPerPage: _rowsPerPage,
                availableRowsPerPage: const [10, 20, 50],
                onRowsPerPageChanged: (value) {
                  setState(() {
                    _rowsPerPage = value!;
                  });
                },
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

class ChargeDataSource extends DataTableSource {
  final List<dynamic> charges;

  ChargeDataSource({required this.charges});

  @override
  DataRow? getRow(int index) {
    if (index >= charges.length) return null;
    final charge = charges[index];
    return DataRow2(
      cells: [
        DataCell(
          ActionChip(
            label: Text(charge['cargaID'].toString()),
            onPressed: () {
              print('ID de la carga: ${charge['cargaID']}');
            },
          ),
        ),
        DataCell(Text(charge['estatus'])),
        DataCell(Text(charge['fechainicial'].toString())),
        DataCell(Text(charge['fechafinal'].toString())),
        DataCell(Text(charge['entregainicial'].toString())),
        DataCell(Text(charge['entregafinal'].toString())),
        DataCell(Text(charge['peso'].toString())),
        DataCell(Text(charge['modalidad'])),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => charges.length;
  @override
  int get selectedRowCount => 0;
}
