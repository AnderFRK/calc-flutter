import 'dart:convert';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class FileService {
  // Exportar: Convierte tu cálculo en texto y abre el menú de compartir de tu celular
  static Future<void> exportNote(String title, String guide, List<String> rows) async {
    Map<String, dynamic> noteMap = {
      "titulo": title,
      "guia": guide,
      "filas": rows,
      "fecha": DateTime.now().toIso8601String(),
    };

    String jsonString = jsonEncode(noteMap);
    
    // Comparte el texto JSON 
    await Share.share(jsonString, subject: 'Exportando Cálculo: $title');
  }

  // Importar: Abre tus archivos del celular para buscar un texto o JSON guardado
  static Future<Map<String, dynamic>?> importNote() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'txt'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      return jsonDecode(content); // Lo vuelve a convertir en datos que la app entiende
    }
    return null;
  }
}