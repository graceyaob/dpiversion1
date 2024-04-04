import 'package:dpiversion1/components/PagesCarnet/navBar.dart';
import 'package:dpiversion1/components/connexion/modifier_MDP.dart';
import 'package:dpiversion1/components/rendez-vous/formulairerdv.dart';
import 'package:dpiversion1/components/rendez-vous/priseRDV.dart';
import 'package:dpiversion1/data/database/config.dart';
import 'package:dpiversion1/components/PagesCarnet/containerCarnet.dart';
import 'package:dpiversion1/pages/consultation.dart';
import 'package:dpiversion1/pages/containerApp.dart';
import 'package:dpiversion1/pages/detailRecu.dart';
import 'package:dpiversion1/pages/getStarted.dart';
import 'package:dpiversion1/pages/login.dart';
import 'package:dpiversion1/pages/modifInfo.dart';
import 'package:dpiversion1/pages/pageRecu.dart';
import 'package:dpiversion1/pages/paiementEnligne.dart';
import 'package:dpiversion1/pages/plusrendezvous.dart';
import 'package:dpiversion1/pages/rendezVous.dart';
import 'package:dpiversion1/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

int? islogged;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Database().initDatabase();
  int test = await Database().isLoggedBoxPatient();
  islogged = test;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Config.instance.init(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DPI MOBILE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Config.couleurPrincipale,
            selectedItemColor: Colors.white,
            showSelectedLabels: false,
            unselectedItemColor: Colors.black54,
            elevation: 10,
            type: BottomNavigationBarType.fixed),
        textTheme: GoogleFonts.poppinsTextTheme(),
        inputDecorationTheme: const InputDecorationTheme(
            focusColor: Config.couleurPrincipale,
            floatingLabelStyle: TextStyle(color: Config.couleurPrincipale)),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Config.couleurPrincipale,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const GetStarted(),
        "login": (context) => Login(
              visibility: true,
            ),
        'main': (context) => const ContainerApp(),
        'modifier': (context) => const LoginModif(),
        'modifInfo': (context) => const ModiInfo(),
        'prdv': (context) => const FormulaireRdvPage(),
        'calrdv': (context) => const PriseRdv(),
        'consultation': (context) => const ConsultationPage(),
        'rdv': (context) => const AppointPage(),
        "baseCarnet": (context) => const ContainerCarnet(),
        "paiement": (context) => const Paiement(),
        "recu": (context) => const RecuPaiement(),
        'detailRecu': (context) => DetailRecu(
            payementeffectue: bool.parse(
                ModalRoute.of(context)?.settings.arguments.toString() ??
                    'false')),
        /*"detailRecu": (context) => DetailRecu(
              payementeffectue: false,
            ),*/
        "punrdv": (context) => const AppointplusPage(),
        "info": (context) => NavBar()
      },
    );
  }
}
