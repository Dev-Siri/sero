import "package:graphql_flutter/graphql_flutter.dart";
import "package:sero/models/api_response.dart";
import "package:sero/models/otp_validity_status.dart";

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

    print(sessionId);
    print(otp);
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
}
