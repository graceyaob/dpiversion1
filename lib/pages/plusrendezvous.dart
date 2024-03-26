import 'package:dpiversion1/components/button.dart';
import 'package:dpiversion1/components/champsSelection.dart';
import 'package:dpiversion1/data/api/api.dart';
import 'package:dpiversion1/data/database/config.dart';
import 'package:dpiversion1/data/models/models_api.dart';
import 'package:dpiversion1/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class AppointplusPage extends StatefulWidget {
  const AppointplusPage({super.key});

  @override
  State<AppointplusPage> createState() => _AppointplusPageState();
}

class _AppointplusPageState extends State<AppointplusPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> itemsVilles = [""];
  List listVille = [];
  List<String> itemsServices = [""];
  List listService = [];
  List<String> itemscentres = [""];
  List listCentre = [];
  List<String> itemsPrestations = [""];
  List listPrestations = [];
  TextEditingController prix = TextEditingController();
  String idService = "";
  String idPrestation = "";
  String idPatient = "";
  String idCentreSante = "";
  String idMontant = "";
  ResponseRequest sortir = ResponseRequest(status: 0);

  @override
  void initState() {
    Api().getApi(Api.villesUrl()).then((value) {
      setState(() {
        listVille = value;

        listVille.forEach((item) {
          itemsVilles.add(item["libelle"]);
        });
      });
    });
    Database().getInfoBoxPatient().then((value) {
      setState(() {
        idPatient = value.id;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Fiche de paiement",
            style: TextStyle(
                color: Config.couleurPrincipale,
                fontSize: Config.widthSize * 0.05),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(children: [
              //cadre de design
              Container(
                  width: double.infinity,
                  height: Config.heightSize * 0.1,
                  decoration: const BoxDecoration(
                      color: Config.couleurPrincipale,
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(100))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Ionicons.document_text_outline,
                        color: Colors.white,
                        size: Config.widthSize * 0.1,
                      ),
                      Text(
                        "Formulaire de création de fiche de paiement",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Config.widthSize * 0.038),
                      ),
                    ],
                  )),
              SizedBox(
                height: 10,
              ),
              formulaire()
            ]),
          ),
        ));
  }

  Widget formulaire() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Config.widthSize * 0.05),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            ChampSelect(
              items: itemsVilles,
              libelle: "Ville",
              readOnly: false,
              formulaireConsultation: true,
              onValueChanged: (selectedCentre) {
                //parcour ma liste de ville si l'élement selectionné = ville[libelle],appelle les centres qui sont dans cette ville
                listVille.forEach((ville) {
                  if (ville["libelle"] == selectedCentre) {
                    Api().getApi(Api.centreSanteUrl(ville["id"])).then((value) {
                      setState(() {
                        listCentre = value;
                        itemscentres.clear();
                        itemscentres.add("");
                      });
// on parcour la liste des centre et on ajoute les centre dans mon itemscentres
                      listCentre.forEach((centre) {
                        setState(() {
                          itemscentres.add(centre["libelle"]);
                        });
                      });
                    });
                  }
                });
              },
            ),
            ChampSelect(
              items: itemscentres,
              libelle: "Centre de santé",
              readOnly: false,
              formulaireConsultation: true,
              onValueChanged: (selectedCentre) {
                listCentre.forEach((centre) {
                  if (centre["libelle"] == selectedCentre) {
                    setState(() {
                      idCentreSante = centre["id"];
                    });
                    Api().getApi(Api.serviceUrl(centre["id"])).then((value) {
                      setState(() {
                        listService = value;
                        itemsServices.clear();
                        itemsServices.add("");
                      });

                      listService.forEach((service) {
                        setState(() {
                          itemsServices.add(service["libelle"]);
                        });
                      });
                      setState(() {
                        itemsServices
                            .removeWhere((element) => element == "CAISSE");
                      });
                    });
                  } else {
                    print("désolé");
                  }
                });
              },
            ),
            ChampSelect(
              items: itemsServices,
              libelle: "Spécialité",
              readOnly: false,
              formulaireConsultation: true,
              onValueChanged: (selectedSpecialite) {
                listService.forEach((service) {
                  if (service["libelle"] == selectedSpecialite) {
                    setState(() {
                      idService = service['id'];

                      Api()
                          .getApi(Api.prestationUrl(service["id"]))
                          .then((value) {
                        setState(() {
                          listPrestations = value;
                          itemsPrestations.clear();
                          itemsPrestations.add("");
                        });
                        listPrestations.forEach((prestation) {
                          setState(() {
                            itemsPrestations
                                .add(prestation["motif"]["libelle"]);
                          });
                        });
                      });
                    });
                  }
                });
              },
            ),
            ChampSelect(
              items: itemsPrestations,
              libelle: "prestation",
              readOnly: false,
              formulaireConsultation: true,
              onValueChanged: (selectedPrestation) {
                listPrestations.forEach((prestation) {
                  if (prestation["motif"]["libelle"] == selectedPrestation) {
                    setState(() {
                      idPrestation = prestation["id"];
                      idMontant = prestation["motif"]["cout"];
                      prix.text = "$idMontant fcfa";
                    });
                  }
                });
              },
            ),
            Text("Prix de la prestation"),
            TextField(
              controller: prix,
              enabled: false,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Colors.black),
              )),
            ),
            Config.spaceSmall,
            Button(
                width: double.infinity,
                title: "Enregistrer",
                disable: false,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    Map body = {
                      "fiches": {
                        "assigne": null,
                        "assurancepatient": null,
                        "cas_social": false,
                        "centre_demande": null,
                        "centresante": idCentreSante,
                        "gratuite_cible": true,
                        "montant_a_payer": idMontant,
                        "montant_assure": 0,
                        "montant_gratuite": 0,
                        "montant_total": 0,
                        "motif": null,
                        "motif_examens": [idPrestation],
                        "nature": null,
                        "patient": idPatient,
                        "prescripteur": null,
                        "prestations": [
                          {
                            "montant_a_payer": idMontant,
                            "montant_assure": 0,
                            "montant_gratuite": 2000,
                            "motif": idPrestation,
                            "prix_unitaire": 0,
                            "quantite": 1,
                            "taux_couverture": 0,
                            "total_partiel": 0
                          }
                        ],
                        "service": idService,
                        "service_code": "mobile",
                        "tarif_reduit": false,
                        "taux_couverture": 0,
                        "valeur_motif": null
                      }
                    };
                    sortir =
                        await Api().postApiDeux(Api.fichePaiementUrl(), body);

                    if (sortir.status == 200) {
                      Map<String, dynamic>? data = sortir.data;
                      showDialog(
                          context: context,
                          builder: (BuildContext) {
                            return AlertDialog(
                              content: Column(
                                children: [
                                  Text("Opération: Succès"),
                                  Text(
                                      "Reçu N°${data?["fichepaiement"]["reference"]}"),
                                  Text(
                                      "consultation en ${data?["fichepaiement"]["service"]["libelle"]}"),
                                ],
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Modifier")),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext) {
                                                return AlertDialog(
                                                  content: Text(
                                                      "Voulez-vous faire le paiement en ligne ?"),
                                                  actions: [
                                                    Row(
                                                      children: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pushNamed(
                                                                      "paiement");
                                                            },
                                                            child: Text("Oui")),
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pushNamed(
                                                                      "recu");
                                                            },
                                                            child: Text("Non"))
                                                      ],
                                                    )
                                                  ],
                                                );
                                              });
                                        },
                                        child: Text("Suivant")),
                                  ],
                                )
                              ],
                            );
                          });
                    } else {
                      // ignore: use_build_context_synchronously
                      showAlertDialog(context, sortir.message!);
                    }
                  }
                })
          ],
        ),
      ),
    );
  }
}
