class SignedUrlInfo {
  final String uploadUri;
  final String fileKey;

  const SignedUrlInfo({required this.uploadUri, required this.fileKey});

  factory SignedUrlInfo.fromJson(Map<String, dynamic> json) {
    return SignedUrlInfo(
      uploadUri: json["uploadUri"] as String,
      fileKey: json["fileKey"] as String,
    );
  }
}
