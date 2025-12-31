import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:sero/blocs/auth/auth_bloc.dart";
import "package:sero/blocs/auth/auth_event.dart";
import "package:sero/blocs/auth/auth_state.dart";
import "package:sero/widgets/logo.dart";

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Logo(height: 50, width: 50, color: Colors.black),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthStateAuthorized) return const SizedBox.shrink();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsetsGeometry.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Hero(
                      tag: "profile-icon",
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: state.user.pictureUrl != null
                            ? CachedNetworkImage(
                                imageUrl: state.user.pictureUrl ?? "",
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.user.displayName ?? "You",
                          style: const TextStyle(fontSize: 24),
                        ),
                        Text(
                          state.user.statusText ?? "No status set.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                onTap: () => context.push("/profile/edit"),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                title: const Text("Edit Profile"),
              ),
              ListTile(
                onTap: () => "",
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                title: const Text("Change Status"),
              ),
              ListTile(
                onTap: () =>
                    context.read<AuthBloc>().add(AuthLogoutUserEvent()),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
