// class PostResponseModel {
//   final String requestId;

//   PostResponseModel({required this.requestId});

//   factory PostResponseModel.fromJson(Map<String, dynamic> json) {
//     return PostResponseModel(requestId: json['request_id']);
//   }
//   // Getter method to retrieve the requestId
//   String getRequestId() {
//     return requestId;
//   }
// }
class PostResponseModel {
  final String? requestId; // Nullable because it may not always be provided
  final String? message; // Nullable because it may not always be provided

  PostResponseModel({this.requestId, this.message});

  // Factory constructor to parse JSON
  factory PostResponseModel.fromJson(Map<String, dynamic> json) {
    return PostResponseModel(
      requestId: json['request_id'] ?? null, // Assign if 'request_id' exists
      message: json['message'] ?? null, // Assign if 'message' exists
    );
  }

  // Helper method to check if the API call failed
  bool get isError => message != null;

  // Getters for requestId and message
  String getRequestId() {
    return requestId ?? "No Request ID";
  }

  String getMessage() {
    return message ?? "No Message";
  }
}
