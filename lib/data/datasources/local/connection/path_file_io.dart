import 'dart:io';

Future<void> writePathString(String path, String content) =>
    File(path).writeAsString(content);

Future<String> readPathString(String path) => File(path).readAsString();
