import 'package:dpiversion1/components/function404.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dpiversion1/data/api/api.dart';
import 'package:dpiversion1/data/database/config.dart';
import 'package:dpiversion1/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

class Calendrier extends StatefulWidget {
  const Calendrier({Key? key});

  @override
  State<Calendrier> createState() => _CalendrierState();
}

class _CalendrierState extends State<Calendrier> {
  late List<Appointment> _appointments = [];
  bool _isLoading = true; // Variable pour suivre l'état de chargement
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
        _appointments = [];
      });
    } else {
      _loadAppointments();
    }
  }

  Future<void> _loadAppointments() async {
    final List<Appointment> appointments = await getAppointments();
    setState(() {
      _appointments = appointments;
      _isLoading =
          false; // Mettez à jour l'état de chargement une fois le chargement terminé
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Afficher un indicateur de chargement si les rendez-vous sont en cours de chargement
          : _appointments.isEmpty
              ? ErrorFunction(
                  message: "Aucun rendez-vous trouvé",
                  height: Config.heightSize * 0.43,
                ) // Afficher un message si la liste est vide
              : StreamBuilder(
                  stream: connectivityStream.stream,
                  builder: (context, snapshot) {
                    //quand la connection est active
                    if (snapshot.connectionState == ConnectionState.active) {
                      var result = snapshot.data;
                      //quand la connexion se désactive
                      if (result == ConnectivityResult.none) {
                        return calendrier();
                      } else {
                        _loadAppointments();
                        return calendrier();
                      }
                    }
                    //quand il n'y a pas connexion

                    else {
                      return calendrier();
                    }
                  },
                ),
    );
  }

  Widget calendrier() {
    return SfCalendar(
      view: CalendarView.week,
      firstDayOfWeek: 1,
      dataSource: AppointSource(_appointments),
      // fonction pour afficher un boite a dialogue pour rendre les details des rendez vous visible
      onTap: (CalendarTapDetails details) {
        if (details.appointments != null && details.appointments!.isNotEmpty) {
          // Afficher une boîte de dialogue lorsque l'utilisateur clique sur un rendez-vous
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // Créer et retourner la boîte de dialogue
              return AlertDialog(
                title: Text("Rendez-vous"),
                content:
                    Text("Description: ${details.appointments![0].subject}"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Fermer la boîte de dialogue
                    },
                    child: Text('Fermer'),
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }
}

Future<List<Appointment>> getAppointments() async {
  final String id =
      await Database().getInfoBoxPatient().then((value) => value.id);
  final rendez =
      await Api().getApi(Api.rendezVousUrl(id)).then((value) => value);

  if (rendez == 404) {
    return []; // Retourner une liste vide si aucun rendez-vous n'est trouvé
  }

  final List<Appointment> rdvs = [];
  for (int index = 0; index < rendez.length; index++) {
    final Map unRdv = rendez[index];
    final DateTime rdv = DateTime.parse('${unRdv["datePrevue"]}');

    final String heureDebut = unRdv["heureDebut"];
    DateTime startime = DateFormat('HH:mm:ss').parse(heureDebut);
    startime = DateTime(rdv.year, rdv.month, rdv.day, startime.hour,
        startime.minute, startime.second);
    final String heureFin =
        unRdv["heureFin"] == null ? unRdv["heureDebut"] : unRdv["heureFin"];
    DateTime endtime = DateFormat('HH:mm:ss').parse(heureFin);
    startime = DateTime(rdv.year, rdv.month, rdv.day, startime.hour,
        startime.minute, startime.second);
    final String centre = await Api()
        .getApi(Api.centreSanteByIdUrl(unRdv["centresante"]))
        .then((value) => value["libelle"]);

    final servicerecupere = unRdv["service"];
    String service = "";

    if (servicerecupere == null || service.isEmpty) {
      service = "Medecine Génerale";
    } else {
      service = await Api()
          .getApi(Api.serviceByIdUrl(servicerecupere))
          .then((value) => value["libelle"]);
    }
    if (unRdv["rendezvous"] == false && unRdv["annuler"] == false) {
      rdvs.add(Appointment(
          startTime: startime,
          endTime: endtime,
          subject:
              'rendez-vous en $service à $centre de $heureDebut  - $heureFin',
          color: Colors.blue));
    }
  }

  return rdvs;
}

class AppointSource extends CalendarDataSource {
  AppointSource(List<Appointment> source) {
    appointments = source;
  }
}
