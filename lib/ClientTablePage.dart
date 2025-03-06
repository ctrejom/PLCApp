import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plcapp/CustomWidgets/CustomSideBar.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:data_table_2/data_table_2.dart';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ClientTablePage extends StatefulWidget {
  @override
  _ClientTablePageState createState() => _ClientTablePageState();
}

class _ClientTablePageState extends State<ClientTablePage> {
  dynamic clientes = [];
  List<dynamic> filteredClientes = [];
  final TextEditingController _searchController = TextEditingController();
  final SidebarXController _sidebarXController = SidebarXController(selectedIndex: 3);
  
  int _rowsPerPage = 10;
  int currentPage = 0; // Variable para rastrear el número de página (0, 1, 2, ...)

  Future<void> fetchClientes() async {
    final response = await http.get(Uri.parse('http://localhost:3000/clientes'));
    if (response.statusCode == 200) {
      setState(() {
        clientes = json.decode(response.body).map((cliente) {
          return {
            'clienteID': cliente['ClienteID'],
            'nombre': cliente['Nombre'],
            'apellido': cliente['Apellido'],
            'email': cliente['Email'],
            'numeroidentidad': cliente['NumeroIdentidad'],
            'fecha': cliente['Fecha'],
            'direccion': cliente['Direccion'],
            'ciudad': cliente['Ciudad'],
            'estado': cliente['Estado'],
            'movil': cliente['Movil']
          };
        }).toList();
        filteredClientes = List.from(clientes);
      });
    } else {
      throw Exception('Error al cargar los clientes');
    }
  }

  void _filterClientes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredClientes = clientes.where((cliente) {
        return cliente['clienteID'].toLowerCase().contains(query) ||
            cliente['nombre'].toLowerCase().contains(query) ||
            cliente['apellido'].toLowerCase().contains(query) ||
            cliente['email'].toLowerCase().contains(query) ||
            cliente['numeroidentidad'].toLowerCase().contains(query) ||
            cliente['fecha'].toLowerCase().contains(query) ||
            cliente['direccion'].toLowerCase().contains(query) ||
            cliente['ciudad'].toLowerCase().contains(query) ||
            cliente['estado'].toLowerCase().contains(query) ||
            cliente['movil'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchClientes();
  }

  ClienteDataSource _clienteDataSource() {
    return ClienteDataSource(clientes: filteredClientes);
  }

  Future<void> _generatePdf() async {
    // Calcula el índice de inicio y fin según el número de página y filas por página
    int start = currentPage * _rowsPerPage;
    int end = (start + _rowsPerPage) > filteredClientes.length
        ? filteredClientes.length
        : start + _rowsPerPage;
    List<dynamic> visibleClientes = filteredClientes.sublist(start, end);

    final pdfDoc = pw.Document();

    final headers = [
      'ClienteID',
      'Nombre',
      'Apellido',
      'Email',
      'Legal ID',
      'Fecha',
      'Direccion',
      'Ciudad',
      'Estado',
      'Movil'
    ];

    // Mapea los datos visibles a lista de filas
    final data = visibleClientes.map((cliente) {
      return [
        cliente['clienteID'],
        cliente['nombre'],
        cliente['apellido'],
        cliente['email'],
        cliente['numeroidentidad'],
        cliente['fecha'],
        cliente['direccion'],
        cliente['ciudad'],
        cliente['estado'],
        cliente['movil']
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
              "Reporte de clientes",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            // Tabla personalizada con anchos fijos para wrap de texto
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(60),  // ClienteID
                1: const pw.FixedColumnWidth(80),  // Nombre
                2: const pw.FixedColumnWidth(80),  // Apellido
                3: const pw.FixedColumnWidth(120), // Email
                4: const pw.FixedColumnWidth(80),  // Legal ID
                5: const pw.FixedColumnWidth(60),  // Fecha
                6: const pw.FixedColumnWidth(120), // Direccion
                7: const pw.FixedColumnWidth(80),  // Ciudad
                8: const pw.FixedColumnWidth(80),  // Estado
                9: const pw.FixedColumnWidth(60),  // Movil
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
      name: 'Reporte_de_clientes.pdf',
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
        title: const Text('Página de Clientes'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
          )
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
              decoration: const InputDecoration(
                labelText: 'Buscar',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                prefixIcon: Icon(Icons.search),
                filled: true,
              ),
              onChanged: (value) => _filterClientes(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PaginatedDataTable2(
                header: const Text('Listado de Clientes'),
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                dataRowHeight: 60,
                headingRowHeight: 40,
                columns: const [
                  DataColumn2(label: Text('ID')),
                  DataColumn2(label: Text('Nombre')),
                  DataColumn2(label: Text('Apellido')),
                  DataColumn2(label: Text('Email')),
                  DataColumn2(label: Text('Numero Identidad')),
                  DataColumn2(label: Text('Fecha')),
                  DataColumn2(label: Text('Direccion')),
                  DataColumn2(label: Text('Ciudad')),
                  DataColumn2(label: Text('Estado')),
                  DataColumn2(label: Text('Movil')),
                ],
                source: _clienteDataSource(),
                rowsPerPage: _rowsPerPage,
                availableRowsPerPage: const <int>[10, 20, 50],
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

class ClienteDataSource extends DataTableSource {
  final List<dynamic> clientes;

  ClienteDataSource({required this.clientes});

  @override
  DataRow? getRow(int index) {
    if (index >= clientes.length) return null;
    final cliente = clientes[index];
    return DataRow2(
      cells: [
        DataCell(ActionChip(
          label: Text(cliente['clienteID'].toString()),
          onPressed: () {
            print('ID del cliente: ${cliente['clienteID']}');
          },
        )),
        DataCell(Text(cliente['nombre'])),
        DataCell(Text(cliente['apellido'])),
        DataCell(Text(cliente['email'])),
        DataCell(Text(cliente['numeroidentidad'])),
        DataCell(Text(cliente['fecha'].toString())),
        DataCell(Text(cliente['direccion'])),
        DataCell(Text(cliente['ciudad'])),
        DataCell(Text(cliente['estado'])),
        DataCell(Text(cliente['movil'].toString())),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => clientes.length;
  @override
  int get selectedRowCount => 0;
}
