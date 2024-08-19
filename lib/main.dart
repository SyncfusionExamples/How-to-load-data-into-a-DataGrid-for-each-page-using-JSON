import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

/// The application that contains datagrid on it.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syncfusion DataGrid Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const JsonDataGrid(),
    );
  }
}

int rowsPerPage = 10;
late JsonDataGridSource jsonDataGridSource;
List<Product> productlist = [];

class JsonDataGrid extends StatefulWidget {
  const JsonDataGrid({super.key});

  @override
  JsonDataGridState createState() => JsonDataGridState();
}

Future generateProductList() async {
  // Here we have get the entire data asynchronously.
  var response = await http.get(Uri.parse(
      'https://ej2services.syncfusion.com/production/web-services/api/Orders?'));
  var list = json.decode(response.body).cast<Map<String, dynamic>>();
  productlist =
      await list.map<Product>((json) => Product.fromJson(json)).toList();
  jsonDataGridSource =
      JsonDataGridSource(productlist.getRange(0, rowsPerPage).toList());

  return productlist;
}

class JsonDataGridState extends State<JsonDataGrid> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter DataGrid Sample'),
        ),
        body: FutureBuilder(
            future: generateProductList(),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              return snapshot.hasData
                  ? LayoutBuilder(builder: (context, constraints) {
                      return Column(children: [
                        SizedBox(
                            height: constraints.maxHeight - 60,
                            width: constraints.maxWidth,
                            child: buildDataGrid()),
                        SizedBox(
                          height: 60,
                          width: constraints.maxWidth,
                          child: SfDataPager(
                            pageCount: (productlist.length / rowsPerPage)
                                .ceil()
                                .toDouble(),
                            delegate: jsonDataGridSource,
                            availableRowsPerPage: const [10, 20, 30],
                            onRowsPerPageChanged: (int? rowsPerPages) {
                              setState(() {
                                rowsPerPage = rowsPerPages!;
                                jsonDataGridSource.updateDataGriDataSource();
                              });
                            },
                          ),
                        )
                      ]);
                    })
                  : const Center(
                      child: CircularProgressIndicator(strokeWidth: 3));
            }));
  }

  Widget buildDataGrid() {
    return SfDataGrid(
        columns: getColumns(),
        source: jsonDataGridSource,
        columnWidthMode: ColumnWidthMode.fill);
  }

  List<GridColumn> getColumns() {
    return [
      GridColumn(
        columnName: 'orderID',
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: const Text(
            'Order ID',
            overflow: TextOverflow.clip,
            softWrap: true,
          ),
        ),
      ),
      GridColumn(
        columnName: 'customerID',
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: const Text(
            'Customer ID',
            overflow: TextOverflow.clip,
            softWrap: true,
          ),
        ),
      ),
      GridColumn(
        columnName: 'employeeID',
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: const Text(
            'Employee ID',
            overflow: TextOverflow.clip,
            softWrap: true,
          ),
        ),
      ),
      GridColumn(
        columnName: 'freight',
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: const Text('Freight'),
        ),
      ),
      GridColumn(
        columnName: 'shipAddress',
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: const Text(
            'Ship Address',
            overflow: TextOverflow.clip,
            softWrap: true,
          ),
        ),
      ),
      GridColumn(
        columnName: 'shipCity',
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: const Text(
            'Ship City',
            overflow: TextOverflow.clip,
            softWrap: true,
          ),
        ),
      ),
      GridColumn(
        columnName: 'shipCountry',
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: const Text(
            'Ship Country',
            overflow: TextOverflow.clip,
            softWrap: true,
          ),
        ),
      ),
      GridColumn(
        columnName: 'shipName',
        label: Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: const Text(
            'Ship Name',
            overflow: TextOverflow.clip,
            softWrap: true,
          ),
        ),
      ),
    ];
  }
}

class JsonDataGridSource extends DataGridSource {
  JsonDataGridSource(List<Product> productlist) {
    buildDataGridRow(productlist);
  }

  List<DataGridRow> dataGridRows = [];

  void buildDataGridRow(List<Product> productlist) {
    dataGridRows = productlist.map<DataGridRow>((dataGridRow) {
      return DataGridRow(cells: [
        DataGridCell<int>(columnName: 'orderID', value: dataGridRow.orderID),
        DataGridCell<String>(
            columnName: 'customerID', value: dataGridRow.customerID),
        DataGridCell<int>(
            columnName: 'employeeID', value: dataGridRow.employeeID),
        DataGridCell<double>(columnName: 'freight', value: dataGridRow.freight),
        DataGridCell<String>(
            columnName: 'shipAddress', value: dataGridRow.shipAddress),
        DataGridCell<String>(
            columnName: 'shipCity', value: dataGridRow.shipCity),
        DataGridCell<String>(
            columnName: 'shipCountry', value: dataGridRow.shipCountry),
        DataGridCell<String>(
            columnName: 'shipName', value: dataGridRow.shipName),
      ]);
    }).toList(growable: false);
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: dataGridCell.columnName == 'shippedDate'
            ? Text(DateFormat('MM/dd/yyyy').format(dataGridCell.value))
            : Text(dataGridCell.value.toString()),
      );
    }).toList());
  }

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    int startIndex = newPageIndex * rowsPerPage;
    int endIndex = startIndex + rowsPerPage;
    if (endIndex > productlist.length) {
      endIndex = productlist.length;
    }
    if (startIndex < productlist.length && endIndex <= productlist.length) {
      buildDataGridRow(productlist.getRange(startIndex, endIndex).toList());
      notifyListeners();
    } else {
      dataGridRows = [];
    }

    return true;
  }

  void updateDataGriDataSource() {
    notifyListeners();
  }
}

class Product {
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        orderID: json['OrderID'],
        customerID: json['CustomerID'],
        employeeID: json['EmployeeID'],
        orderDate: DateTime.parse(json['OrderDate']),
        shippedDate: DateTime.parse(json['ShippedDate']),
        freight: json['Freight'],
        shipName: json['ShipName'],
        shipAddress: json['ShipAddress'],
        shipCity: json['ShipCity'],
        shipPostelCode: json['ShipPostelCode'],
        shipCountry: json['ShipCountry']);
  }

  Product(
      {this.orderID,
      this.customerID,
      this.employeeID,
      this.orderDate,
      this.shippedDate,
      this.freight,
      this.shipName,
      this.shipAddress,
      this.shipCity,
      this.shipPostelCode,
      this.shipCountry});
  int? orderID;
  String? customerID;
  int? employeeID;
  DateTime? orderDate;
  DateTime? shippedDate;
  double? freight;
  String? shipName;
  String? shipAddress;
  String? shipCity;
  int? shipPostelCode;
  String? shipCountry;
}
