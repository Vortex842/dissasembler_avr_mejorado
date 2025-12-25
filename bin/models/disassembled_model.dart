/// [DisassembledModel]
///
/// PROPÓSITO:
/// Es un objeto de transferencia de datos (DTO) inmutable que empaqueta el
/// resultado final de haber procesado una instrucción.
///
/// ¿POR QUÉ ES IMPORTANTE?
/// Este objeto es la pieza clave para eliminar la lógica compleja del bucle principal.
/// En lugar de que el `main` tenga que adivinar si debe avanzar 1 o 2 pasos,
/// este modelo trae esa información encapsulada en la propiedad [length].
///
/// CONTENIDO:
/// 1. [text]: La traducción legible para humanos (ej: "LDI R16, 0xFF").
/// 2. [countWords]: La cantidad de memoria que consumió esta instrucción.
/// 3. [rawWord]: El código máquina original (útil para mostrar al lado del texto).
class DisassembledModel {
  /// El texto en lenguaje ensamblador resultante.
  /// Contiene el mnemónico y los operandos ya resueltos.
  /// Ejemplo: "STS 0x0150, R16"
  final String text;

  /// La longitud de la instrucción en "palabras" de 16 bits.
  ///
  /// USO CRÍTICO:
  /// Este valor indica al Program Counter (PC) cuánto debe incrementarse.
  /// - Valor 1: Instrucción estándar (16 bits).
  /// - Valor 2: Instrucción larga (32 bits, tomó la palabra actual y la siguiente).
  final int countWords;

  /// El valor numérico crudo de la instrucción completa.
  ///
  /// Si [countWords] es 2, este valor contiene los 32 bits combinados.
  /// Si [countWords] es 1, contiene los 16 bits originales.
  /// Se usa principalmente para visualización y debugging (para ver el código hex).
  final int rawWord;

  const DisassembledModel({
    required this.text,
    required this.countWords,
    required this.rawWord,
  });

  /// Representación en cadena para facilitar la depuración rápida.
  @override
  String toString() => text;
}
