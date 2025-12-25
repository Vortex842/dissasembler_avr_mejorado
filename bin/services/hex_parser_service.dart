import '../models/hex_line_model.dart';

/// [HexParserService]
///
/// PROPÓSITO:
/// Encargado de interpretar el formato de texto estándar Intel HEX.
/// Transforma una cadena de texto cruda en una lista estructurada de objetos [HexLineModel].
///
/// RESPONSABILIDADES:
/// 1. Limpiar el texto (ignorar líneas vacías o comentarios).
/// 2. Validar el formato (debe empezar con ':').
/// 3. Parsear metadatos (Dirección, Tipo de registro, Longitud).
/// 4. Convertir los datos hexadecimales en bytes numéricos.
/// 5. Manejar la conversión "Little Endian" (invertir bytes) propia de los archivos AVR.
class HexParserService {
  /// Parsea el contenido completo de un archivo HEX.
  ///
  /// - [fileContent]: El contenido del archivo como un solo String.
  /// Retorna una lista de [HexLineModel] para ser procesada por el desensamblador.
  ///
  /// Lanza una [FormatException] si encuentra líneas corruptas.
  List<HexLineModel> parse(String fileContent) {
    return fileContent
        // 1. Dividir líneas de texto crudas, por saltos de linea
        .split(RegExp(r'\r\n|\r|\n'))

        // 2. Limpieza preliminar: Trim y filtrar vacías
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)

        // 3. Transformación a HexLineModel
        .map((line) {
      // Validar inicio
      if (!line.startsWith(':')) {
        throw FormatException('Línea inválida (no comienza con ":"): $line');
      }

      try {
        // --- ESTRUCTURA DE LA LÍNEA ---
        // :LLAAAATT[DATA]CC

        // - LL: Longitud (Bytes de datos).
        final int length = int.parse(line.substring(1, 3), radix: 16);

        // - AAAA: Dirección de memoria (Offset).
        final int address = int.parse(line.substring(3, 7), radix: 16);

        // - TT: Tipo de Registro.
        final int type = int.parse(line.substring(7, 9), radix: 16);

        // - [D1[0..3], D2[0..3], ...]: Datos reales (1 byte por hex).
        final String dataStr = line.substring(9, 9 + (length * 2));

        // Convertir datos hex a lista de enteros (bytes) con corrección Little Endian
        final List<int> bytes = _parseDataBytes(dataStr);

        return HexLineModel(
          address: address,
          recordType: type,
          dataBytes: bytes,
        );
      } catch (e) {
        throw FormatException(
            'Error parseando línea HEX: "$line". Detalle: $e');
      }
    })
        // 4. Empaquetado final
        .toList();
  }

  /// Convierte la cadena hexadecimal de datos en una lista de enteros.
  /// APLICA CORRECCIÓN LITTLE ENDIAN (Invierte pares de bytes).
  ///
  /// - [dataStr]: La sección de datos en formato hexadecimal (sin espacios).
  /// Retorna una lista de enteros representando las palabras de 16 bits.
  ///
  /// Ejemplo:
  ///
  /// Entrada: "0C945600" (String) que se observa en el HEX como: 0C 94 56 00
  ///
  /// Note que estan  invertidos por ser Little Endian.
  ///
  /// Salida:  [0x940C, 0x0056] (Intrucciones ya invertidas)
  List<int> _parseDataBytes(String dataStr) {
    // Calculamos cuántos elementos habrá (longitud / 2)
    // por que la longitud indica cada byte o 2 caracteres hex
    // pero al usar el dataStr.length, obtenemos el total de caracteres
    // y por ello el divido por 4
    int count = dataStr.length ~/ 4;

    // Creamos y llenamos la lista en un solo paso
    return List.generate(
      count,
      (index) {
        // Multiplicamos por 4 para contemplar pares de bytes (4 caracteres hex)
        int i = index * 4;

        String wordHex = dataStr.substring(i, i + 4);
        String invertedHex = wordHex.substring(2, 4) + wordHex.substring(0, 2);

        return int.parse(invertedHex, radix: 16);
      },
    );
  }
}
