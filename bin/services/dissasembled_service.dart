import '../models/disassembled_model.dart';
import '../models/instruction_model.dart';
import '../utils/bit_manipulator_utils.dart';
import '../utils/math_evaluator_utils.dart';

/// [DisassemblerService]
///
/// PROPÓSITO:
/// Es el "Cerebro" del sistema. Toma una lista de códigos numéricos y, usando
/// el set de instrucciones definido, los traduce a texto legible.
///
/// RESPONSABILIDADES:
/// 1. Identificar qué instrucción coincide con el código actual.
/// 2. Manejar instrucciones de 16 bits y 32 bits automáticamente.
/// 3. Coordinar la extracción de operandos y la evaluación matemática.
class DisassemblerService {
  final List<InstructionModel> _instructionSet;

  DisassemblerService(this._instructionSet);

  // TODO:ESTO SERA USADO FUERA EN UN FUTURO
  // // Validar límites
  //   if (pc >= programCode.length) {
  //     return const DisassembledModel(text: 'EOF', length: 0, rawWord: 0);
  //   }

  //   final int currentWord = programCode[pc];

  //   // Pre-cargamos la siguiente palabra por si es una instrucción de 32 bits.
  //   // Si estamos al final del archivo, nextWord será null.
  //   final int? nextWord =
  //       (pc + 1 < programCode.length) ? programCode[pc + 1] : null;

  /// Método principal que decodifica una instrucción dada la palabra actual
  /// y la siguiente (si aplica) que será usada en caso de ser una instrucción de 32 bits.
  /// - [currentWord]: La palabra actual a decodificar.
  /// - [nextWord]: La siguiente palabra (si aplica).
  /// Retorna un [DisassembledModel] con el resultado.
  ///
  /// Esta función es útil para casos donde ya se tiene la palabra actual y la
  /// siguiente, sin necesidad de manejar un array completo.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final result = disassemblerService.decode(0xE0FF, 0x1234);
  /// print(result.text); // Imprime: "MOV R15, 255"
  /// ```
  DisassembledModel decode(int currentWord, {int? nextWord}) {
    // Recorremos el set buscando coincidencia
    for (final instr in _instructionSet) {
      if (instr.match(currentWord)) {
        // --- CASO 1: Instrucción Larga (32 bits) ---
        if (instr.isLongInstruction) {
          if (nextWord != null && instr.secondBitPattern != null) {
            // Combinamos las palabras
            final int fullWord = (currentWord << 16) | nextWord;
            final String fullPattern =
                instr.bitPattern + instr.secondBitPattern!;

            // Construimos el texto y retornamos INMEDIATAMENTE
            final text = _buildText(instr.nameTemplate, fullPattern, fullWord);

            return DisassembledModel(
                text: text, countWords: 2, rawWord: fullWord);
          } else {
            // Error: Falta la segunda palabra
            return DisassembledModel(
              text: '// ERROR: Instrucción incompleta (Falta 2da palabra)',
              countWords:
                  1, // Consumimos 1 para no trabar el bucle, aunque esté roto
              rawWord: currentWord,
            );
          }
        }

        // --- CASO 2: Instrucción Corta (16 bits) ---
        else {
          final text =
              _buildText(instr.nameTemplate, instr.bitPattern, currentWord);

          return DisassembledModel(
              text: text, countWords: 1, rawWord: currentWord);
        }
      }
    }

    // --- CASO 3: Desconocida ---
    // Si terminó el bucle y no retornó nada, es que no encontró coincidencia.
    return DisassembledModel(
        text:
            '// 0x${currentWord.toRadixString(16).toUpperCase().padLeft(4, '0')} (Desconocida)',
        countWords: 1,
        rawWord: currentWord);
  }

  /// Método auxiliar privado que coordina el BitManipulator y el MathEvaluator
  /// para construir el texto final de la instrucción.
  /// - [template]: La plantilla de texto con marcadores (ej: "MOV W{d}, K{K}")
  /// - [pattern]: El patrón de bits asociado (ej: "11100000ddddkkkk")
  /// - [word]: La palabra numérica completa (ej: 0xE0FF)
  ///
  /// Retorna el texto final con valores evaluados.
  ///
  ///
  /// Ejemplo:
  /// - input: template="MOV R{d}, K{K}", pattern="11100000ddddkkkk", word=0xE0FF
  /// - output: "MOV R15, 255"
  ///
  ///           "MOV R{d}, K{K}" -> "MOV R15, 255"
  ///
  /// donde d=15 y K=255 extraídos y evaluados.
  ///
  ///
  /// Soporta prefijos 0x y 0b para formatear la salida en hexadecimal o binario.
  ///
  /// Ejemplo con prefijo:
  /// - input: template="LOAD 0x{K}", pattern="11000000kkkkkkkk", word=0xC0FF
  /// - output: "LOAD 0xFF"
  ///
  ///        "LOAD 0x{K}" -> "LOAD 0xFF"
  ///
  /// donde K=255 y se formatea en hexadecimal.
  ///
  ///
  /// Soporta expresiones matemáticas dentro de los marcadores.
  ///
  /// Ejemplo avanzado:
  /// - input: template="GOTO 0x{K+16}", pattern="10100000kkkkkkkk", word=0xA0F0
  /// - output: "GOTO 0x10F0"
  ///
  ///          "GOTO 0x{K+16}" -> "GOTO 0x100"
  ///
  /// donde K=0xF0 (240) y K+16=256 (0x100).
  ///
  ///
  /// Soporta múltiples marcadores en una misma plantilla.
  ///
  /// Ejemplo avanzado:
  /// - input: template="SET W{d}, 0b{K+1}", pattern="11110000ddddkkkk", word=0xF0FE
  /// - output: "SET R15, 0b11111111"
  ///
  ///       "SET R{d}, 0b{K+1}" -> "SET R15, 0b11111111"
  ///
  /// donde d=15, K=254 y K+1=255 formateado en binario.
  String _buildText(String template, String pattern, int word) {
    // 1. Extraer variables crudas (ej: d=0, K=255)
    final vars = BitManipulator.extractValues(pattern, word);

    // 2. Reemplazar y evaluar expresiones en la plantilla (ej: "{d+16}" -> "16")
    // Buscamos patrones como: {expresion} o 0x{expresion}
    return template.replaceAllMapped(
      RegExp(r'(0x|0b)?\{([^}]+)\}'),
      (match) {
        final prefix = match[1]; // '0x', '0b' o null
        final expr = match[2]!; // La fórmula interna, ej: "d+16" or "K"

        // Calculamos el valor final usando la calculadora
        int result = MathEvaluator.evaluate(expr, vars);

        // Formateamos según el prefijo
        if (prefix == '0x') {
          return '0x${result.toRadixString(16).toUpperCase().padLeft(4, '0')}'; // Ej: 0x00FF
        } else if (prefix == '0b') {
          return '0b${result.toRadixString(2).padLeft(8, '0')}'; // Ej: 0b00011111
        } else {
          return result.toString(); // Ej: 255
        }
      },
    );
  }
}
