import 'package:flutter/material.dart';

const tPrimaryColor = Colors.blue;
const tSecondaryColor = Colors.white;
const ttextColor = Colors.black;
const ttextColor2 = Colors.white;

double tverysmallfontsize(BuildContext context) {
  return MediaQuery.of(context).size.width * 0.037;
}

double tsmallfontsize(BuildContext context) {
  return MediaQuery.of(context).size.width * 0.04;
} // Set a constant value

double tmediumfontsize(BuildContext context) {
  return MediaQuery.of(context).size.width * 0.047;
}

double tlargefontsize(BuildContext context) {
  return MediaQuery.of(context).size.width * 0.06;
}

double tverylargefontsize(BuildContext context) {
  return MediaQuery.of(context).size.width * 0.095;
}

double tsmallspace(BuildContext context) {
  return MediaQuery.of(context).size.height * 0.006;
}

double tmediumspace(BuildContext context) {
  return MediaQuery.of(context).size.height * 0.025;
}

double tlargespace(BuildContext context) {
  return MediaQuery.of(context).size.height * 0.02;
}

double tverylargespace(BuildContext context) {
  return MediaQuery.of(context).size.height * 0.04;
}
