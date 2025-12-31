import "package:graphql_flutter/graphql_flutter.dart";
import "package:sero/constants.dart";

GraphQLClient createGqlClient(String? token) {
  final httpLink = HttpLink(gqlApiUrl);
  final authLink = AuthLink(
    getToken: () => token == null ? null : "Bearer $token",
  );
  final link = authLink.concat(httpLink);

  return GraphQLClient(
    cache: GraphQLCache(store: InMemoryStore()),
    link: link,
  );
}
