import "package:graphql_flutter/graphql_flutter.dart";
import "package:sero/models/api_response.dart";
import "package:sero/models/authenticated_user.dart";
import "package:sero/models/otp_validity_status.dart";
import "package:sero/models/user.dart";

class AuthRepo {
  final GraphQLClient gqlClient;

  AuthRepo(this.gqlClient);

  Future<ApiResponse<String>> createSession({required String phone}) async {
    const mutation = r"""
      mutation CreateSession($phone: String!) {
        createSession(phone: $phone) {
          sessionId
        }
      }
    """;

    try {
      final result = await gqlClient.mutate(
        MutationOptions(document: gql(mutation), variables: {"phone": phone}),
      );

      final sessionId = result.data?["createSession"]?["sessionId"] as String?;

      if (result.hasException || sessionId == null) {
        return ApiResponseError(
          message:
              result.exception?.graphqlErrors[0].message ??
              "An error occured in while creating your auth session.",
        );
      }

      return ApiResponseSuccess(data: sessionId);
    } catch (err) {
      return ApiResponseError(message: err.toString());
    }
  }

  Future<ApiResponse<OtpValidityStatus>> verifyOtp({
    required String sessionId,
    required String otp,
  }) async {
    const mutation = r"""
      mutation VerifyOtp($sessionId: ID!, $otp: String!) {
        verifyOtp(
          otp: { sessionId: $sessionId, otp: $otp }
        )
      }
    """;

    try {
      final result = await gqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {"sessionId": sessionId, "otp": otp},
        ),
      );

      final otpValidityStatus = result.data?["verifyOtp"];

      if (result.hasException || otpValidityStatus == null) {
        return ApiResponseError(
          message:
              result.exception?.graphqlErrors[0].message ??
              "An error occured in while verifying OTP.",
        );
      }

      return ApiResponseSuccess(
        data: otpValidityStatusFromMap(otpValidityStatus ?? ""),
      );
    } catch (err) {
      return ApiResponseError(message: err.toString());
    }
  }

  Future<ApiResponse<void>> resendOtp({
    required String sessionId,
    required String phone,
  }) async {
    const mutation = r"""
      mutation ResendOtp($sessionId: ID!, $phone: String!) {
        resendOtp(
          otp: { sessionId: $sessionId, phone: $phone }
        )
      }
    """;

    try {
      final result = await gqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {"sessionId": sessionId, "phone": phone},
        ),
      );

      if (result.hasException) {
        return ApiResponseError(
          message:
              result.exception?.graphqlErrors[0].message ??
              "An error occured in while resending OTP.",
        );
      }

      return const ApiResponseSuccess(data: null);
    } catch (err) {
      return ApiResponseError(message: err.toString());
    }
  }

  Future<ApiResponse<AuthenticatedUser>> completeAuth({
    required String sessionId,
    required String phone,
  }) async {
    const mutation = r"""
      mutation CompleteAuth($sessionId: ID!, $phone: String!) {
        completeAuth(
          authInfo: { sessionId: $sessionId, phone: $phone }
        ) {
          token,
          userId,
          authType
        }
      }
    """;

    try {
      final result = await gqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {"sessionId": sessionId, "phone": phone},
        ),
      );

      final authedUser = result.data?["completeAuth"];

      if (result.hasException || authedUser == null) {
        return ApiResponseError(
          message:
              result.exception?.graphqlErrors[0].message ??
              "An error occured in while completing authentication.",
        );
      }

      return ApiResponseSuccess(data: AuthenticatedUser.fromJson(authedUser));
    } catch (err) {
      return ApiResponseError(message: err.toString());
    }
  }

  Future<ApiResponse<User>> fetchUser(String userId) async {
    const query = r"""
      query FetchUser($userId: ID!) {
        getUser(userId: $userId) {
          userId,
          phone,
          displayName,
          createdAt,
          statusText,
          pictureUrl
        }
      }
    """;

    try {
      final result = await gqlClient.query(
        QueryOptions(document: gql(query), variables: {"userId": userId}),
      );

      final user = result.data?["getUser"];

      if (result.hasException || user == null) {
        return ApiResponseError(
          message:
              result.exception?.graphqlErrors[0].message ??
              "An error occured while fetching user.",
        );
      }

      return ApiResponseSuccess(data: User.fromJson(user));
    } catch (err) {
      return ApiResponseError(message: err.toString());
    }
  }

  Future<ApiResponse<void>> updateDisplayName(String newName) async {
    const mutation = r"""
      mutation UpdateDisplayName($newName: String!) {
        updateDisplayName(newName: $newName)
      }
    """;

    try {
      final result = await gqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {"newName": newName},
        ),
      );

      if (result.hasException) {
        return ApiResponseError(
          message:
              result.exception?.graphqlErrors[0].message ??
              "An error occured while updating your name.",
        );
      }

      return const ApiResponseSuccess(data: null);
    } catch (err) {
      return ApiResponseError(message: err.toString());
    }
  }

  Future<ApiResponse<void>> updateStatus(String newStatus) async {
    const mutation = r"""
      mutation UpdateStatus($newStatus: String!) {
        updateStatus(newStatus: $newStatus)
      }
    """;

    try {
      final result = await gqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {"newStatus": newStatus},
        ),
      );

      if (result.hasException) {
        return ApiResponseError(
          message:
              result.exception?.graphqlErrors[0].message ??
              "An error occured while updating your status.",
        );
      }

      return const ApiResponseSuccess(data: null);
    } catch (err) {
      return ApiResponseError(message: err.toString());
    }
  }

  Future<ApiResponse<void>> updatePictureUrl(
    String newPictureAttachmentId,
  ) async {
    const mutation = r"""
      mutation UpdatePictureUrl($newPictureAttachmentId: String!) {
        updatePictureUrl(newPictureAttachmentId: $newPictureAttachmentId)
      }
    """;

    try {
      final result = await gqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {"newPictureAttachmentId": newPictureAttachmentId},
        ),
      );

      if (result.hasException) {
        return ApiResponseError(
          message:
              result.exception?.graphqlErrors[0].message ??
              "An error occured while updating your picture.",
        );
      }

      return const ApiResponseSuccess(data: null);
    } catch (err) {
      return ApiResponseError(message: err.toString());
    }
  }

  Future<ApiResponse<void>> uploadPublicKey({
    required String algorithm,
    required String publicKey,
    required String userToken,
  }) async {
    const mutation = r"""
      mutation UploadPublicKey($algorithm: String!, $publicKey: String!, $userToken: String!) {
        uploadPublicKey(publicKey: {
          algorithm: $algorithm
          publicKey: $publicKey
          userToken: $userToken
        })
      }
    """;

    try {
      final result = await gqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: {
            "algorithm": algorithm,
            "publicKey": publicKey,
            "userToken": userToken,
          },
        ),
      );

      if (result.hasException) {
        return ApiResponseError(
          message:
              result.exception?.graphqlErrors[0].message ??
              "An error occured while uploading public key.",
        );
      }

      return const ApiResponseSuccess(data: null);
    } catch (err) {
      return ApiResponseError(message: err.toString());
    }
  }

  Future<ApiResponse<void>> revokePublicKey() async {
    const mutation = r"""
      mutation RevokePublicKey {
        revokePublicKey
      }
    """;

    try {
      final result = await gqlClient.mutate(
        MutationOptions(document: gql(mutation)),
      );

      if (result.hasException) {
        return ApiResponseError(
          message:
              result.exception?.graphqlErrors[0].message ??
              "An error occured while revoking your public key.",
        );
      }

      return const ApiResponseSuccess(data: null);
    } catch (err) {
      return ApiResponseError(message: err.toString());
    }
  }
}
