/// [BitManipulator]
///
/// PROPÓSITO:
/// Actúa como el "Cirujano" del sistema. Su responsabilidad es diseccionar
/// una instrucción cruda (word) y extraer los valores de sus operandos
/// basándose en una plantilla (pattern).
///
/// ¿POR QUÉ EXISTE ESTA CLASE?
/// En la arquitectura AVR, para ahorrar espacio, los operandos (como registros
/// o constantes) a menudo están fragmentados y dispersos en posiciones no
/// contiguas dentro de los 16 bits de la instrucción.
///
/// Ejemplo: En la instrucción LDI ("1110 KKKK dddd KKKK"), el valor inmediato 'K'
/// está partido en dos pedazos separados por el registro 'd'.
///
/// Esta clase resuelve ese problema: localiza esos fragmentos dispersos,
/// los extrae y los une para formar números enteros limpios y utilizables.
///
/// FLUJO:
/// Entrada:  Patrón ("1110 KKKK dddd KKKK") + Código Hex como "word" (0xE001)
/// Proceso:  Recorta los bits de 'd' y los bits de 'K'.
/// Salida:   Mapa de valores {"d": 0, "K": 1}.
class BitManipulator {
  /// Extrae los valores numéricos de las variables incrustadas en una palabra (word)
  /// basándose en un patrón de bits.
  ///
  /// - [pattern]: Cadena que define la estructura (ej: "1110 KKKK dddd KKKK").
  ///   - '0' y '1': Bits fijos (se usan para validación en otros lugares, aquí se ignoran).
  ///   - Letras (K, d, r...): Representan variables cuyos valores queremos extraer.
  /// - [word]: El número entero del cual se extraerán los bits.
  ///
  /// Retorna un [Map] donde cada clave es el nombre de cada variable (ej: "K")
  /// y el valor, correspondiente a cada uno, es el entero extraído y reconstruido como entero.
  static Map<String, int> extractValues(String pattern, int word) {
    // Eliminamos espacios para trabajar con índices reales de bits
    final cleanPattern = pattern.replaceAll(' ', '');

    // 1. Identificar qué bits del 'word' pertenecen a cada variable
    final positions = _mapVariablePositions(cleanPattern);

    // 2. Extraer esos bits y reconstruir los valores numéricos
    return _reconstructValues(positions, word);
  }

  /// Analiza el patrón y determina las posiciones de bits (índices) para cada variable.
  ///
  /// Convierte la posición del carácter en el string (lectura humana izq->der)
  /// a la posición del bit en el entero (peso matemático 2^n).
  ///
  /// - [pattern]: El patrón limpio sin espacios.
  ///
  /// Retorna un mapa: {"K": [11, 10, 9, 8, 3, 2, 1, 0], ...}
  /// Nota: Las posiciones son índices de bits (0 = LSB y 15 = MSB para palabras de 16 bits).
  static Map<String, List<int>> _mapVariablePositions(String pattern) {
    final int n = pattern.length;
    final Map<String, List<int>> positions = {};

    for (int i = 0; i < n; i++) {
      final String char = pattern[i];

      // Si es una variable (no es un bit fijo '0' o '1')
      if (char != '0' && char != '1') {
        // Fórmula mágica: Convertir índice de array (i) a peso de bit.
        // Si length es 16: i=0 -> bit 15 (MSB), i=15 -> bit 0 (LSB).
        final int bitPos = (n - 1) - i;

        positions.putIfAbsent(char, () => []).add(bitPos);
      }
    }
    return positions;
  }

  /// Toma las posiciones mapeadas y extrae los bits del [word] para formar
  /// los nuevos valores.
  ///
  /// - [positions]: Mapa de variables y sus listas de posiiciones de los bits originales.
  /// - [word]: La palabra original de donde sacar los datos.
  ///
  /// Retorna un mapa con los valores reconstruidos para cada variable.
  /// Ejemplo: {"K": 0b10101010, "d": 0b1100}
  static Map<String, int> _reconstructValues(
      Map<String, List<int>> positions, int word) {
    final Map<String, int> result = {};

    positions.forEach(
      (variable, bitIndices) {
        // Invertimos la lista 'bitIndices'.
        // ¿Por qué? Porque '_mapVariablePositions' escanea de Izq a Der (MSB a LSB).
        // Para reconstruir el número nuevo, queremos llenar primero su bit 0, luego el 1, etc.
        // Al invertir, el último bit leído (que es el de menor peso) queda primero.
        final orderedIndices = bitIndices.reversed.toList();

        int newValue = 0;

        for (int i = 0; i < orderedIndices.length; i++) {
          final int sourceBitPos = orderedIndices[i];

          // Lógica de bits:
          // 1. (word >> sourceBitPos): Mueve el bit deseado a la posición 0.
          // 2. & 1: Aísla ese bit (elimina el resto).
          // 3. << i: Mueve ese bit a su nueva posición en el 'newValue' (0, 1, 2...).
          final int bit = (word >> sourceBitPos) & 1;
          newValue |= (bit << i);
        }

        result[variable] = newValue;
      },
    );

    return result;
  }
}
