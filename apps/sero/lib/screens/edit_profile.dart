import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:sero/blocs/auth/auth_bloc.dart";
import "package:sero/blocs/auth/auth_state.dart";
import "package:sero/widgets/logo.dart";

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Future<void> _pickImage() async {
    print("_pickImage");
  }

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
                              child: state.user.pictureUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: state.user.pictureUrl ?? "",
                                    )
                                  : null,
                            ),
                          ),
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
