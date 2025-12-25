import 'package:test/test.dart';

import '../bin/models/hex_line_model.dart';

void main() {
  group(
    'HexLineModel test',
    () {
      final lineWithData = HexLineModel(
        address: 0x0000,
        recordType: 0x00,
        dataBytes: [0xE0FF, 0x940E, 0x0FFF],
      );

      final lineEOF = HexLineModel(
        address: 0x0010,
        recordType: 0x01,
        dataBytes: [],
      );

      final lineExtended = HexLineModel(
        address: 0x0101,
        recordType: 0x02,
        dataBytes: [],
      );

      test(
        'Debe identificar el tipo de línea correctamente',
        () {
          // Verificar que es una línea que contiene datos
          expect(lineWithData.isDataRecord, isTrue,
              reason: 'Debe ser una línea de datos');
          expect(lineWithData.isEndOfFile, isFalse,
              reason: 'No debe ser una línea de fin de archivo');

          // Verificar que es una línea de fin de archivo
          expect(lineEOF.isDataRecord, isFalse,
              reason: 'No debe ser una línea de datos');
          expect(lineEOF.isEndOfFile, isTrue,
              reason: 'Debe ser una línea de fin de archivo');

          // Verificar que es una línea que contiene segmentos extendidos
          expect(lineExtended.isDataRecord, isFalse,
              reason: 'No debe ser una línea de datos');
          expect(lineExtended.isEndOfFile, isFalse,
              reason: 'No debe ser una línea de fin de archivo');
        },
      );

      test(
        'Cada linea debe tener los datos correctos',
        () {
          expect(lineWithData.dataBytes, equals([0xE0FF, 0x940E, 0x0FFF]),
              reason:
                  'Los bytes de datos deben coincidir con los proporcionados.');

          expect(lineEOF.dataBytes, isEmpty,
              reason:
                  'Los bytes de datos deben estar vacíos para una linea EOF.');

          expect(lineExtended.dataBytes, isEmpty,
              reason:
                  'Los bytes de datos deben estar vacíos para una linea extendida.');
        },
      );

      test(
        'El metodo "toString" debe generar una descripción legible para depuración',
        () {
          // HexLineModel
          // Aqui hay datos de programa
          //   Addr: 0x0000
          //   Type: 0x00
          //   Data: [0xE0FF, 0x940E, 0x0FFF]
          final text = lineWithData.toString();

          expect(text, contains('Addr: 0x0'),
              reason: 'Debe mostrar la dirección');

          expect(text, contains('Type: 0x00'), reason: 'Debe mostrar el tipo');

          expect(text, contains('Data: [0xE0FF, 0x940E, 0x0FFF]'),
              reason: 'Debe mostrar los datos');
        },
      );
    },
  );
}
