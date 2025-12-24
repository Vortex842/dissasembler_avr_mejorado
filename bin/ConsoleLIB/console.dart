import 'dart:io';

class ConsoleColor {
  static const reset = '\x1B[0m';
  static const red = '\x1B[31m';
  static const green = '\x1B[32m';
  static const yellow = '\x1B[33m';
  static const blue = '\x1B[34m';
  static const magenta = '\x1B[35m';
  static const cyan = '\x1B[36m';
  static const white = '\x1B[37m';
  static const black = '\x1B[30m';

  static String customRGB(int r, int g, int b) => '\x1B[38;2;$r;$g;${b}m';

  // Haz una funcion extra para customHEX que reciba un color en formato hexadecimal
  static String customHEX(String hexColor) {
    if (hexColor.startsWith('#')) {
      hexColor = hexColor.substring(1);
    }
    return '\x1B[38;2;${int.parse(hexColor.substring(0, 2), radix: 16)};${int.parse(hexColor.substring(2, 4), radix: 16)};${int.parse(hexColor.substring(4, 6), radix: 16)}m';
  }
}

class Console {
  static void write(String text,
      {int x = 0, int y = 0, String color = ConsoleColor.white}) {
    moveTo(x + 1, y + 1);
    stdout.write('$color$text${ConsoleColor.reset}');
  }

  static void writeLine(String text,
      {int x = 0, int y = 0, String color = ConsoleColor.white}) {
    write(text, x: x, y: y, color: color);
    stdout.write('\n');
  }

  static String readLine(String prompt,
      {int x = 0, int y = 0, String color = ConsoleColor.white}) {
    writeLine(prompt, x: x, y: y, color: color);
    return stdin.readLineSync() ?? '';
  }

  static void clear() {
    stdout.write('\x1B[2J\x1B[0;0H');
  }

  static void moveTo(int x, int y) {
    stdout.write('\x1B[$y;${x}H');
  }

  static void hideCursor() {
    stdout.write('\x1B[?25l');
  }

  static void showCursor() {
    stdout.write('\x1B[?25h');
  }

  static void wait(int milliseconds) {
    sleep(Duration(milliseconds: milliseconds));
  }

  static void waitUntilKeyPress() {
    stdin.readByteSync();
  }

  static void setTitle(String title) {
    stdout.write('\x1B]0;$title\x07');
  }

  static Map<String, int> rgbFromInt(int color) {
    final r5 = (color >> 11) & 0x1F; // 5 bits
    final g6 = (color >> 5) & 0x3F; // 6 bits
    final b5 = color & 0x1F; // 5 bits

    // Expandir a 8 bits (conversión más precisa mediante la replicación de bits)
    final r8 = (r5 << 3) | (r5 >> 2);
    final g8 = (g6 << 2) | (g6 >> 4);
    final b8 = (b5 << 3) | (b5 >> 2);

    return {
      'R': r8,
      'G': g8,
      'B': b8 + 32,
    };
  }
}
