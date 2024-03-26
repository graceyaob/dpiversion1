import 'package:dpiversion1/components/PagesCarnet/constantes.dart';
import 'package:dpiversion1/data/models/models_database.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dpiversion1/components/buttonFacture.dart';
import 'package:dpiversion1/components/function404.dart';
import 'package:dpiversion1/components/home/containerImage.dart';
import 'package:dpiversion1/components/home/welcome.dart';
import 'package:dpiversion1/data/api/api.dart';
import 'package:dpiversion1/data/database/config.dart';
import 'package:dpiversion1/utils/config.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool uneConsultation = true;
  String id = '';
  Map constantes = {};
  String? poids = "";
  String? taille = "";
  String? imc = "";
  String diabete = "";
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
      setState(() {
        uneConsultation = true;
      });
      callDatabase();
      /* ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Connexion Internet désactivée'),
        duration: Duration(seconds: 3),
      ));*/
    } else {
      callApi();
    }
  }

  void callApi() {
    Database().getInfoBoxPatient().then((value) {
      setState(() {
        id = value.id;
      });

      Api().getApi(Api.consultationUrl(id)).then((value) {
        print(value);
        if (value == 404) {
          setState(() {
            uneConsultation = false;
          });
        } else {
          setState(() {
            constantes = value[0];

            Map constante = {
              "poids": constantes["fichepaiement"]["priseconstantes"]['poids']
                  .toString(),
              "taille": constantes["fichepaiement"]["priseconstantes"]['taille']
                  .toString(),
              "imc": constantes["fichepaiement"]["priseconstantes"]['imc']
                  .toString(),
              "diabete": constantes['diabete']
            };
            if (constante == Null || constante.isEmpty) {
              callDatabase();
            } else {
              Database().insertAfterLoginBoxConstance(constante);
              callDatabase();
            }
          });
        }
      });
    });
  }

  void callDatabase() {
    Database().getInfoBoxConstante().then((value) {
      setState(() {
        poids = value.poids;
        imc = value.imc;
        taille = value.taille;
        diabete = value.diabete;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Config.widthSize * 0.005,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Welcome(
                columnVisible: true,
                selection: false,
              ), // Placer Welcome en dehors du StreamBuilder
              StreamBuilder(
                stream: connectivityStream.stream,
                builder: (context, snapshot) {
                  //quand la connection est active
                  if (snapshot.connectionState == ConnectionState.active) {
                    var result = snapshot.data;
                    //quand la connexion se désactive
                    if (result == ConnectivityResult.none) {
                      return derniereConstante();
                    } else {
                      return derniereConstante();
                    }
                  }
                  //quand il n'y a pas connexion

                  else {
                    return derniereConstante();
                  }
                },
              ),
              Config.spaceSmall,
              Padding(
                padding: EdgeInsets.only(left: Config.widthSize * 0.70),
                child: ButtonFacture(
                  fondBouton: Config.couleurPrincipale,
                  couleurEcriture: Colors.white,
                  title: "Facture",
                  onPressed: () {
                    Navigator.of(context).pushNamed("recu");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget derniereConstante() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Config.widthSize * 0.05,
              vertical: Config.widthSize * 0.05,
            ),
            child: uneConsultation
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Mes dernières constantes",
                        style: TextStyle(
                          color: const Color(0xFF655F5F),
                          fontSize: Config.widthSize * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Config.spaceMeduim,
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Config.widthSize * 0.05,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ContainerImage(
                                  image: "assets/images/haltere.png",
                                  titre: "Mon poids",
                                  valeur: "$poids kg",
                                ),
                                ContainerImage(
                                  image: "assets/images/taille.png",
                                  titre: "Ma taille",
                                  valeur: "$taille cm",
                                ),
                              ],
                            ),
                            Config.spaceMeduim,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ContainerImage(
                                  image: "assets/images/formegros.png",
                                  titre: "IMC",
                                  valeur: "$imc kg/m²",
                                ),
                                ContainerImage(
                                  image: "assets/images/sucre.png",
                                  titre: "Diabétique",
                                  valeur: diabete,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : ErrorFunction(
                    message: "Aucuns parametres enregistrés",
                    height: Config.heightSize * 0.4,
                  ),
          ),
        ],
      ),
    );
  }
}
