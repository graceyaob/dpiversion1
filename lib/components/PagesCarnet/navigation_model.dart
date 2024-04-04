import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NavigationModel {
  String title;
  IconData icon;

  NavigationModel({required this.title, required this.icon});
}

List<NavigationModel> navigationItems = [
  NavigationModel(title: "constantes", icon: Icons.show_chart),
  NavigationModel(title: "Symptomes", icon: Icons.self_improvement),
  NavigationModel(title: "Examens", icon: Icons.assignment),
  NavigationModel(title: "Diagnostiques", icon: Icons.healing),
  NavigationModel(title: "Prescriptions", icon: Icons.description),
];
