import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/widgets/custom_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  child: Text(
                                    state.user.name.isNotEmpty
                                        ? state.user.name[0].toUpperCase()
                                        : 'U',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.copyWith(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '¡Bienvenido!',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        state.user.name.isNotEmpty
                                            ? state.user.name[0].toUpperCase() +
                                                state.user.name.substring(1)
                                            : state.user.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información del Usuario',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context,
                              'Nombre',
                              state.user.name.isNotEmpty
                                  ? state.user.name[0].toUpperCase() +
                                      state.user.name.substring(1)
                                  : state.user.name,
                              Icons.person,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              context,
                              'Username',
                              state.user.username,
                              Icons.alternate_email,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              context,
                              'Correo Electrónico',
                              state.user.email,
                              Icons.email,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              context,
                              'ID de Usuario',
                              state.user.id.toString(),
                              Icons.badge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CustomButton(
                          text: 'Cerrar Sesión',
                          onPressed: () => _showLogoutDialog(context),
                          isOutlined: true,
                          icon: Icons.logout,
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(child: Text('No autenticado'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Cerrar Sesión'),
            content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
                child: const Text('Cerrar Sesión'),
              ),
            ],
          ),
    );
  }
}
