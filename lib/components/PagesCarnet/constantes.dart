import 'package:dpiversion1/data/api/api.dart';
import 'package:dpiversion1/data/database/config.dart';
import 'package:dpiversion1/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class Constante extends StatefulWidget {
  const Constante({super.key});

  @override
  State<Constante> createState() => _ConstanteState();
}

class _ConstanteState extends State<Constante> {
  Map constantes = {};
  String fichePaiement = "";
  double? poids;
  double? temperature;
  double? taille;
  double? imc;
  double? tensionArterielle;
  double? pouls;
  StreamController<ConnectivityResult> connectivityStream =
      StreamController<ConnectivityResult>();

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      connectivityStream.add(result);
    });
  }

  void checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
    } else {
      callApi();
    }
  }

  void callApi() {
    MySharedPreferences.loadData().then((value) {
      setState(() {
        if (value != null) {
          fichePaiement = value;
          print(fichePaiement);
          Api().getApi(Api.constanteAcceuilUrl(fichePaiement)).then((value) {
            print(value);
            setState(() {
              for (var i = 0; i < value.length; i++) {
                constantes = value[value.length - 1];
                poids = constantes["poids"];
                temperature = constantes["temperature"];
                taille = constantes["taille"];
                imc = constantes["imc"];

                tensionArterielle = constantes["tension_arteriel_systolique"];

                pouls = constantes["pouls"];
              }
            });
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          decoration: BoxDecoration(border: Border.all()),
          margin: EdgeInsets.only(
              left: Config.widthSize * 0.02, right: Config.widthSize * 0.02),
          child: Column(
            children: [
              Card(
                color: Color(0xFFE9F7FF),
                child: ListTile(
                  title: Text(
                    "Constante",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B82F6),
                        fontSize: Config.widthSize * 0.05),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [Text("Température"), Text("$temperature °")],
              ),
              Config.spaceSmall,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [Text("Poids"), Text("$poids Kg")],
              ),
              Config.spaceSmall,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [Text("Taille"), Text("$taille cm")],
              ),
              Config.spaceSmall,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [Text("IMC"), Text("$imc Kg/m²")],
              ),
              Config.spaceSmall,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Tension Arterielle"),
                  Text("$tensionArterielle mmHg"),
                ],
              ),
              Config.spaceSmall,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [Text("Pouls"), Text("$pouls Btt/mn")],
              ),
            ],
          ),
        ));
  }
}
