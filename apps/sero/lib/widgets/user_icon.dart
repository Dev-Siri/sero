import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:go_router/go_router.dart";
import "package:sero/blocs/auth/auth_bloc.dart";
import "package:sero/blocs/auth/auth_state.dart";

class UserIcon extends StatelessWidget {
  const UserIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsGeometry.only(left: 10, right: 5),
      child: GestureDetector(
        onTap: () => context.push("/profile"),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! AuthStateAuthorized) {
              return CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                radius: 5,
              );
            }

            return CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 5,
              foregroundImage: state.user.pictureUrl != null
                  ? CachedNetworkImageProvider(state.user.pictureUrl ?? "")
                  : null,
              child: const Icon(Icons.person, color: Colors.white),
            );
          },
        ),
      ),
    );
  }
}
