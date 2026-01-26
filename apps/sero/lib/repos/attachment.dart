import "package:http/http.dart" as http;
import "package:graphql_flutter/graphql_flutter.dart";
import "package:image_picker/image_picker.dart";
import "package:sero/models/api_response.dart";
import "package:sero/models/signed_url_info.dart";

enum FileKind { image, video, document }

class AttachmentRepo {
  final GraphQLClient gqlClient;

  AttachmentRepo(this.gqlClient);

  Future<ApiResponse<SignedUrlInfo>> getSignedUri({
    required XFile file,
    required FileKind fileKind,
  }) async {
    const query = r"""
      query GetSignedUrl($fileInfo: FileInfo!) {
        getSignedUrl(fileInfo: $fileInfo) {
          uploadUri
          fileKey
        }
      }
    """;

    try {
      final result = await gqlClient.query(
        QueryOptions(
          document: gql(query),
          variables: {
            "fileInfo": {
              "name": file.name,
              "size": await file.length(),
              "mimeType": file.mimeType ?? "application/octet-stream",
              "kind": fileKind.name.toUpperCase(),
            },
          },
        ),
      );

      final signedFileInfo = result.data?["getSignedUrl"];

      if (result.hasException || signedFileInfo == null) {
        return ApiResponseError(
          message:
              result.exception?.graphqlErrors[0].message ??
              "An error occured in while getting the signed URL.",
        );
      }

      return ApiResponseSuccess(data: SignedUrlInfo.fromJson(signedFileInfo));
    } catch (err) {
      return ApiResponseError(message: err.toString());
    }
  }

  Future<ApiResponse<String>> uploadFile({
    required XFile file,
    required FileKind fileKind,
    required String uploadUri,
    required String fileKey,
  }) async {
    try {
      final preparedUri = Uri.parse(uploadUri);
      final request = http.MultipartRequest("PUT", preparedUri);

      request.files.add(
        http.MultipartFile(
          "file",
          file.readAsBytes().asStream(),
          await file.length(),
        ),
      );

      final response = await request.send();

      if (response.statusCode != 200 && response.statusCode != 204) {
        return const ApiResponseError(message: "Upload failed");
      }

      const mutation = r"""
        mutation UploadFile($presignedFileInfo: PresignedFileInfo!) {
          uploadFile(presignedFileInfo: $presignedFileInfo) {
            attachmentId
          }
        }
      """;

      final result = await gqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            "presignedFileInfo": {
              "name": file.name,
              "fileKey": fileKey,
              "mimeType": file.mimeType ?? "application/octet-stream",
              "kind": fileKind.name.toUpperCase(),
            },
          },
        ),
      );

      final attachmentId = result.data?["uploadFile"]?["attachmentId"];

      if (result.hasException || attachmentId == null) {
        return ApiResponseError(
          message:
              result.exception?.graphqlErrors[0].message ??
              "An error occured in while uploading the image URL.",
        );
      }

      return ApiResponseSuccess(data: attachmentId as String);
    } catch (err) {
      print(err);
      return ApiResponseError(message: err.toString());
    }
  }
}
