import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:graphql_flutter/graphql_flutter.dart";
import "package:sero/blocs/auth/auth_bloc.dart";
import "package:sero/blocs/auth/auth_event.dart";
import "package:sero/blocs/auth/auth_state.dart";
import "package:sero/models/api_response.dart";
import "package:sero/models/signed_url_info.dart";
import "package:sero/repos/attachment.dart";
import "package:sero/repos/auth.dart";
import "package:sero/utils/url.dart";
import "package:sero/widgets/logo.dart";
import "package:image_picker/image_picker.dart";

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final authBloc = context.read<AuthBloc>();
    final gqlClient = GraphQLProvider.of(context);
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file == null) return;

    setState(() => _isLoading = true);
    final repo = AttachmentRepo(gqlClient.value);

    final signedUriInfo = await repo.getSignedUri(
      file: file,
      fileKind: FileKind.image,
    );

    if (signedUriInfo is! ApiResponseSuccess<SignedUrlInfo>) {
      _showErrorSnack();
      setState(() => _isLoading = false);
      return;
    }

    final uploadResponse = await repo.uploadFile(
      file: file,
      uploadUri: signedUriInfo.data.uploadUri,
      fileKey: signedUriInfo.data.fileKey,
      fileKind: FileKind.image,
    );

    if (uploadResponse is! ApiResponseSuccess<String>) {
      _showErrorSnack();
      setState(() => _isLoading = false);
      return;
    }

    final authRepo = AuthRepo(gqlClient.value);
    final finalPictureUpdateResponse = await authRepo.updatePictureUrl(
      uploadResponse.data,
    );

    if (finalPictureUpdateResponse is ApiResponseError<void>) {
      _showErrorSnack();
      setState(() => _isLoading = false);
      return;
    }

    final fileUrl = getFileUrl(signedUriInfo.data.fileKey);
    authBloc.add(AuthUpdatePictureUrlEvent(newPictureUrl: fileUrl));
    setState(() => _isLoading = false);
  }

  void _showErrorSnack() => ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Image upload failed."),
      backgroundColor: Colors.red,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Logo(height: 50, width: 50, color: Colors.black),
      ),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! AuthStateAuthorized) return const SizedBox.shrink();

            return SizedBox.expand(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Hero(
                    tag: "profile-icon",
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Opacity(
                            opacity: 0.8,
                            child: CircleAvatar(
                              radius: 80,
                              backgroundColor: Theme.of(context).primaryColor,
                              backgroundImage: state.user.pictureUrl != null
                                  ? CachedNetworkImageProvider(
                                      state.user.pictureUrl ?? "",
                                    )
                                  : null,
                            ),
                          ),
                          if (_isLoading)
                            if (Platform.isIOS)
                              const CircularProgressIndicator.adaptive(
                                backgroundColor: Colors.white,
                              )
                            else
                              const CircularProgressIndicator(
                                color: Colors.white,
                              )
                          else
                            const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 50,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text("Tap to select a picture."),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 2,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      child: MaterialButton(
                        padding: const EdgeInsets.all(10),
                        onPressed: () => context.push(
                          "/profile/edit/name${state.user.displayName == null ? "" : "?currentName=${state.user.displayName}"}",
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person, size: 25),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Name",
                                  style: TextStyle(fontSize: 10),
                                ),
                                Text(state.user.displayName ?? "Not set."),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
