import 'dart:io';

import 'models/instruction_model.dart';
import 'utils/instruction_loader_utils.dart';

void main() {
  print('Disassembler AVR Tool');

  List<InstructionModel> instructions;

  do {
    print('Cargando instrucciones AVR');
    print("Por favor, ingrese el path del archivo JSON de instrucciones AVR");
    print("Ejemplo: assets/AVR_ISA.json");

    String? pathAVRJson = stdin.readLineSync();

    if (pathAVRJson == null || pathAVRJson.isEmpty) {
      print('Path inválido. Inténtalo nuevamente.');
      continue;
    }

    // Cargar el set de instrucciones AVR, desde el archivo JSON
    instructions = InstructionLoader.loadAVRInstructionsFromJson(
      pathAVRJson,
      onError: (errorMsg) {
        print(errorMsg);
      },
    );

    if (instructions.isEmpty) {
      print('Error al cargar las instrucciones AVR. Reintentalo nuevamente.');
      continue;
    } else {
      print(
          'Instrucciones AVR cargadas exitosamente. Total: ${instructions.length}');
      break;
    }
  } while (true);
}
