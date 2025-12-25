/// [HexLineModel]
///
/// PROPÓSITO:
/// Representa una única línea procesada de un archivo Intel HEX.
/// Actúa como un contenedor de datos inmutable que almacena la información
/// ya validada y lista para ser usada por el desensamblador.
///
/// ¿POR QUÉ EXISTE ESTA CLASE?
/// Los archivos .hex son texto plano difícil de manipular directamente.
/// Esta clase convierte esa cadena de caracteres crípticos en un objeto
/// con propiedades claras (dirección de memoria, tipo de registro, datos).
///
/// ESTRUCTURA HEX ORIGINAL:
/// Formato: :LLAAAATT[DD...]CC
/// - LL: Longitud (Bytes de datos).
/// - AAAA: Dirección de memoria (Offset).
/// - TT: Tipo de Registro (00=Datos, 01=EOF, etc.).
/// - DD: Datos reales (1 byte por hex).
/// - CC: Checksum (Verificación).
///
/// NOTA: Esta clase no contiene el Checksum ni la Longitud explícita,
/// ya que esos son datos de control para el parser. Aquí solo guardamos
/// lo que es útil para la lógica del programa.
class HexLineModel {
  /// La dirección de memoria inicial donde se deben escribir los [dataBytes].
  final int address;

  /// El tipo de registro.
  /// - 00: Datos (Data Record) - Contiene código o datos del programa.
  /// - 01: Fin de Archivo (End of File) - Marca el final del hex.
  /// - 02/04: Segmentos extendidos (usados en memorias mayores a 64KB).
  final int recordType;

  /// La lista de bytes crudos contenidos en la línea.
  final List<int> dataBytes;

  const HexLineModel({
    required this.address,
    required this.recordType,
    required this.dataBytes,
  });

  /// Indica si esta línea contiene datos útiles para el programa.
  bool get isDataRecord => recordType == 0x00;

  /// Indica si esta línea marca el final del archivo.
  bool get isEndOfFile => recordType == 0x01;

  /// Genera una representación legible de la línea HEX.
  /// - [address] es la dirección de memoria inicial donde se deben escribir los [dataBytes].
  /// - [recordType] es el tipo de registro en formato hexadecimal.
  /// - [dataBytes] es la lista de bytes en formato hexadecimal.
  ///
  /// Ejemplo: "HexLine(Addr: 0x0000, Type: 00, Data: [0x0C, 0x94...])"
  ///
  /// NOTA: Esta representación no es usada para la lógica del programa.
  /// Se utiliza solo para depuración.
  @override
  String toString() {
    final dataHex = dataBytes
        .map((e) => '0x${e.toRadixString(16).toUpperCase().padLeft(2, '0')}')
        .join(', ');

    final addr = '0x${address.toRadixString(16).toUpperCase().padLeft(4, '0')}';

    final type =
        '0x${recordType.toRadixString(16).toUpperCase().padLeft(2, '0')}';

    return '''
HexLineModel
${isDataRecord ? 'Aqui hay datos de programa' : isEndOfFile ? 'Es un EOF' : 'Es un segmento extendido (sin datos)'}
  Addr: $addr
  Type: $type
  Data: [$dataHex]
''';
  }

//   @override
//   String toString() {
//     return '''

//   nameTemplate: $nameTemplate

//   bitPattern: $bitPattern
//   secondBitPattern: $secondBitPattern

//   mask: ${mask.toRadixString(2).padLeft(16, '0')}
//   pattern: ${pattern.toRadixString(2).padLeft(16, '0')}
// ''';
//   }
}
