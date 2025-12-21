class BitManipulator {
  /// Extrae valores de una palabra (word) basándose en un patrón de bits.
  /// - [pattern]: Una cadena que representa el patrón de bits, donde '0' y '1'
  /// son bits fijos y otras letras representan variables.
  /// - [word]: El entero del cual se extraerán los valores.
  /// - Retorna un mapa donde las claves son las variables definidas en el patrón
  /// y los valores son los enteros extraídos correspondientes.
  ///
  /// Ejemplo: pattern = "1110 KKKK dddd KKKK"
  static Map<String, int> extractValues(String pattern, int word) {
    // Limpiar espacios en el patrón
    pattern = pattern.replaceAll(' ', '');

    // 1. Mapear dónde está cada letra (bitPos)
    Map<String, List<int>> positions = _getPositions(pattern);

    // 2. Reconstruir los valores
    Map<String, int> bits = _extractBits(positions, word);

    return bits;
  }

  static Map<String, List<int>> _getPositions(String pattern) {
    // Tamaño del patrón
    int n = pattern.length;

    Map<String, List<int>> positions = {};
    for (int i = 0; i < n; i++) {
      // Obtener el carácter en la posición i
      String bit = pattern[i];

      // Validar que el carácter no sea 0 o 1
      if (bit != '0' && bit != '1') {
        // Convertimos índice de string a posición de bit (MSB a LSB)
        int bitPos = (n - 1) - i;

        // Agregar la posición del bit a la lista correspondiente en el mapa
        // Si la clave no existe, inicializamos con una lista vacía
        positions.putIfAbsent(bit, () => []).add(bitPos);
      }
    }
    return positions;
  }

  static Map<String, int> _extractBits(
      Map<String, List<int>> positions, int word) {
    Map<String, int> bits = {};
    positions.forEach(
      (variable, bitPositions) {
        // Invertimos la lista para llenar desde el bit menos significativo
        final orderedBits = bitPositions.reversed.toList();

        int value = 0;
        for (int i = 0; i < orderedBits.length; i++) {
          int sourceBit = orderedBits[i];
          // Tomamos el bit de la posición original y lo movemos a la posición i
          value |= ((word >> sourceBit) & 1) << i;
        }
        bits[variable] = value;
      },
    );

    return bits;
  }
}
