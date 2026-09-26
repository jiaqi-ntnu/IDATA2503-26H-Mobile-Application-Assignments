import 'package:flutter/material.dart';

import 'dice_roller.dart';

const topLeft = Alignment.topLeft;
const bottomRight = Alignment.bottomRight;

class GradientContainer extends StatelessWidget {
  new({super.key, required this.colors});

  List<Color> colors;

  @override
  Widget build(context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: topLeft,
          end: bottomRight,
        ),
      ),
      child: Center(
        child: DiceRoller()
      ),
    );
  }
}
