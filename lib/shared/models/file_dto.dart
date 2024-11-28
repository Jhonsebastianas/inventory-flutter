import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart'; // Para obtener el MIME type de un archivo
import 'package:path/path.dart'; // Para obtener la extensión del archivo

class FileDTO {
  String? id;
  String filename;
  String mimetype;
  int size;
  String data;
  String? extension;

  FileDTO({
    this.id,
    required this.filename,
    required this.mimetype,
    required this.size,
    required this.data,
    this.extension,
  });

  factory FileDTO.fromJson(Map<String, dynamic> json) {
    return FileDTO(
      id: json['id'],
      filename: json['filename'],
      mimetype: json['mimetype'],
      size: json['size'].toInt(),
      data: json['data'],
      extension: json['extension'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filename': filename,
      'mimetype': mimetype,
      'size': size,
      'data': data,
      'extension': extension,
    };
  }
}

Future<FileDTO> createFileDTO(File file) async {
  // Leer el archivo y convertirlo a base64
  final bytes = await file.readAsBytes();
  final base64Data = base64Encode(bytes);

  // Obtener el nombre del archivo
  final filename = basename(file.path);

  // Obtener el tipo MIME del archivo
  final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

  // Obtener la extensión del archivo
  final extension = extensionFromMime(mimeType);

  // Crear el DTO con la información del archivo
  return FileDTO(
    filename: filename,
    mimetype: mimeType,
    size: bytes.length,
    data: base64Data,
    extension: extension,
  );
}
