import "package:graphql_flutter/graphql_flutter.dart";
import "package:sero/constants.dart";

GraphQLClient createGqlClient() {
  final httpLink = HttpLink(gqlApiUrl);

  return GraphQLClient(
    cache: GraphQLCache(store: InMemoryStore()),
    link: httpLink,
  );
}
