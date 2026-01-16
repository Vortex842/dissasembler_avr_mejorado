import 'dart:convert';
import 'dart:io';

import '../models/instruction_model.dart';
import 'exceptions.dart';

class InstructionLoader {
  /// Parsea el contenido JSON puro.
  /// Lanza [InstructionLoadException] si el formato es inválido.
  /// Devuelve la lista de instrucciones en formato [InstructionModel].
  static List<InstructionModel> parseInstructions(String jsonContent) {
    try {
      final dynamic decoded = jsonDecode(jsonContent);

      if (decoded is! List) {
        throw InstructionLoadException('El JSON no es una lista ([...]).');
      }

      return decoded.map((item) => InstructionModel.fromJson(item)).toList();
    } catch (e) {
      // Atrapamos errores de sintaxis JSON o de mapeo y los re-empaquetamos
      throw InstructionLoadException('JSON mal formado o datos inválidos: $e');
    }
  }

  /// Carga desde archivo.
  /// Lanza [InstructionLoadException] si el archivo no existe o falla la lectura.
  static List<InstructionModel> loadFromFile(String filePath) {
    final file = File(filePath);

    if (!file.existsSync()) {
      // Aquí cortamos la ejecución inmediatamente.
      throw InstructionLoadException('El archivo no existe en: $filePath');
    }

    try {
      final content = file.readAsStringSync();
      return parseInstructions(content);
    } catch (e) {
      // Si falla parseInstructions, el error sube automáticamente.
      // Si falla readAsStringSync (ej: permisos), entra aquí.
      if (e is InstructionLoadException)
        rethrow; // Ya es nuestro error, déjalo pasar.
      throw InstructionLoadException('Error de lectura I/O: $e');
    }
  }
}
