import "package:flutter_dotenv/flutter_dotenv.dart";

final gqlApiUrl = dotenv.get("GQL_API_URL");

const envFile = ".env";
