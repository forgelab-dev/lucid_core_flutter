import '../models/models.dart' show LucidApiClientResponse;

abstract class LucidAbstractRequestHandler {
  Future<LucidApiClientResponse<T>> execute<T>();
}
