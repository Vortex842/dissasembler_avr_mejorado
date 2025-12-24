import '../console.dart';

// Pone las funciones que no sean drawBox como privadas
class ConsoleBOX {
  static String _borderColor = ConsoleColor.white;
  static String _textColor = ConsoleColor.white;

  static void _setBorderColor(String color) {
    _borderColor = color;
  }

  static void _setTextColor(String color) {
    _textColor = color;
  }

  static void _drawTopLeftCorner(int x, int y) {
    Console.writeLine("┌─", x: x, y: y, color: _borderColor);
  }

  static void _drawTopRightCorner(int x, int y) {
    Console.writeLine("─┐", x: x, y: y, color: _borderColor);
  }

  static void _drawTop(int x, int y) {
    Console.writeLine("──", x: x, y: y - 1, color: _borderColor);
  }

  // Bottom Left corner
  static void _drawBottomLeftCorner(int x, int y) {
    Console.writeLine("└─", x: x, y: y, color: _borderColor);
  }

  // Bottom Right corner
  static void _drawBottomRightCorner(int x, int y) {
    Console.writeLine("─┘", x: x, y: y, color: _borderColor);
  }

  // Bottom
  static void _drawBottom(int x, int y) {
    Console.writeLine("──", x: x, y: y, color: _borderColor);
  }

  // Left side
  static void _drawSide(int x, int y) {
    Console.writeLine("│", x: x, y: y, color: _borderColor);
  }

  static int drawLinesWithMultiColors(
    Map<String, String?> lines, {
    int x = 0,
    int y = 0,
    String borderColor = ConsoleColor.white,
    String? textColor,
  }) {
    // Configura los colores de borde y texto
    _setBorderColor(borderColor);
    _setTextColor(textColor ?? ConsoleColor.white);

    if (textColor != null) _setTextColor(textColor);

    int i = 0;
    int j = 0;

    // Encuentra la longitud máxima de las líneas
    for (String line in lines.keys) {
      if (line.length > i) {
        i = line.length;
      }
    }

    // Dibuja la esquina superior izquierda "┌─"
    _drawTopLeftCorner(x, y);

    // Dibuja la parte superior de la caja "──"
    if (i > 0) {
      for (int k = 1; k < i; k++) {
        _drawTop(x + 1 + k, y + 1);
      }
    }

    // Coloca la esquina superior derecha "─┐"
    _drawTopRightCorner(x + 2 + i, y);

    // Dibuja los diferentes niveles de la caja segun los saltos de línea
    for (j = 0; j < lines.length; j++) {
      // Dibuja el lado izquierdo "│"
      _drawSide(x, y + 1 + j);

      // Dibuja el lado derecho "│"
      _drawSide(x + 3 + i, y + 1 + j);

      // Escribe la línea con su color correspondiente
      // Si el color es null, usa el color de texto por defecto
      Console.write(
        lines.keys.elementAt(j),
        x: x + 2,
        y: y + 1 + j,
        color: textColor == null
            ? lines.values.elementAt(j) ?? _textColor
            : _textColor,
      );
    }

    // Dibuja la esquina inferior izquierda "└─"
    _drawBottomLeftCorner(x, y + 1 + j);

    // Dibuja la parte inferior de la caja "──"
    if (i > 0) {
      for (int k = 1; k < i; k++) {
        _drawBottom(x + 1 + k, y + 1 + j);
      }
    }

    // Dibuja la esquina inferior derecha "─┘"
    _drawBottomRightCorner(x + 2 + i, y + 1 + j);

    return j + 2; // Retorna el número de líneas dibujadas
  }

  static int drawLines(List<String> lines,
      {int x = 0,
      int y = 0,
      String borderColor = ConsoleColor.white,
      String textColor = ConsoleColor.white}) {
    // Llama a la función drawLinesWithDifferentColors con un mapa de líneas y colores
    // donde el color de cada línea es null (usando el color de texto por defecto)
    return drawLinesWithMultiColors(
      {for (var item in lines) item: null},
      x: x,
      y: y,
      borderColor: borderColor,
      textColor: textColor,
    );
  }

  static int drawLine(String text,
      {int x = 0,
      int y = 0,
      String borderColor = ConsoleColor.white,
      String textColor = ConsoleColor.white}) {
    drawLinesWithMultiColors(
      {text: null},
      x: x,
      y: y,
      borderColor: borderColor,
      textColor: textColor,
    );

    return 3;
  }
}
