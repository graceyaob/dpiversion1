import 'package:dpiversion1/utils/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CollapsingListTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final AnimationController animationController;
  bool isSelected = false;
  final Function() onTap;
  CollapsingListTile(
      {super.key,
      required this.title,
      required this.icon,
      required this.animationController,
      required this.isSelected,
      required this.onTap});

  @override
  State<CollapsingListTile> createState() => _CollapsingListTileState();
}

class _CollapsingListTileState extends State<CollapsingListTile>
    with SingleTickerProviderStateMixin {
  late Animation<double> widthAnimation;
  late Animation<double> sizedBoxAnimation;

  @override
  void initState() {
    widthAnimation =
        Tween<double>(begin: 250, end: 70).animate(widget.animationController);
    sizedBoxAnimation =
        Tween<double>(begin: 10, end: 0).animate(widget.animationController);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            color: widget.isSelected
                ? Colors.transparent.withOpacity(0.3)
                : Colors.transparent),
        width: widthAnimation.value,
        margin: EdgeInsets.symmetric(
          horizontal: 8,
        ),
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: widget.isSelected
                  ? Config.couleurBoutonSelectionner
                  : Colors.black12,
              size: 38,
            ),
            SizedBox(
              width: sizedBoxAnimation.value,
            ),
            (widthAnimation.value >= 220)
                ? Text(
                    widget.title,
                    style: widget.isSelected
                        ? TextStyle(
                            color: Config.couleurBoutonSelectionner,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)
                        : TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 20),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
