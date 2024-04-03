import 'package:dpiversion1/components/PagesCarnet/constantes.dart';
import 'package:dpiversion1/components/PagesCarnet/navBar.dart';
import 'package:dpiversion1/components/PagesCarnet/prescriptions.dart';
import 'package:dpiversion1/utils/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sidebar/sidebar.dart';

class InformationSante extends StatefulWidget {
  const InformationSante({Key? key}) : super(key: key);

  @override
  State<InformationSante> createState() => _InformationSanteState();
}

class _InformationSanteState extends State<InformationSante> {
  late Future<int> _indexFuture;

  @override
  void initState() {
    super.initState();

    _indexFuture = _getIndex();
  }

  Future<int> _getIndex() async {
    while (navBarKey.currentState == null) {
      await Future.delayed(Duration(milliseconds: 100)); // Attendre un peu
    }
    return navBarKey.currentState!.getCurrentSelectedIndex();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Config.couleurPrincipale,
        title: Text(
          "Consultation du 03-09-2024",
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          FutureBuilder<int>(
            future: _indexFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              }
              final index = snapshot.data!;
              return Container(
                color: Colors.white,
                child: index == 1 ? Constante() : Prescriptions(),
              );
            },
          ),
          NavBar(
            key: navBarKey,
          ),
        ],
      ),
    );
  }
}

Widget Bloc() {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: Colors.white24,
      child: Icon(
        CupertinoIcons.person,
        color: Colors.white,
      ),
    ),
    title: Text(
      "Yao",
      style: TextStyle(color: Colors.white),
    ),
    subtitle: Text("Patient", style: TextStyle(color: Colors.white)),
  );
}
