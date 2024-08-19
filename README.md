# How to load data into a DataGrid for each page using JSON in Flutter DataTable (SfDataGrid).
In this article, we will show you how to load data into a DataGrid for each page using JSON in [Flutter DataTable](https://www.syncfusion.com/flutter-widgets/flutter-datagrid).

## STEP 1: 

Refer to this KB [link](https://support.syncfusion.com/kb/article/10959/how-to-populate-flutter-datatable-datagrid-with-json-api) to populate Flutter DataTable (DataGrid) with JSON API.

## STEP 2: 

Initialize the [SfDataGrid](https://pub.dev/documentation/syncfusion_flutter_datagrid/latest/datagrid/SfDataGrid-class.html) and [SfDataPager](https://pub.dev/documentation/syncfusion_flutter_datagrid/latest/datagrid/SfDataPager-class.html) widgets with all the required properties. Instead of supplying the entire data to the DataGrid, provide only the data corresponding to the current page to the [DataGridSource](https://pub.dev/documentation/syncfusion_flutter_datagrid/latest/datagrid/DataGridSource-class.html). 

```dart
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
```

## STEP 3: 

Then, load the relevant data for the specific page within the [handlePageChange](https://pub.dev/documentation/syncfusion_flutter_datagrid/latest/datagrid/DataGridSource/handlePageChange.html) method. This method is invoked whenever the page is changed through the data pager.

```dart
class JsonDataGridSource extends DataGridSource {
 ...

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
}
```

You can download this example on [GitHub](https://github.com/SyncfusionExamples/How-to-load-data-into-a-DataGrid-for-each-page-using-JSON).