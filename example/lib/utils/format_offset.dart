import 'package:flutter/painting.dart';

/// Release builds strip [Offset.toString], so it has to be formatted manually.
String formatOffset(Offset? offset) => offset == null
    ? 'null'
    : 'Offset(${offset.dx.toStringAsFixed(1)}, ${offset.dy.toStringAsFixed(1)})';
