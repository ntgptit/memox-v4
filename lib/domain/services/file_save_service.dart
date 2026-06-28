/// Writes exported bytes to local storage and returns the saved file path.
/// Keeps `dart:io` out of the presentation layer (the export screen just calls
/// this).
abstract interface class FileSaveService {
  Future<String> save(String fileName, List<int> bytes);
}
