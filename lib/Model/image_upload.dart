// class ImageUploadResponse {
//   final String url;

//   ImageUploadResponse({required this.url});

//   factory ImageUploadResponse.fromJson(Map<String, dynamic> json) {
//     return ImageUploadResponse(
//       url: json['url'],
//     );
//   }
// }
class ImageUploadResponse {
  final String? url;
  final String? message;

  ImageUploadResponse({this.url, this.message});

  // Factory constructor to parse JSON
  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) {
    return ImageUploadResponse(
      url: json['url'] ?? null, // Assign if 'url' exists
      message: json['message'] ?? null, // Assign if 'message' exists
    );
  }

  // Helper method to check if the response contains an error
  bool get isError => message != null;

  // Getters for url and message
  String getUrl() {
    return url ?? "No URL provided";
  }

  String getMessage() {
    return message ?? "No Message";
  }
}
