import 'package:flutter/widgets.dart';

/// Returns `true` when the shortest screen dimension indicates a tablet
/// layout (width >= 600 logical pixels).
bool isTablet(BuildContext context) {
  return MediaQuery.of(context).size.width >= 600;
}
