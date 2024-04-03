import 'package:flutter/material.dart';
import 'package:dpiversion1/utils/config.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

class ChampSelect extends StatefulWidget {
  const ChampSelect({
    super.key,
    required this.items,
    required this.libelle,
    required this.readOnly,
    required this.formulaireConsultation,
    required this.onValueChanged,
    this.validator,
  });
  final List<String> items;
  final String libelle;
  final bool readOnly;
  final bool formulaireConsultation;
  final void Function(String?) onValueChanged;
  final FormFieldValidator<String>? validator;

  @override
  State<ChampSelect> createState() => _ChampSelectState();
}

class _ChampSelectState extends State<ChampSelect> {
  String? choix;

  @override
  void initState() {
    choix = widget.items.isNotEmpty ? widget.items[0] : null;
    super.initState();
  }

  /*@override
  void didUpdateWidget(covariant ChampSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Réinitialiser la valeur sélectionnée lorsque le widget est mis à jour
    setState(() {
      choix = widget.items.isNotEmpty ? widget.items[0] : null;
    });
  }*/

  // Fonction de validation pour vérifier si une valeur a été sélectionnée
  String? validateform(String? value) {
    return value == null ? 'Veuillez sélectionner une constance' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              widget.libelle,
              style: TextStyle(
                  color: widget.formulaireConsultation
                      ? Colors.black
                      : Config.couleurPrincipale),
            ),
            Visibility(
                visible: widget.formulaireConsultation ? true : false,
                child: Text(
                  "*",
                  style: TextStyle(color: Colors.red),
                ))
          ],
        ),
        DropdownButtonFormField<String>(
          // choix de la valeur dans la liste de la liste selection
          isExpanded: true,
          value: choix,
          onChanged: widget.readOnly
              ? null
              : (newValue) {
                  setState(() {
                    choix =
                        newValue!; // mise à jour de choixHopital avec la nouvelle valeur sélectionnée
                    widget.onValueChanged(choix);
                  });
                },
          //C'est la liste des éléments qui apparaissent dans le menu déroulant. Dans cet exemple, _items est une liste d'éléments de type String. Chaque élément de cette liste est transformé en un DropdownMenuItem<String> qui contient la valeur et l'affichage textuel de l'élément.
          items: widget.items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          decoration: widget.formulaireConsultation
              ? InputDecoration(
                  border: Config.outLinedBorder,
                  focusedBorder: Config.focusBorder,
                  errorBorder: Config.errorBorder,
                  enabledBorder: Config.outLinedBorder)
              : null,
          validator: widget.validator,
        )
        /*DropdownTextfield(
          dropDownList: widget.items,
          initialValue: choix,
          onChanged: widget.readOnly
              ? null
              : (newValue) {
                  setState(() {
                    choix =
                        newValue; // Mise à jour de choixHopital avec la nouvelle valeur sélectionnée
                    widget.onValueChanged(choix);
                  });
                },
          textFieldDecoration: widget.formulaireConsultation
              ? InputDecoration(
                  border: Config.outLinedBorder,
                  focusedBorder: Config.focusBorder,
                  errorBorder: Config.errorBorder,
                  enabledBorder: Config.outLinedBorder)
              : null,
        )*/
      ],
    );
  }
}
