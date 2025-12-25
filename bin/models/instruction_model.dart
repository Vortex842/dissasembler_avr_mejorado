/// [InstructionModel]
///
/// PROPÓSITO:
/// Define la "identidad" de una instrucción AVR (ej: LDI, ADD, JMP).
/// Contiene las reglas necesarias para reconocerla dentro del código binario
/// y la plantilla para convertirla a texto legible.
///
/// ¿POR QUÉ EXISTE ESTA CLASE?
/// El procesador no sabe de nombres como "LDI", solo entiende bits.
/// Esta clase actúa como el "Diccionario": traduce un patrón de bits
/// a una estructura humana.
///
/// CONCEPTOS CLAVE:
/// - [mask] (Máscara): Filtro que nos dice qué bits son fijos y definen la instrucción.
/// - [pattern] (Patrón): El valor exacto que deben tener esos bits fijos.
/// - [nameTemplate]: Cómo se debe escribir la instrucción (ej: "LDI R{d+16}, 0x{K}").
///
/// EJEMPLO DE FUNCIONAMIENTO:
/// Instrucción: LDI ("1110 KKKK dddd KKKK")
/// - Mask:    1111 0000 0000 0000 (Solo importan los 4 primeros bits).
/// - Pattern: 1110 0000 0000 0000 (Deben ser exactamente 1110).
/// Si llega "1110 0001...", la máscara deja pasar el "1110", coincide con el patrón -> ¡Es un LDI!
class InstructionModel {
  /// Plantilla de texto para mostrar al usuario (ej: "LDI R{d+16}, 0x{K}").
  final String nameTemplate;

  /// Patrón de bits original en formato string (ej: "1110 KKKK dddd KKKK").
  /// Útil para debugging o referencias, aunque la lógica usa [mask] y [pattern].
  final String bitPattern;

  /// Segundo patrón opcional. Solo existe si la instrucción ocupa 32 bits (2 palabras).
  final String? secondBitPattern;

  /// Máscara de bits pre-calculada.
  final int mask;

  /// Patrón de bits pre-calculado.
  final int pattern;

  /// Indica si la instrucción ocupa dos palabras (32 bits) en memoria.
  bool get isLongInstruction => secondBitPattern != null;

  const InstructionModel({
    required this.nameTemplate,
    required this.bitPattern,
    this.secondBitPattern,
    required this.mask,
    required this.pattern,
  });

  /// Factory Constructor: Crea una instancia optimizada desde un objeto JSON.
  ///
  /// IMPORTANTE:
  /// En lugar de parsear el string de bits cada vez que buscamos una instrucción,
  /// este constructor calcula la [mask] y el [pattern] UNA SOLA VEZ al inicio.
  /// Esto mejora drásticamente el rendimiento del desensamblador.
  factory InstructionModel.fromJson(Map<String, dynamic> json) {
    final String bitStr = (json['bitPattern'] as String).replaceAll(' ', '');

    // Variables temporales para el cálculo
    int calcMask = 0;
    int calcPattern = 0;

    // Recorremos el string para generar los bits de control
    for (int i = 0; i < bitStr.length; i++) {
      final bit = bitStr[i];

      // Si el carácter es '0' o '1', es parte de la identidad de la instrucción.
      // Si es una letra (variable), se ignora en la máscara (queda en 0).
      if (bit == '0' || bit == '1') {
        // Convertimos índice i (lectura humana) a posición de bit (peso binario)
        // bitStr length es 16. Si i=0 (principio), shift=15 (MSB).
        final int shift = bitStr.length - 1 - i;

        // Encendemos el bit en la máscara (este bit "importa")
        calcMask |= (1 << shift);

        // Si el carácter es '1', también lo encendemos en el patrón
        if (bit == '1') {
          calcPattern |= (1 << shift);
        }
      }
    }

    return InstructionModel(
      nameTemplate: json['nameTemplate'],
      bitPattern: json['bitPattern'],
      secondBitPattern: json['secondBitPattern'],
      mask: calcMask,
      pattern: calcPattern,
    );
  }

  /// Verifica si una palabra de código [word] corresponde a esta instrucción.
  ///
  /// Lógica: (Palabra & Máscara) == Patrón
  /// Esto borra las variables de la palabra y deja solo la estructura fija
  /// para compararla.
  bool match(int word) => (word & mask) == pattern;

  @override
  String toString() {
    return '''
InstructionModel
  nameTemplate: $nameTemplate

  bitPattern: $bitPattern
  secondBitPattern: $secondBitPattern

  mask: ${mask.toRadixString(2).padLeft(16, '0')}
  pattern: ${pattern.toRadixString(2).padLeft(16, '0')}
''';
  }
}
