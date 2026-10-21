import 'dart:io';
import 'package:flutter/widgets.dart';

/// Punto único que decide de dónde viene una imagen a partir de su ruta:
///  - `assets/...`  → recurso empaquetado (imágenes del catálogo demo)
///  - `http(s)://...` → remota (preparado para cuando exista backend)
///  - cualquier otra ruta → archivo local elegido desde la galería
/// Así `AppImage` y el visor no duplican esta lógica y, al migrar a
/// Firestore/Storage, solo cambian las URLs guardadas.
ImageProvider imageProviderFor(String path) {
  if (path.startsWith('assets/')) return AssetImage(path);
  if (path.startsWith('http://') || path.startsWith('https://')) return NetworkImage(path);
  return FileImage(File(path));
}
