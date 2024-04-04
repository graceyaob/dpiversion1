import 'package:dpiversion1/components/PagesCarnet/collapsingListTile.dart';
import 'package:dpiversion1/components/PagesCarnet/constantes.dart';
import 'package:dpiversion1/components/PagesCarnet/examens.dart';
import 'package:dpiversion1/components/PagesCarnet/interrogatoire.dart';
import 'package:dpiversion1/components/PagesCarnet/navigation_model.dart';
import 'package:dpiversion1/components/PagesCarnet/prescriptions.dart';
import 'package:dpiversion1/components/imageProfil.dart';
import 'package:dpiversion1/data/database/config.dart';
import 'package:dpiversion1/utils/config.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final navBarKey = GlobalKey<_NavBarState>();

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> with SingleTickerProviderStateMixin {
  double maxWidth = 220.0;
  double minWidth = 70;
  bool isCollapsed = false; // permettre de réduire l'interface
  late Animation<double> widthAnimation;
  late Animation<double> widthContainer;
  late AnimationController _animationController;
  late int currentSelectedIndex;
  late String nom;

  @override
  void initState() {
    currentSelectedIndex = 0;
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    widthAnimation = Tween<double>(begin: maxWidth, end: minWidth)
        .animate(_animationController);
    widthContainer =
        Tween<double>(begin: 70, end: 500).animate(_animationController);
    Database().getInfoBoxPatient().then((value) {
      setState(() {
        nom = "${value.nom} ${value.prenoms}";
      });
    });

    super.initState();
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
          Container(
            padding: EdgeInsets.only(left: 60),
            color: Colors.white,
            child: currentSelectedIndex == 0
                ? Constante()
                : currentSelectedIndex == 1
                    ? Interrogatoire()
                    : currentSelectedIndex == 2
                        ? Examens()
                        : currentSelectedIndex == 3
                            ? Container()
                            : Prescriptions(),
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, widget) => getWidget(context, widget),
          )
        ],
      ),
    );
  }

  Widget getWidget(context, Widget) {
    return Material(
      elevation: 8,
      child: Container(
        width: widthAnimation.value,
        color: Config.couleurPrincipale,
        child: SafeArea(
          child: Column(
            children: [
              InkWell(
                child: AnimatedIcon(
                  icon: AnimatedIcons.close_menu,
                  progress: _animationController,
                  color: Colors.white,
                  size: 50,
                ),
                onTap: () {
                  setState(() {
                    isCollapsed = !isCollapsed;
                    isCollapsed
                        ? _animationController.forward()
                        : _animationController.reverse();
                  });
                },
              ),
              Bloc(),
              Divider(
                color: Colors.white54,
                height: 12,
              ),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, counter) {
                    return Divider(
                      height: 10,
                      color: Config.couleurPrincipale,
                    );
                  },
                  itemBuilder: (context, counter) {
                    return CollapsingListTile(
                        onTap: () {
                          setState(() {
                            currentSelectedIndex = counter;
                            print(currentSelectedIndex);
                          });
                        },
                        isSelected: currentSelectedIndex == counter,
                        title: navigationItems[counter].title,
                        icon: navigationItems[counter].icon,
                        animationController: _animationController);
                  },
                  itemCount: navigationItems.length,
                ),
              ),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget Bloc() {
    return ListTile(
      leading: CircleAvatar(
          backgroundColor: Colors.white24, child: CadrePhoto(raduis: 20)),
      title: (widthAnimation.value >= 220)
          ? Text(
              nom,
              style: TextStyle(color: Colors.white, fontSize: 10),
            )
          : Text(""),
      subtitle: (widthAnimation.value >= 220)
          ? Text("Mon carnet", style: TextStyle(color: Colors.white))
          : Text(""),
    );
  }
}
