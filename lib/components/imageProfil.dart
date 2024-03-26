import 'package:flutter/material.dart';

class CadrePhoto extends StatefulWidget {
  const CadrePhoto({super.key, required this.raduis});
  final double raduis;

  @override
  State<CadrePhoto> createState() => _CadrePhotoState();
}

class _CadrePhotoState extends State<CadrePhoto> {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.raduis,
      backgroundImage: const AssetImage(
        "assets/images/portrait_femme.jpg",
      ),
    );
  }
}
