import 'package:dpiversion1/data/api/api.dart';
import 'package:dpiversion1/data/database/config.dart';
import 'package:dpiversion1/components/PagesCarnet/cadre.dart';
import 'package:dpiversion1/utils/config.dart';
import 'package:flutter/material.dart';

class Prescriptions extends StatefulWidget {
  const Prescriptions({Key? key}) : super(key: key);

  @override
  State<Prescriptions> createState() => _PrescriptionsState();
}

class _PrescriptionsState extends State<Prescriptions> {
  String fiche = "";
  List prescriptions = [];
  bool unePrescription = true;

  @override
  void initState() {
    MySharedPreferences.loadData().then((value) {
      setState(() {
        if (value != null) {
          fiche = value;
          Api().getApi(Api.prescriptionUrl(fiche)).then((value) {
            print("value:$value");
            setState(() {
              prescriptions = value;
              if (prescriptions.isEmpty) {
                unePrescription = false;
              }
            });
          });
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // pacourir mes prescriptions
    Future<List<Widget>> buildPrescriptions(List prescriptions) async {
      List<Widget> ordonnance = [];
      for (int index = 0; index < prescriptions.length; index++) {
        Map prescription = prescriptions[index];
        String idmedicament = prescription["medicament"];
        String idposologie = prescription["posologie"];
        int duree = prescription["duree"];
        String quantite = prescription["quantite"];

        Map medicament = await Api().getApi(Api.medicamentUrl(idmedicament));
        Map posologie = await Api().getApi(Api.posologieUrl(idposologie));

        ordonnance.add(InstructionLine(
          medicament: medicament["libelle_produit"],
          posologie: posologie["libelle"],
          duree: duree,
          quantite: quantite,
        ));
      }
      return ordonnance;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Cadre(titre: "Prescription"),
            Expanded(
              child: Container(
                width: Config.widthSize * 0.8,
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    width: Config.widthSize * 1.0,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        height: Config.heightSize * 1,
                        //la vue ordonnance
                        child: FutureBuilder<List<Widget>>(
                          future: buildPrescriptions(prescriptions),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Widget>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text("Erreur: ${snapshot.error}");
                            } else {
                              if (unePrescription) {
                                return Column(
                                  children: snapshot.data!,
                                );
                              } else {
                                return Text(
                                  "Aucune prescription disponible",
                                  style: TextStyle(fontSize: 16),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Codes des différentes blocs de mon ordonnances
class InstructionLine extends StatelessWidget {
  final String medicament;
  final String posologie;
  final int duree;
  final String quantite;

  InstructionLine({
    required this.medicament,
    required this.posologie,
    required this.duree,
    required this.quantite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Médicament: $medicament",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4.0),
          Text(
            "Posologie: $posologie",
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 4.0),
          Text(
            "Durée: $duree jours",
            style: const TextStyle(color: Colors.blue),
          ),
          const SizedBox(height: 4.0),
          Text(
            "Quantité: $quantite",
            style: const TextStyle(color: Colors.green),
          ),
        ],
      ),
    );
  }
}
