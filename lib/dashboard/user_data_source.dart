import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'user_model.dart';

class UserDataSource extends DataGridSource {
  List<DataGridRow> _users = [];

  UserDataSource(List<UserModel> users) {
    _users = users.map<DataGridRow>((user) {
      return DataGridRow(cells: [
        DataGridCell<String>(columnName: 'firstName', value: user.firstName),
        DataGridCell<String>(columnName: 'lastName', value: user.lastName),
        DataGridCell<String>(columnName: 'mobile', value: user.mobile),
        DataGridCell<String>(columnName: 'whatsapp', value: user.whatsapp),
        DataGridCell<String>(columnName: 'aadhaar', value: user.aadhaar),
        DataGridCell<String>(columnName: 'role', value: user.role),
        DataGridCell<int>(columnName: 'points', value: user.points),
        DataGridCell<int>(
            columnName: 'pointsRedeemed', value: user.pointsRedeemed),
        DataGridCell<String>(columnName: 'pincode', value: user.pincode),
        DataGridCell<String>(columnName: 'state', value: user.state),
        DataGridCell<String>(columnName: 'district', value: user.district),
        DataGridCell<String>(columnName: 'city', value: user.city),
        DataGridCell<String>(columnName: 'address', value: user.address),
        DataGridCell<String>(
            columnName: 'createdAt', value: user.createdAt.toDate().toString()),
        DataGridCell<String>(
            columnName: 'isAdmin', value: user.isAdmin ? "Yes" : "No"),
      ]);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _users;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((cell) {
      return Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(cell.value.toString()),
      );
    }).toList());
  }
}
