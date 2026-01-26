sealed class ApiResponse<T> {
  const ApiResponse();
}

class ApiResponseSuccess<T> extends ApiResponse<T> {
  final T data;

  const ApiResponseSuccess({required this.data});
}

class ApiResponseError<T> extends ApiResponse<T> {
  final String message;

  const ApiResponseError({required this.message});

  @override
  String toString() => "ApiResponseError(message: $message)";
}
