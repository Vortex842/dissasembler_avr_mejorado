import 'models/instruction_model.dart';
import 'utils/instruction_loader.dart';

void main() {
  print('Disassembler AVR Tool');

  // Cargar el set de instrucciones AVR, desde el archivo JSON
  List<InstructionModel> instructions =
      InstructionLoader.loadAVRInstructionsFromJson('assets/AVR_ISA.json',
          onError: (errorMsg) {
    print(errorMsg);
  });

  print('Instrucciones AVR cargadas: ${instructions.length}');
  print('Primera instrucción: ${instructions.first.toString()}');
}
