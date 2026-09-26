import 'package:flutter/material.dart';

import 'dart:math';

import 'styled_text.dart';

final ramdomiser = Random();

class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  @override
  State<DiceRoller> createState() {
    return _DiceRollerState();
  }
}

class _DiceRollerState extends State<DiceRoller> {
  String image = "assets/images/dice-6.png";

  void changeImage() {
    int randomInt = ramdomiser.nextInt(6) + 1;
    setState(() {
      image = "assets/images/dice-$randomInt.png";
    });
  }

  @override
  Widget build(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(image, width: 200),
        const SizedBox(height: 20),
        TextButton(onPressed: changeImage, child: StyledText("Roll Dice")),
      ],
    );
  }
}
