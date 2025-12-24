import 'dart:convert';
import 'dart:io';

import '../models/instruction_model.dart';

class InstructionLoader {
  /// Carga el set de instrucciones desde un archivo JSON.
  ///
  /// - [filePath]: Ruta al archivo .json.
  /// - [onError]: (Opcional) Función callback que se ejecuta si algo falla.
  ///   Recibe el mensaje de error como string.
  ///
  /// Retorna una lista de [InstructionModel].
  /// Si ocurre un error, retorna una lista vacía `[]` (no lanza excepción).
  static List<InstructionModel> loadAVRInstructionsFromJson(String pathAVRJson,
      {Function(String)? onError}) {
    try {
      final fileAVRJson = File(pathAVRJson);

      // 1. Verificar existencia
      if (!fileAVRJson.existsSync()) {
        if (onError != null) {
          onError('El archivo no existe en la ruta: $pathAVRJson');
        }
        return [];
      }

      // 2. Leer contenido
      final String jsonStringAVR = fileAVRJson.readAsStringSync();

      // 3. Decodificar JSON
      final dynamic jsonListAVR = jsonDecode(jsonStringAVR);

      // Verificación de seguridad: ¿Es realmente una lista?
      if (jsonListAVR is! List) {
        if (onError != null) {
          onError('El formato del JSON es incorrecto. Se esperaba una lista.');
        }
        return [];
      }

      // 4. Convertir a Modelos
      return jsonListAVR
          .map((jsonItem) => InstructionModel.fromJson(jsonItem))
          .toList();
    } catch (e) {
      // Capturamos CUALQUIER error (lectura, sintaxis json, campos faltantes)
      if (onError != null) {
        onError('Error inesperado cargando instrucciones: $e');
      }
      // Retornamos lista vacía para indicar "fallo seguro"
      return [];
    }
  }
}
