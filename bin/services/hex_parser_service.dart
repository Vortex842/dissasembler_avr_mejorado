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
    List<HexLineModel> lines = [];

    // Dividimos por saltos de línea (soporta Windows \r\n y Linux \n)
    final rawLines = fileContent.split(RegExp(r'\r\n|\r|\n'));

    for (var line in rawLines) {
      // Limpiar espacios en blanco
      line = line.trim();

      // Ignorar líneas vacías
      if (line.isEmpty) continue;

      // Validar inicio de línea estándar Intel HEX
      if (!line.startsWith(':')) {
        throw FormatException('Línea inválida (no comienza con ":"): $line');
      }

      try {
        // --- ESTRUCTURA DE LA LÍNEA ---
        // :LLAAAATT[DATA]CC

        // 1. Longitud (LL): Caracteres en posiciones (o Bytes) 1-3
        final int length = int.parse(line.substring(1, 3), radix: 16);

        // 2. Dirección (AAAA): Caracteres en posiciones 3-7
        final int address = int.parse(line.substring(3, 7), radix: 16);

        // 3. Tipo (TT): Caracteres en posiciones 7-9
        final int type = int.parse(line.substring(7, 9), radix: 16);

        // 4. Datos: Desde el caracter en la posición 9 hasta el final (sin el Checksum)
        // La longitud del string de datos es length * 2 (porque son 2 caracteres por Byte)
        final String dataStr = line.substring(9, 9 + (length * 2));

        // 5. Convertir Hex String a Lista de Bytes
        final List<int> bytes = _parseDataBytes(dataStr);

        // Crear el modelo y agregar a la lista final de líneas HEX parseadas correctamente
        lines.add(
            HexLineModel(address: address, recordType: type, dataBytes: bytes));
      } catch (e) {
        throw FormatException(
            'Error parseando línea HEX: "$line". Detalle: $e');
      }
    }

    return lines;
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
    List<int> bytes = [];

    // Avanzamos de 4 en 4 caracteres (porque 4 chars = 1 palabra de 16 bits)
    // Ej: "0C94" son 4 chars.
    for (int i = 0; i < dataStr.length; i += 4) {
      // Aseguramos que queden suficientes caracteres para formar una palabra
      // de 16 bits
      // Ej: Si quedan 3 chars, no alcanza para formar 1 palabra completa.
      // En ese caso, simplemente lo ignoramos (debería ser raro en un HEX válido).
      if (i + 4 <= dataStr.length) {
        String wordHex = dataStr.substring(i, i + 4);

        // INVERSIÓN (Little Endian):
        // El archivo trae "LowByte HighByte" (ej: 0C 94).
        // Nosotros queremos el valor real 0x940C.
        // Tomamos los últimos 2 chars (94) y los ponemos primero.
        String invertedHex = wordHex.substring(2, 4) + wordHex.substring(0, 2);

        // Agregar a la lista como entero
        bytes.add(int.parse(invertedHex, radix: 16));
      }
    }
    return bytes;
  }
}
