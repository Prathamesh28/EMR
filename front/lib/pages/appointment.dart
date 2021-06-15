import 'dart:math';
import 'package:emr/pages/pages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AppointmentList extends StatefulWidget {
  @override
  _AppointmentListState createState() => _AppointmentListState();
}

class _AppointmentListState extends State<AppointmentList> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Container(
            height: max(MediaQuery.of(context).size.height * 0.1, 70),
            padding: EdgeInsets.all(10),
            alignment: Alignment.centerLeft,
            child: Text(
              "Appointments",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
          ),
          Container(
            child: DataTable(),
          )
        ],
      ),
    );
  }
}

Future<List<Patient>> fetchData() async {
  final String response = await rootBundle.loadString('assets/data/data.json');
  final parsed = json.decode(response).cast<Map<String, dynamic>>();
  return parsed.map<Patient>((json) => Patient.fromJson(json)).toList();
}

// List<Patient> parseData(String responseBody) {
//   final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
//   return parsed.map<Patient>((json) => Patient.fromJson(json)).toList();
// }

class DataTable extends StatefulWidget {
  @override
  _DataTableState createState() => _DataTableState();
}

class _DataTableState extends State<DataTable> {
  DTS _source = DTS([]);
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  bool isLoaded = false;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  void _sort<T>(
      Comparable<T> getField(Patient d), int columnIndex, bool ascending) {
    _source._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  Future<void> getData() async {
    final patients = await fetchData();
    //print(patients);
    if (!isLoaded) {
      setState(() {
        _source = DTS(patients);
        isLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return SingleChildScrollView(
      child: PaginatedDataTable(
        source: _source,
        rowsPerPage: _rowsPerPage,
        sortAscending: _sortAscending,
        sortColumnIndex: _sortColumnIndex,
        availableRowsPerPage: [10, 20, 30, 50],
        showFirstLastButtons: true,
        onRowsPerPageChanged: (newRowsPerPage) {
          setState(() {
            _rowsPerPage = newRowsPerPage!;
          });
        },
        columns: [
          DataColumn(
              label: Text(
                'ID',
              ),
              onSort: (int columnIndex, bool ascending) =>
                  _sort<num>((Patient d) => d.id, columnIndex, ascending)),
          DataColumn(
              label: Text('Company'),
              onSort: (int columnIndex, bool ascending) => _sort<String>(
                  (Patient d) => d.companyName, columnIndex, ascending)),
          DataColumn(
              label: Text('First name'),
              onSort: (int columnIndex, bool ascending) => _sort<String>(
                  (Patient d) => d.firstName, columnIndex, ascending)),
          DataColumn(
              label: Text('Last name'),
              onSort: (int columnIndex, bool ascending) => _sort<String>(
                  (Patient d) => d.lastName, columnIndex, ascending)),
          DataColumn(
              label: Text('Phone'),
              onSort: (int columnIndex, bool ascending) => _sort<String>(
                  (Patient d) => d.phone, columnIndex, ascending)),
          DataColumn(label: Text('Completed/Delete')),
        ],
      ),
    );
  }

  // void setSort(int i, bool asc) => setState(() {
  //       _sortIndex = i;
  //       _sortAsc = asc;
  //     });
}

class DTS extends DataTableSource {
  final List<Patient> _patients;
  DTS(this._patients);

  void _sort<T>(Comparable<T> getField(Patient d), bool ascending) {
    _patients.sort((Patient a, Patient b) {
      if (!ascending) {
        final Patient c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    final Patient patient = _patients[index];
    return DataRow(cells: [
      DataCell(Text(patient.id.toString())),
      DataCell(Text(patient.companyName)),
      DataCell(Text(patient.firstName)),
      DataCell(Text(patient.lastName)),
      DataCell(Text(patient.phone)),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
              width: 30,
              height: 30,
              child: FloatingActionButton(
                child: Icon(Icons.check),
                onPressed: () {
                  print('Add');
                },
              )),
          Container(
              width: 30,
              height: 30,
              child: FloatingActionButton(
                child: Icon(Icons.cancel_outlined),
                onPressed: () {
                  print('Remove');
                },
              ))
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _patients.length;

  @override
  int get selectedRowCount => 0;
}
//   @override
//   int get selectedRowCount => 0;

//   @override
//   Future<RemoteDataSourceDetails<Patient>> getNextPage(
//       NextPageRequest pageRequest) async {
//     //the remote data source has to support the pagaing and sorting
//     final queryParameter = <String, dynamic>{
//       'offset': pageRequest.offset.toString(),
//       'pageSize': pageRequest.pageSize.toString(),
//       'sortIndex': ((pageRequest.columnSortIndex ?? 0) + 1).toString(),
//       'sortAsc': ((pageRequest.sortAscending ?? true) ? 1 : 0).toString(),
//     };

//     final requestUri = Uri.https(
//       'example.devowl.de',
//       '',
//       queryParameter,
//     );

//     final response = await http.get(requestUri);
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return RemoteDataSourceDetails(
//         data['totalRows'],
//         (data['rows'] as List<dynamic>)
//             .map((json) => Patient.fromJson(json))
//             .toList(),
//       );
//     } else {
//       throw Exception('Unable to query remote server');
//     }
//   }
// }

// class DataTableDemo extends StatefulWidget {
//   const DataTableDemo({Key key}) : super(key: key);

//   @override
//   _DataTableDemoState createState() => _DataTableDemoState();
// }

// class _RestorableDessertSelections extends RestorableProperty<Set<int>> {
//   Set<int> _dessertSelections = {};

//   /// Returns whether or not a dessert row is selected by index.
//   bool isSelected(int index) => _dessertSelections.contains(index);

//   /// Takes a list of [_Dessert]s and saves the row indices of selected rows
//   /// into a [Set].
//   void setDessertSelections(List<_Dessert> desserts) {
//     final updatedSet = <int>{};
//     for (var i = 0; i < desserts.length; i += 1) {
//       var dessert = desserts[i];
//       if (dessert.selected) {
//         updatedSet.add(i);
//       }
//     }
//     _dessertSelections = updatedSet;
//     notifyListeners();
//   }

//   @override
//   Set<int> createDefaultValue() => _dessertSelections;

//   @override
//   Set<int> fromPrimitives(Object data) {
//     final selectedItemIndices = data as List<dynamic>;
//     _dessertSelections = {
//       ...selectedItemIndices.map<int>((dynamic id) => id as int),
//     };
//     return _dessertSelections;
//   }

//   @override
//   void initWithValue(Set<int> value) {
//     _dessertSelections = value;
//   }

//   @override
//   Object toPrimitives() => _dessertSelections.toList();
// }

// class _DataTableDemoState extends State<DataTableDemo> with RestorationMixin {
//   final _RestorableDessertSelections _dessertSelections =
//       _RestorableDessertSelections();
//   final RestorableInt _rowIndex = RestorableInt(0);
//   final RestorableInt _rowsPerPage =
//       RestorableInt(PaginatedDataTable.defaultRowsPerPage);
//   final RestorableBool _sortAscending = RestorableBool(true);
//   final RestorableIntN _sortColumnIndex = RestorableIntN(null);
//   _DessertDataSource _dessertsDataSource;

//   @override
//   String get restorationId => 'data_table_demo';

//   @override
//   void restoreState(RestorationBucket oldBucket, bool initialRestore) {
//     registerForRestoration(_dessertSelections, 'selected_row_indices');
//     registerForRestoration(_rowIndex, 'current_row_index');
//     registerForRestoration(_rowsPerPage, 'rows_per_page');
//     registerForRestoration(_sortAscending, 'sort_ascending');
//     registerForRestoration(_sortColumnIndex, 'sort_column_index');

//     _dessertsDataSource ??= _DessertDataSource(context);
//     switch (_sortColumnIndex.value) {
//       case 0:
//         _dessertsDataSource._sort<String>((d) => d.name, _sortAscending.value);
//         break;
//       case 1:
//         _dessertsDataSource._sort<num>((d) => d.calories, _sortAscending.value);
//         break;
//       case 2:
//         _dessertsDataSource._sort<num>((d) => d.fat, _sortAscending.value);
//         break;
//       case 3:
//         _dessertsDataSource._sort<num>((d) => d.carbs, _sortAscending.value);
//         break;
//       case 4:
//         _dessertsDataSource._sort<num>((d) => d.protein, _sortAscending.value);
//         break;
//       case 5:
//         _dessertsDataSource._sort<num>((d) => d.sodium, _sortAscending.value);
//         break;
//       case 6:
//         _dessertsDataSource._sort<num>((d) => d.calcium, _sortAscending.value);
//         break;
//       case 7:
//         _dessertsDataSource._sort<num>((d) => d.iron, _sortAscending.value);
//         break;
//     }
//     _dessertsDataSource.updateSelectedDesserts(_dessertSelections);
//     _dessertsDataSource.addListener(_updateSelectedDessertRowListener);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _dessertsDataSource ??= _DessertDataSource(context);
//     _dessertsDataSource.addListener(_updateSelectedDessertRowListener);
//   }

//   void _updateSelectedDessertRowListener() {
//     _dessertSelections.setDessertSelections(_dessertsDataSource._desserts);
//   }

//   void _sort<T>(
//     Comparable<T> Function(_Dessert d) getField,
//     int columnIndex,
//     bool ascending,
//   ) {
//     _dessertsDataSource._sort<T>(getField, ascending);
//     setState(() {
//       _sortColumnIndex.value = columnIndex;
//       _sortAscending.value = ascending;
//     });
//   }

//   @override
//   void dispose() {
//     _rowsPerPage.dispose();
//     _sortColumnIndex.dispose();
//     _sortAscending.dispose();
//     _dessertsDataSource.removeListener(_updateSelectedDessertRowListener);
//     _dessertsDataSource.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final localizations = GalleryLocalizations.of(context);
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text(localizations.demoDataTableTitle),
//       ),
//       body: Scrollbar(
//         child: ListView(
//           restorationId: 'data_table_list_view',
//           padding: const EdgeInsets.all(16),
//           children: [
//             PaginatedDataTable(
//               header: Text(localizations.dataTableHeader),
//               rowsPerPage: _rowsPerPage.value,
//               onRowsPerPageChanged: (value) {
//                 setState(() {
//                   _rowsPerPage.value = value;
//                 });
//               },
//               initialFirstRowIndex: _rowIndex.value,
//               onPageChanged: (rowIndex) {
//                 setState(() {
//                   _rowIndex.value = rowIndex;
//                 });
//               },
//               sortColumnIndex: _sortColumnIndex.value,
//               sortAscending: _sortAscending.value,
//               onSelectAll: _dessertsDataSource._selectAll,
//               columns: [
//                 DataColumn(
//                   label: Text(localizations.dataTableColumnDessert),
//                   onSort: (columnIndex, ascending) =>
//                       _sort<String>((d) => d.name, columnIndex, ascending),
//                 ),
//                 DataColumn(
//                   label: Text(localizations.dataTableColumnCalories),
//                   numeric: true,
//                   onSort: (columnIndex, ascending) =>
//                       _sort<num>((d) => d.calories, columnIndex, ascending),
//                 ),
//                 DataColumn(
//                   label: Text(localizations.dataTableColumnFat),
//                   numeric: true,
//                   onSort: (columnIndex, ascending) =>
//                       _sort<num>((d) => d.fat, columnIndex, ascending),
//                 ),
//                 DataColumn(
//                   label: Text(localizations.dataTableColumnCarbs),
//                   numeric: true,
//                   onSort: (columnIndex, ascending) =>
//                       _sort<num>((d) => d.carbs, columnIndex, ascending),
//                 ),
//                 DataColumn(
//                   label: Text(localizations.dataTableColumnProtein),
//                   numeric: true,
//                   onSort: (columnIndex, ascending) =>
//                       _sort<num>((d) => d.protein, columnIndex, ascending),
//                 ),
//                 DataColumn(
//                   label: Text(localizations.dataTableColumnSodium),
//                   numeric: true,
//                   onSort: (columnIndex, ascending) =>
//                       _sort<num>((d) => d.sodium, columnIndex, ascending),
//                 ),
//                 DataColumn(
//                   label: Text(localizations.dataTableColumnCalcium),
//                   numeric: true,
//                   onSort: (columnIndex, ascending) =>
//                       _sort<num>((d) => d.calcium, columnIndex, ascending),
//                 ),
//                 DataColumn(
//                   label: Text(localizations.dataTableColumnIron),
//                   numeric: true,
//                   onSort: (columnIndex, ascending) =>
//                       _sort<num>((d) => d.iron, columnIndex, ascending),
//                 ),
//               ],
//               source: _dessertsDataSource,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _Dessert {
//   _Dessert(
//     this.name,
//     this.calories,
//     this.fat,
//     this.carbs,
//     this.protein,
//     this.sodium,
//     this.calcium,
//     this.iron,
//   );

//   final String name;
//   final int calories;
//   final double fat;
//   final int carbs;
//   final double protein;
//   final int sodium;
//   final int calcium;
//   final int iron;
//   bool selected = false;
// }

// class _DessertDataSource extends DataTableSource {
//   _DessertDataSource(this.context) {
//     final localizations = GalleryLocalizations.of(context);
//     _desserts = <_Dessert>[
//       _Dessert(
//         localizations.dataTableRowFrozenYogurt,
//         159,
//         6.0,
//         24,
//         4.0,
//         87,
//         14,
//         1,
//       ),
//       _Dessert(
//         localizations.dataTableRowIceCreamSandwich,
//         237,
//         9.0,
//         37,
//         4.3,
//         129,
//         8,
//         1,
//       ),
//       _Dessert(
//         localizations.dataTableRowEclair,
//         262,
//         16.0,
//         24,
//         6.0,
//         337,
//         6,
//         7,
//       ),
//       _Dessert(
//         localizations.dataTableRowCupcake,
//         305,
//         3.7,
//         67,
//         4.3,
//         413,
//         3,
//         8,
//       ),
//       _Dessert(
//         localizations.dataTableRowGingerbread,
//         356,
//         16.0,
//         49,
//         3.9,
//         327,
//         7,
//         16,
//       ),
//       _Dessert(
//         localizations.dataTableRowJellyBean,
//         375,
//         0.0,
//         94,
//         0.0,
//         50,
//         0,
//         0,
//       ),
//       _Dessert(
//         localizations.dataTableRowLollipop,
//         392,
//         0.2,
//         98,
//         0.0,
//         38,
//         0,
//         2,
//       ),
//       _Dessert(
//         localizations.dataTableRowHoneycomb,
//         408,
//         3.2,
//         87,
//         6.5,
//         562,
//         0,
//         45,
//       ),
//       _Dessert(
//         localizations.dataTableRowDonut,
//         452,
//         25.0,
//         51,
//         4.9,
//         326,
//         2,
//         22,
//       ),
//       _Dessert(
//         localizations.dataTableRowApplePie,
//         518,
//         26.0,
//         65,
//         7.0,
//         54,
//         12,
//         6,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithSugar(
//           localizations.dataTableRowFrozenYogurt,
//         ),
//         168,
//         6.0,
//         26,
//         4.0,
//         87,
//         14,
//         1,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithSugar(
//           localizations.dataTableRowIceCreamSandwich,
//         ),
//         246,
//         9.0,
//         39,
//         4.3,
//         129,
//         8,
//         1,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithSugar(
//           localizations.dataTableRowEclair,
//         ),
//         271,
//         16.0,
//         26,
//         6.0,
//         337,
//         6,
//         7,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithSugar(
//           localizations.dataTableRowCupcake,
//         ),
//         314,
//         3.7,
//         69,
//         4.3,
//         413,
//         3,
//         8,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithSugar(
//           localizations.dataTableRowGingerbread,
//         ),
//         345,
//         16.0,
//         51,
//         3.9,
//         327,
//         7,
//         16,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithSugar(
//           localizations.dataTableRowJellyBean,
//         ),
//         364,
//         0.0,
//         96,
//         0.0,
//         50,
//         0,
//         0,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithSugar(
//           localizations.dataTableRowLollipop,
//         ),
//         401,
//         0.2,
//         100,
//         0.0,
//         38,
//         0,
//         2,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithSugar(
//           localizations.dataTableRowHoneycomb,
//         ),
//         417,
//         3.2,
//         89,
//         6.5,
//         562,
//         0,
//         45,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithSugar(
//           localizations.dataTableRowDonut,
//         ),
//         461,
//         25.0,
//         53,
//         4.9,
//         326,
//         2,
//         22,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithSugar(
//           localizations.dataTableRowApplePie,
//         ),
//         527,
//         26.0,
//         67,
//         7.0,
//         54,
//         12,
//         6,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithHoney(
//           localizations.dataTableRowFrozenYogurt,
//         ),
//         223,
//         6.0,
//         36,
//         4.0,
//         87,
//         14,
//         1,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithHoney(
//           localizations.dataTableRowIceCreamSandwich,
//         ),
//         301,
//         9.0,
//         49,
//         4.3,
//         129,
//         8,
//         1,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithHoney(
//           localizations.dataTableRowEclair,
//         ),
//         326,
//         16.0,
//         36,
//         6.0,
//         337,
//         6,
//         7,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithHoney(
//           localizations.dataTableRowCupcake,
//         ),
//         369,
//         3.7,
//         79,
//         4.3,
//         413,
//         3,
//         8,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithHoney(
//           localizations.dataTableRowGingerbread,
//         ),
//         420,
//         16.0,
//         61,
//         3.9,
//         327,
//         7,
//         16,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithHoney(
//           localizations.dataTableRowJellyBean,
//         ),
//         439,
//         0.0,
//         106,
//         0.0,
//         50,
//         0,
//         0,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithHoney(
//           localizations.dataTableRowLollipop,
//         ),
//         456,
//         0.2,
//         110,
//         0.0,
//         38,
//         0,
//         2,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithHoney(
//           localizations.dataTableRowHoneycomb,
//         ),
//         472,
//         3.2,
//         99,
//         6.5,
//         562,
//         0,
//         45,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithHoney(
//           localizations.dataTableRowDonut,
//         ),
//         516,
//         25.0,
//         63,
//         4.9,
//         326,
//         2,
//         22,
//       ),
//       _Dessert(
//         localizations.dataTableRowWithHoney(
//           localizations.dataTableRowApplePie,
//         ),
//         582,
//         26.0,
//         77,
//         7.0,
//         54,
//         12,
//         6,
//       ),
//     ];
//   }

//   final BuildContext context;
//   List<_Dessert> _desserts;

//   void _sort<T>(Comparable<T> Function(_Dessert d) getField, bool ascending) {
//     _desserts.sort((a, b) {
//       final aValue = getField(a);
//       final bValue = getField(b);
//       return ascending
//           ? Comparable.compare(aValue, bValue)
//           : Comparable.compare(bValue, aValue);
//     });
//     notifyListeners();
//   }

//   int _selectedCount = 0;
//   void updateSelectedDesserts(_RestorableDessertSelections selectedRows) {
//     _selectedCount = 0;
//     for (var i = 0; i < _desserts.length; i += 1) {
//       var dessert = _desserts[i];
//       if (selectedRows.isSelected(i)) {
//         dessert.selected = true;
//         _selectedCount += 1;
//       } else {
//         dessert.selected = false;
//       }
//     }
//     notifyListeners();
//   }

//   @override
//   DataRow getRow(int index) {
//     final format = NumberFormat.decimalPercentPattern(
//       locale: GalleryOptions.of(context).locale.toString(),
//       decimalDigits: 0,
//     );
//     assert(index >= 0);
//     if (index >= _desserts.length) return null;
//     final dessert = _desserts[index];
//     return DataRow.byIndex(
//       index: index,
//       selected: dessert.selected,
//       onSelectChanged: (value) {
//         if (dessert.selected != value) {
//           _selectedCount += value ? 1 : -1;
//           assert(_selectedCount >= 0);
//           dessert.selected = value;
//           notifyListeners();
//         }
//       },
//       cells: [
//         DataCell(Text(dessert.name)),
//         DataCell(Text('${dessert.calories}')),
//         DataCell(Text(dessert.fat.toStringAsFixed(1))),
//         DataCell(Text('${dessert.carbs}')),
//         DataCell(Text(dessert.protein.toStringAsFixed(1))),
//         DataCell(Text('${dessert.sodium}')),
//         DataCell(Text(format.format(dessert.calcium / 100))),
//         DataCell(Text(format.format(dessert.iron / 100))),
//       ],
//     );
//   }

//   @override
//   int get rowCount => _desserts.length;

//   @override
//   bool get isRowCountApproximate => false;

//   @override
//   int get selectedRowCount => _selectedCount;

//   void _selectAll(bool checked) {
//     for (final dessert in _desserts) {
//       dessert.selected = checked;
//     }
//     _selectedCount = checked ? _desserts.length : 0;
//     notifyListeners();
//   }
// }
