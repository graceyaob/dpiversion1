import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NavigationModel {
  String title;
  IconData icon;

  NavigationModel({required this.title, required this.icon});
}

List<NavigationModel> navigationItems = [
  NavigationModel(title: "constantes", icon: Icons.insert_chart),
  NavigationModel(title: "Symptomes", icon: Icons.insert_chart),
  NavigationModel(title: "Examens", icon: Icons.insert_chart),
  NavigationModel(title: "Diagnostiques", icon: Icons.insert_chart),
  NavigationModel(title: "Prescriptions", icon: Icons.insert_chart),
];
