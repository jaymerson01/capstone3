import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:community_safety_app/features/auth/presentation/bloc/auth_state.dart';

/// Unlocks the app as soon as an admin approves the resident's ID (or locks
/// it if they revoke it), without signing out and back in.
class VerificationWatcher extends StatefulWidget {
  const VerificationWatcher({super.key, required this.user, required this.child, this.verified});

  final UserEntity user;
  final Widget child;

  /// The user's verified flag as it changes; defaults to their Firestore record.
  final Stream<bool>? verified;

  @override
  State<VerificationWatcher> createState() => _VerificationWatcherState();
}

class _VerificationWatcherState extends State<VerificationWatcher> {
  StreamSubscription<bool>? _subscription;

  @override
  void initState() {
    super.initState();
    final stream = widget.verified ??
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.id)
            .snapshots()
            .map((doc) => doc.data()?['isVerified'] == true);
    _subscription = stream.distinct().listen(_onVerified, onError: (Object e) {
      debugPrint('[VerificationWatcher] $e');
    });
  }

  void _onVerified(bool verified) {
    if (!mounted) return;
    final bloc = context.read<AuthBloc>();
    final state = bloc.state;
    if (state is Authenticated && state.user.id == widget.user.id && state.user.isVerified != verified) {
      bloc.add(AuthUserChanged(state.user.copyWith(isVerified: verified)));
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
