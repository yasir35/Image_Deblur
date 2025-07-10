// class GetResponseModel {
//   final String status;
//   final String result;

//   GetResponseModel({required this.status, required this.result});

//   factory GetResponseModel.fromJson(Map<String, dynamic> json) {
//     return GetResponseModel(
//       status: json['status'] ?? null,
//       result: json['result'] ?? null,
//     );
//   }
// }
class GetResponseModel {
  final String? status; // Nullable because it may not always be provided
  final String? output; // Nullable because it may not always be provided
  final String? message; // Nullable because it may not always be provided

  GetResponseModel({this.status, this.output, this.message});

  // Factory constructor to parse JSON
  factory GetResponseModel.fromJson(Map<String, dynamic> json) {
    return GetResponseModel(
      status: json['status'], // Assign if 'status' exists
      output: json['output'], // Assign if 'output' exists
      message: json['message'], // Assign if 'message' exists
    );
  }

  // Helper method to check if the response contains an error
  bool get isError => message != null;

  // Getters for status, result, and message
  String getStatus() {
    return status ?? "No Status";
  }

  String getOutput() {
    return output ?? "No Result";
  }

  String getMessage() {
    return message ?? "No Message";
  }
}
