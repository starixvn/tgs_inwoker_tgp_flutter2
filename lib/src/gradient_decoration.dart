import 'package:flutter/material.dart';
import 'package:tgp_flutter2/src/custom_color.dart';

BoxDecoration gradientDecoration = BoxDecoration(
  gradient: LinearGradient(
    colors: [CustomColor.theme_button_color, CustomColor.theme_button_color],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  ),
);

BoxDecoration roundGradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [CustomColor.theme_button_color, CustomColor.theme_button_color],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ),
    borderRadius: BorderRadius.all(Radius.circular(45)));

BoxDecoration roundButtonGradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [CustomColor.theme_button_color, CustomColor.theme_button_color],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ),
    borderRadius: BorderRadius.all(Radius.circular(10)));

BoxDecoration gameTabGradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [CustomColor.theme_button_color, CustomColor.theme_button_color],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ),
    border: Border.all(color: Colors.black),
    borderRadius: BorderRadius.all(Radius.circular(5)));

BoxDecoration gameTabColorDecoration = BoxDecoration(
    /*gradient: LinearGradient(
      colors: [
        CustomColor.very_light_pink_four,
        CustomColor.very_light_pink_four,
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ), */
    color: CustomColor.very_light_pink_four,
    border: Border.all(color: CustomColor.very_light_pink_two),
    borderRadius: BorderRadius.all(Radius.circular(5)));
