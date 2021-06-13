import 'package:flutter/material.dart';

class Patient {
  final int id;
  final String companyName;
  final String firstName;
  final String lastName;
  final String phone;

  const Patient(
    this.id,
    this.companyName,
    this.firstName,
    this.lastName,
    this.phone,
  );

  DataRow getRow() {
    return DataRow(cells: [
      DataCell(Text(id.toString())),
      DataCell(Text(companyName)),
      DataCell(Text(firstName)),
      DataCell(Text(lastName)),
      DataCell(Text(phone)),
    ]);
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      json['id'] as int,
      json['companyName'] as String,
      json['firstName'] as String,
      json['lastName'] as String,
      json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
    };
  }
}
