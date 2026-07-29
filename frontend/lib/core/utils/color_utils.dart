import 'package:flutter/material.dart';

/// Extension pour gérer l'opacité des couleurs de manière compatible web
extension ColorOpacityExtension on Color {
  /// Applique une valeur d'opacité à la couleur
  /// Utilise withOpacity() au lieu de withValues() pour éviter l'erreur "Unsupported operation: _Namespace" sur web
  Color withAlphaValue(double alpha) {
    return withOpacity(alpha);
  }
}