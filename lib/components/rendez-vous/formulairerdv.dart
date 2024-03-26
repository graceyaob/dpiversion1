import 'package:dpiversion1/components/button.dart';
import 'package:dpiversion1/components/champsSelection.dart';
import 'package:dpiversion1/data/api/api.dart';
import 'package:dpiversion1/data/database/config.dart';
import 'package:dpiversion1/data/models/models_api.dart';
import 'package:dpiversion1/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:intl/intl.dart';
import 'package:date_time_field/date_time_field.dart';

class FormulaireRdvPage extends StatefulWidget {
  const FormulaireRdvPage({super.key});

  @override
  State<FormulaireRdvPage> createState() => _FormulaireRdvPageState();
}

class _FormulaireRdvPageState extends State<FormulaireRdvPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> itemsVilles = [""];
  List listVille = [];
  List<String> itemsServices = [""];
  List listService = [];
  List<String> itemscentres = [""];
  List listCentre = [];
  List<String> itemsPrestations = [""];
  List<String> itemsMedecins = [""];
  List listPrestations = [];
  List listMedecins = [];
  TextEditingController prix = TextEditingController();
  String idService = "";
  String idPrestation = "";
  String idPatient = "";
  String idCentreSante = "";
  String idMontant = "";
  String idmedecin = "";
  ResponseRequest sortir = ResponseRequest(status: 0);
  DateTime? date;
  DateEditingController dateController = DateEditingController(
    date: DateTime.now(),
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2050, 4, 4),
    format: DateFormat('dd/MM/yyyy'),
  );

  @override
  void initState() {
    super.initState();
    loadVilles();
    loadIdPatient();
    dateController.addListener(() {
      setState(() {
        date = dateController.date;
      });
    });
  }

  void loadVilles() {
    Api().getApi(Api.villesUrl()).then((value) {
      setState(() {
        listVille = value;
        itemsVilles.clear();
        itemsVilles.add(""); // Ajoutez l'élément vide au début
        listVille.forEach((item) {
          if (!itemsVilles.contains(item["libelle"])) {
            itemsVilles.add(item["libelle"]);
          }
        });
        print(itemsVilles);
      });
    });
  }

  void loadIdPatient() {
    Database().getInfoBoxPatient().then((value) {
      setState(() {
        idPatient = value.id;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Rendez-vous",
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
                        "Formulaire de prise de rendez-vous",
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        print(listCentre);
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
                    Api().getApi(Api.serviceUrl(idCentreSante)).then((value) {
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

                      Api().getApi(Api.prestationUrl(idService)).then((value) {
                        setState(() {
                          listPrestations = value;
                          itemsPrestations.clear();
                          itemsPrestations.add("");
                        });

                        listPrestations.forEach((prestation) {
                          setState(() {
                            if (!itemsPrestations
                                .contains(prestation["motif"]["libelle"])) {
                              itemsPrestations
                                  .add(prestation["motif"]["libelle"]);
                            }
                          });
                        });
                      });

                      Api().getApi(Api.getMedecinUrl(idService)).then((value) {
                        setState(() {
                          print("idService = $idService");
                          listMedecins = value;
                          itemsMedecins.clear();
                          itemsMedecins.add("");
                        });

                        listMedecins.forEach((medecin) {
                          setState(() {
                            String nom =
                                "${medecin["first_name"]} ${medecin["last_name"]}";
                            if (!itemsMedecins.contains(nom)) {
                              itemsMedecins.add(nom);
                            }
                          });
                        });
                      });
                    });
                  }
                });
              },
            ),
            ChampSelect(
              items: itemsMedecins,
              libelle: "Choix du medecin",
              readOnly: false,
              formulaireConsultation: true,
              onValueChanged: (selectedMedecin) {
                listMedecins.forEach((medecin) {
                  String nom =
                      "${medecin["first_name"]} ${medecin["last_name"]}";
                  if (nom == selectedMedecin) {
                    setState(() {
                      idmedecin = medecin["id"];
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
                      print("idprestation = $idPrestation");
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
            Text("choisissez le jour du rendez-vous"),
            DateTimeField(
              controller: dateController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: dateController.clear,
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
            Config.spaceSmall,
            Button(
                width: double.infinity,
                title: "Suivant",
                disable: false,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    Map body = {
                      "datePrevue": "2024-03-28",
                      "heureDebut": "08:58",
                      "heureFin": "09:01",
                      "priorite": "N",
                      "typeRDV": "N",
                      "motif": "test",
                      "commentaire": "test",
                      "patient": "fcdd4a35-cb16-4f88-ac04-9983f17bc7be",
                      "medecin": "fff91868-b188-43e2-866e-cb84525ed5ad",
                      "service": idService
                    };

                    sortir = await Api().postApiDeux(Api.postRdv(), body);

                    if (sortir.status == 200) {
                      Map<String, dynamic>? data = sortir.data;
                      showDialog(
                          context: context,
                          builder: (BuildContext) {
                            return AlertDialog(
                              content: Text(
                                  "N° de la facture:${data?["fichepaiement"]["reference"]} pour la consultation en ${data?["fichepaiement"]["service"]["libelle"]}"),
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

//Dans cet exemple, nous avons utilisé Form pour englober le widget de sélection et le bouton de validation. Le widget DropdownButtonFormField est utilisé pour créer le champ de sélection, et ElevatedButton est utilisé pour le bouton de validation. Lorsque l'utilisateur sélectionne une option et appuie sur le bouton "Valider", les données sont validées et traitées.



