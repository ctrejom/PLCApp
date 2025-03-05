import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:plcapp/CustomWidgets/CustomSideBar.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:data_table_2/data_table_2.dart';
import 'dart:convert';


class CasilleroTablePage extends StatefulWidget {
  @override
  _CasilleroTablePageState createState() => _CasilleroTablePageState();
}

class _CasilleroTablePageState extends State<CasilleroTablePage> {
  dynamic casilleros = [];
   List<dynamic> filteredCasilleros = [];
  final TextEditingController _searchController = TextEditingController();
  final SidebarXController _sidebarXController = SidebarXController(selectedIndex: 3);
  int _rowsPerPage = 10;

  Future<void> fetchCasilleros() async{
    final response = await http.get(Uri.parse('http://localhost:3000/casilleros'));

    if(response.statusCode == 200)
    {
      setState(() {
        casilleros = json.decode(response.body).map((casilleros){
          return{
            'casilleroID': casilleros['ClienteID'],
            'nombre': casilleros['Nombre'],
            'apellido': casilleros['Apellido'],
            'email': casilleros['Email'],
            'numeroidentidad': casilleros['NumeroIdentidad'],
            'fecha': casilleros['Fecha'],
            'direccion': casilleros['Direccion'],
            'ciudad': casilleros['Ciudad'],
            'estado': casilleros['Estado'],
            'movil': casilleros['Movil']
          };
        }
        ).toList();
        filteredCasilleros = List.from(casilleros);

      });
    }
    else{
      throw Exception('Error al cargar los casilleros');
    }
  }

  void _filterCasilleros(){
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredCasilleros = casilleros.where((casilleros){
        return casilleros['casilleroID'].toLowerCase().contains(query) ||
        casilleros['nombre'].toLowerCase().contains(query) ||
        casilleros['apellido'].toLowerCase().contains(query) ||
        casilleros['email'].toLowerCase().contains(query) ||
        casilleros['numeroidentidad'].toLowerCase().contains(query) ||
        casilleros['fecha'].toLowerCase().contains(query) ||
        casilleros['direccion'].toLowerCase().contains(query) ||
        casilleros['ciudad'].toLowerCase().contains(query) ||
        casilleros['estado'].toLowerCase().contains(query) ||
        casilleros['movil'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void initState(){
    super.initState();
    fetchCasilleros();
  }

  @override
  void dispose(){
    _searchController.dispose();
    super.dispose();
  }

// Método que retorna la fuente de datos para la PaginatedDataTable2
  CasilleroDataSource _casilleroDataSource() {
    return CasilleroDataSource(casilleros: filteredCasilleros);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página de Casilleros'),
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
              onChanged: (value) => _filterCasilleros(),
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
                //COLUMNAS
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
                source: _casilleroDataSource(),
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

class CasilleroDataSource extends DataTableSource {
  final List<dynamic> casilleros;

  CasilleroDataSource({required this.casilleros});

  @override
  DataRow? getRow(int index) {
    if (index >= casilleros.length) return null;
    final casillero = casilleros[index];
    //FILAS
    return DataRow2(
      cells: [
        DataCell(ActionChip(
          label: Text(casillero['casilleroID'].toString()),
          onPressed: () {
            print('ID del casillero: ${casillero['casilleroID']}');
          },
        )),
        DataCell(Text(casillero['nombre'])),
        DataCell(Text(casillero['apellido'])),
        DataCell(Text(casillero['email'])),
        DataCell(Text(casillero['numeroidentidad'])),
        DataCell(Text(casillero['fecha'].toString())),
        DataCell(Text(casillero['direccion'])),
        DataCell(Text(casillero['ciudad'])),
        DataCell(Text(casillero['estado'])),
        DataCell(Text(casillero['movil'].toString())),
      ],
    );
  }


  //Metodos obligatorios de DataTable2
  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => casilleros.length;

  @override
  int get selectedRowCount => 0;
}