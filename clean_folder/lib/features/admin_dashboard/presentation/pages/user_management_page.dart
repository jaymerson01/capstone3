import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_safety_app/features/auth/data/models/user_model.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/admin_dashboard/data/datasources/audit_log_remote_data_source.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_header_parts.dart';
import 'package:community_safety_app/features/admin_dashboard/presentation/widgets/admin_ui.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String _searchQuery = "";
  String _statusFilter = "All"; // "All", "Active", "Suspended"
  String _roleFilter = "All"; // "All", "resident", "admin"

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // On very short screens the title and filters scroll on their
          // own, so the citizen table always keeps some room.
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.45,
            ),
            child: SingleChildScrollView(
              primary: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title & Header ─────────────────────────────────────
                  const AdminPageTitle(
                    title: "Citizen Directory & User Management",
                    subtitle:
                        "Registered Barangay Moonwalk residents, emergency contact dossiers, and moderation",
                  ),
                  const SizedBox(height: 20),

                  // ── Search & Filter Controls ───────────────────────────
                  // One row on wide screens, stacked on narrow ones. The
                  // children keep their places, so typed search text
                  // survives a resize.
                  LayoutBuilder(
                    builder: (_, constraints) {
                      final bool wide = constraints.maxWidth >= 900;
                      return Flex(
                        direction: wide ? Axis.horizontal : Axis.vertical,
                        crossAxisAlignment: wide
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          // Status Filter
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: AdminSegmented<String>(
                              segments: const [
                                ("All", "All Statuses"),
                                ("Active", "Active Accounts"),
                                ("Suspended", "Suspended Accounts"),
                              ],
                              value: _statusFilter,
                              onChanged: (val) =>
                                  setState(() => _statusFilter = val),
                            ),
                          ),
                          const SizedBox(width: 12, height: 12),
                          Flexible(
                            flex: wide ? 1 : 0,
                            child: AdminSearchField(
                              hint:
                                  "Search by citizen name, email, phone, sector...",
                              onChanged: (val) =>
                                  setState(() => _searchQuery = val),
                            ),
                          ),
                          const SizedBox(width: 12, height: 12),

                          // Role Filter
                          AdminSelect<String>(
                            value: _roleFilter,
                            accent: _roleFilter != "All",
                            items: const [
                              ("All", "All Roles"),
                              ("resident", "Residents Only"),
                              ("admin", "Admins Only"),
                            ],
                            onChanged: (val) =>
                                setState(() => _roleFilter = val),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Realtime Citizen Stream Table ──────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error loading users: ${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AdminColors.dangerText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AdminColors.cyan,
                    ),
                  );
                }

                final List<UserEntity> users = snapshot.data!.docs.map((doc) {
                  return UserModel.fromFirestore(doc);
                }).toList();

                // Client filter
                final filteredUsers = users.where((u) {
                  final q = _searchQuery.toLowerCase();
                  final matchesSearch = (u.displayName ?? '')
                          .toLowerCase()
                          .contains(q) ||
                      u.email.toLowerCase().contains(q) ||
                      (u.phoneNumber ?? '').toLowerCase().contains(q) ||
                      (u.barangayArea ?? '').toLowerCase().contains(q) ||
                      (u.address ?? '').toLowerCase().contains(q) ||
                      u.id.toLowerCase().contains(q);

                  final matchesStatus = _statusFilter == "All" ||
                      (_statusFilter == "Active" && u.isActive) ||
                      (_statusFilter == "Suspended" && !u.isActive);

                  final matchesRole = _roleFilter == "All" ||
                      u.role.toLowerCase() == _roleFilter.toLowerCase();

                  return matchesSearch && matchesStatus && matchesRole;
                }).toList();

                return Align(
                  alignment: Alignment.topCenter,
                  child: AdminPanel(
                    padding: EdgeInsets.zero,
                    child: filteredUsers.isEmpty
                        ? const SingleChildScrollView(
                            primary: false,
                            child: SizedBox(
                              width: double.infinity,
                              child: AdminEmptyState(
                                icon: Icons.person_search_outlined,
                                title: "No citizen accounts match the criteria",
                              ),
                            ),
                          )
                        : _ScrollingTable(
                            child: DataTable(
                              headingRowHeight: 46,
                              headingRowColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                              dataRowColor: WidgetStateProperty.resolveWith(
                                (states) => states.contains(WidgetState.hovered)
                                    ? AdminTable.hoverRow
                                    : Colors.transparent,
                              ),
                              dataRowMinHeight: 64,
                              dataRowMaxHeight: 76,
                              dividerThickness: 1,
                              horizontalMargin: 18,
                              columnSpacing: 22,
                              headingTextStyle: AdminTable.header,
                              dataTextStyle: AdminTable.cell,
                              columns: [
                                DataColumn(
                                  label: Text(
                                    "Citizen Name".toUpperCase(),
                                    style: AdminTable.header,
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Contact Info".toUpperCase(),
                                    style: AdminTable.header,
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Barangay Sector / Address".toUpperCase(),
                                    style: AdminTable.header,
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Role".toUpperCase(),
                                    style: AdminTable.header,
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Status".toUpperCase(),
                                    style: AdminTable.header,
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Verification".toUpperCase(),
                                    style: AdminTable.header,
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Actions".toUpperCase(),
                                    style: AdminTable.header,
                                  ),
                                ),
                              ],
                              rows: filteredUsers.map((user) {
                                final bool isActive = user.isActive;
                                final AdminTone statusTone = isActive
                                    ? AdminTone.green
                                    : AdminTone.red;

                                // Suspended accounts read a little dimmer.
                                Widget dim(Widget cell) => isActive
                                    ? cell
                                    : Opacity(opacity: 0.8, child: cell);

                                return DataRow(
                                  cells: [
                                    // Name + Avatar
                                    DataCell(
                                      dim(
                                        Row(
                                          children: [
                                            Tooltip(
                                              message: (user.photoUrl != null &&
                                                      user.photoUrl!.isNotEmpty)
                                                  ? "Click to view full photo"
                                                  : (user.displayName ?? "Citizen"),
                                              child: InkWell(
                                                onTap: (user.photoUrl != null &&
                                                        user.photoUrl!.isNotEmpty)
                                                    ? () => _showEnlargedPhotoDialog(
                                                        context, user)
                                                    : null,
                                                customBorder:
                                                    const CircleBorder(),
                                                child: AdminAvatar(
                                                  initial: (user.displayName !=
                                                              null &&
                                                          user.displayName!
                                                              .isNotEmpty)
                                                      ? user.displayName![0]
                                                          .toUpperCase()
                                                      : 'U',
                                                  photoUrl: user.photoUrl,
                                                  size: 38,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                    maxWidth: 190,
                                                  ),
                                                  child: Text(
                                                    user.displayName ??
                                                        "Unnamed Citizen",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style:
                                                        AdminTable.cellStrong,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  "ID: ${user.id.length > 8 ? user.id.substring(0, 8) : user.id}",
                                                  style: const TextStyle(
                                                    color: AdminColors.textHint,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Contact (Email + Phone)
                                    DataCell(
                                      dim(
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ConstrainedBox(
                                              constraints:
                                                  const BoxConstraints(
                                                maxWidth: 220,
                                              ),
                                              child: Text(
                                                user.email,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: AdminTable.cellMuted,
                                              ),
                                            ),
                                            if (user.phoneNumber != null &&
                                                user.phoneNumber!.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 2,
                                                ),
                                                child: Text(
                                                  user.phoneNumber!,
                                                  style: const TextStyle(
                                                    color:
                                                        AdminColors.textLight,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Sector / Address
                                    DataCell(
                                      dim(
                                        SizedBox(
                                          width: 160,
                                          child: Text(
                                            user.barangayArea ??
                                                user.address ??
                                                "Barangay Moonwalk",
                                            style: AdminTable.cell,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Role Badge (Read-Only)
                                    DataCell(
                                      dim(
                                        AdminPill(
                                          label: user.isAdmin
                                              ? "Barangay Admin"
                                              : "Citizen Resident",
                                          tone: user.isAdmin
                                              ? AdminTone.blue
                                              : AdminTone.slate,
                                        ),
                                      ),
                                    ),
                                    // Status Badge
                                    DataCell(
                                      dim(
                                        AdminPill(
                                          label: (isActive ? "Active" : "Suspended")
                                              .toUpperCase(),
                                          tone: statusTone,
                                        ),
                                      ),
                                    ),
                                    // Verification Badge
                                    DataCell(
                                      dim(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              user.isVerified
                                                  ? Icons.verified_rounded
                                                  : Icons.pending_outlined,
                                              size: 15,
                                              color: user.isVerified
                                                  ? AdminColors.cyanSoft
                                                  : AdminColors.pendingText,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              user.isVerified
                                                  ? "Verified"
                                                  : "Unverified",
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                color: user.isVerified
                                                    ? AdminColors.cyanSoft
                                                    : AdminColors.pendingText,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Actions
                                    DataCell(
                                      dim(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // View Citizen Dossier Modal
                                            AdminIconAction(
                                              icon: Icons.badge_outlined,
                                              tooltip:
                                                  "View Citizen Emergency Dossier",
                                              onPressed: () =>
                                                  _showCitizenDossier(
                                                context,
                                                user,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            // Suspend / Reactivate Account Toggle
                                            AdminIconAction(
                                              icon: isActive
                                                  ? Icons.block_flipped
                                                  : Icons.check_circle_outline,
                                              tone: isActive
                                                  ? AdminTone.red
                                                  : AdminTone.green,
                                              tooltip: isActive
                                                  ? "Suspend Account (Spam / Fake Reports)"
                                                  : "Reactivate Account",
                                              onPressed: () =>
                                                  _toggleUserActiveStatus(
                                                context,
                                                user,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            // Verify Resident Toggle
                                            AdminIconAction(
                                              icon: user.isVerified
                                                  ? Icons.verified
                                                  : Icons.verified_outlined,
                                              tone: AdminTone.cyan,
                                              tooltip: user.isVerified
                                                  ? "Revoke Barangay Residency Verification"
                                                  : "Verify Barangay Residency",
                                              onPressed: () =>
                                                  _toggleUserVerification(
                                                context,
                                                user,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Citizen Dossier Modal (Emergency Contact Details) ──────────────────
  void _showCitizenDossier(BuildContext context, UserEntity user) {
    showDialog(
      context: context,
      builder: (ctx) {
        // Count submitted reports from IncidentBloc
        int citizenReportsCount = 0;
        final incidentState = context.read<IncidentBloc>().state;
        if (incidentState is IncidentLoaded) {
          citizenReportsCount = incidentState.incidents
              .where((i) => i.reporterId == user.id)
              .length;
        }

        return AdminDialog(
          title: user.displayName ?? "Citizen Resident",
          subtitle: "UID: ${user.id}",
          maxWidth: 520,
          onClose: () => Navigator.pop(ctx),
          actions: [
            AdminButton(
              label: "Close Dossier",
              style: AdminButtonStyle.ghost,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Interactive Citizen Avatar (Click to enlarge)
              Center(
                child: Builder(
                  builder: (avatarCtx) {
                    final bool hasPhoto = user.photoUrl != null &&
                        user.photoUrl!.isNotEmpty;
                    return Tooltip(
                      message: hasPhoto
                          ? "Click to view enlarged photo"
                          : "No photo uploaded",
                      waitDuration: const Duration(milliseconds: 300),
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTap: () {
                            if (hasPhoto) {
                              _showEnlargedPhotoDialog(context, user);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Citizen has not uploaded a profile picture yet.",
                                  ),
                                  backgroundColor: AdminColors.border,
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          customBorder: const CircleBorder(),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: hasPhoto
                                        ? AdminColors.cyan
                                            .withValues(alpha: 0.6)
                                        : Colors.white
                                            .withValues(alpha: 0.12),
                                    width: 2,
                                  ),
                                  boxShadow: hasPhoto
                                      ? [
                                          BoxShadow(
                                            color: AdminColors.cyan
                                                .withValues(alpha: 0.25),
                                            blurRadius: 14,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: AdminAvatar(
                                  initial: (user.displayName != null &&
                                          user.displayName!.isNotEmpty)
                                      ? user.displayName![0].toUpperCase()
                                      : 'U',
                                  photoUrl: user.photoUrl,
                                  size: 64,
                                ),
                              ),
                              if (hasPhoto)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AdminColors.surfaceDeep,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AdminColors.cyan,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.zoom_in_rounded,
                                      size: 13,
                                      color: AdminColors.cyanText,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (user.photoUrl != null &&
                  user.photoUrl!.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        size: 12,
                        color: AdminColors.cyanSoft,
                      ),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          "Click avatar to enlarge",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AdminColors.cyanText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 18),
              Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 16),

              // Resident Identity & Account Attributes
              _dossierSectionHeader("Citizen Profile & Identification"),
              const SizedBox(height: 6),
              _dossierRow(Icons.email_outlined, "Email Address", user.email),
              _dossierRow(
                Icons.phone_outlined,
                "Mobile Phone",
                user.phoneNumber ?? "Not provided",
              ),
              _dossierRow(
                Icons.location_on_outlined,
                "Barangay Sector",
                user.barangayArea ?? "Barangay Moonwalk",
              ),
              _dossierRow(
                Icons.home_outlined,
                "Home Address",
                user.address ?? "Not provided",
              ),
              _dossierRow(
                Icons.calendar_today_outlined,
                "Registration Date",
                user.createdAt != null
                    ? "${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}"
                    : "Verified Member",
              ),

              const SizedBox(height: 18),
              // EMERGENCY CONTACT DOSSIER (Critical for dispatchers!)
              _dossierSectionHeader("Life-Safety Emergency Contacts"),
              const SizedBox(height: 8),
              AdminInset(
                tone: AdminTone.red,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.contact_emergency_rounded,
                          color: AdminColors.dangerText,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "Designated Emergency Contact",
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AdminColors.dangerText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 16,
                      runSpacing: 6,
                      children: [
                        Text(
                          "Person: ${user.emergencyContactName ?? 'None on file'}",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AdminColors.textStrong,
                          ),
                        ),
                        Text(
                          "Phone: ${user.emergencyContactNumber ?? 'None on file'}",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AdminColors.cyanText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              // Report Ledger Activity
              _dossierSectionHeader("Incident Blotter Activity"),
              const SizedBox(height: 8),
              AdminInset(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "$citizenReportsCount",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AdminColors.textStrong,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Submitted Reports",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AdminColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              user.isVerified ? "YES" : "NO",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: user.isVerified
                                    ? AdminColors.successText
                                    : AdminColors.textHint,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Residency Verified",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AdminColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              user.isActive ? "ACTIVE" : "SUSPENDED",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: user.isActive
                                    ? AdminColors.successText
                                    : AdminColors.dangerText,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Account Standing",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AdminColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Enlarged Citizen Photo Lightbox Modal ───────────────────────────────
  void _showEnlargedPhotoDialog(BuildContext context, UserEntity user) {
    if (user.photoUrl == null || user.photoUrl!.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AdminDialog(
          title: user.displayName ?? "Citizen Resident",
          subtitle:
              "UID: ${user.id} • ${user.barangayArea ?? 'Barangay Moonwalk'}",
          icon: Icons.portrait_rounded,
          tone: AdminTone.cyan,
          maxWidth: 520,
          onClose: () => Navigator.pop(ctx),
          actions: [
            AdminButton(
              label: "Open Original",
              icon: Icons.open_in_new,
              style: AdminButtonStyle.cyan,
              height: 42,
              onPressed: () async {
                final uri = Uri.tryParse(user.photoUrl!);
                if (uri != null) {
                  await launchUrl(uri,
                      mode: LaunchMode.externalApplication);
                }
              },
            ),
            AdminButton(
              label: "Close",
              style: AdminButtonStyle.ghost,
              height: 42,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // High-resolution photo container with InteractiveViewer
              Container(
                width: double.infinity,
                constraints:
                    const BoxConstraints(maxHeight: 440, minHeight: 280),
                decoration: BoxDecoration(
                  color: AdminColors.well,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4.0,
                      clipBehavior: Clip.antiAlias,
                      child: Center(
                        child: Image.network(
                          user.photoUrl!,
                          fit: BoxFit.contain,
                          loadingBuilder:
                              (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AdminColors.cyan,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "Loading photo...",
                                    style: TextStyle(
                                      color: AdminColors.textLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.broken_image_rounded,
                                      size: 48,
                                      color: AdminColors.dangerSoft,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      "Failed to load image",
                                      style: TextStyle(
                                        color: AdminColors.textStrong,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "The remote image could not be loaded or network is offline.",
                                      style: TextStyle(
                                        color: AdminColors.textLight,
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Zoom hint (the footer actions sit in the dialog's button row)
              const Row(
                children: [
                  Icon(Icons.zoom_in, size: 14, color: AdminColors.textHint),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "Pinch or scroll to zoom • Drag to pan",
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AdminColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dossierSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        color: AdminColors.textHint,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _dossierRow(IconData icon, String label, String value) {
    return AdminDetailRow(
      icon: icon,
      label: "$label: ",
      value: value,
      labelWidth: 140,
    );
  }

  // ── Moderation: Suspend / Reactivate Account ───────────────────────────
  Future<void> _toggleUserActiveStatus(
    BuildContext context,
    UserEntity user,
  ) async {
    final bool newStatus = !user.isActive;
    final String actionText = newStatus ? "Reactivate" : "Suspend";

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AdminDialog(
        title: "$actionText Citizen Account?",
        icon: newStatus ? Icons.check_circle_outline : Icons.block_flipped,
        tone: newStatus ? AdminTone.green : AdminTone.red,
        maxWidth: 460,
        actions: [
          AdminButton(
            label: "Cancel",
            style: AdminButtonStyle.ghost,
            onPressed: () => Navigator.pop(ctx, false),
          ),
          AdminButton(
            label: actionText,
            style: newStatus
                ? AdminButtonStyle.primary
                : AdminButtonStyle.danger,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
        child: Text(
          newStatus
              ? "Are you sure you want to reactivate ${user.displayName ?? user.email}'s account?"
              : "Suspending ${user.displayName ?? user.email} will immediately prevent them from submitting emergency reports or signing into the civic app (curbing spam / prank calls).",
          style: const TextStyle(
            color: AdminColors.textSoft,
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .update({'isActive': newStatus});

        await sl<AuditLogRemoteDataSource>().recordLog(
          actionType: 'Citizen Moderation',
          details: '${newStatus ? "Reactivated" : "Suspended"} citizen account for ${user.displayName ?? user.email} (UID: ${user.id})',
          targetId: user.id,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✓ Account successfully ${newStatus ? 'reactivated' : 'suspended'}."),
              backgroundColor: newStatus
                  ? AdminColors.success
                  : AdminColors.amber,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to update status: $e"),
              backgroundColor: AdminColors.critical,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  // ── Moderation: Verify Citizen Residency ───────────────────────────────
  Future<void> _toggleUserVerification(
    BuildContext context,
    UserEntity user,
  ) async {
    final bool newStatus = !user.isVerified;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .update({'isVerified': newStatus});

      await sl<AuditLogRemoteDataSource>().recordLog(
        actionType: 'Citizen Moderation',
        details: '${newStatus ? "Verified" : "Revoked verification for"} citizen ${user.displayName ?? user.email} (UID: ${user.id})',
        targetId: user.id,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? "✓ Resident successfully verified against barangay records."
                  : "✓ Resident verification revoked.",
            ),
            backgroundColor: AdminColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update verification: $e"),
            backgroundColor: AdminColors.critical,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

/// Scrolls a wide table both ways inside its panel. The table is never
/// narrower than the panel and uses the kit's row lines.
class _ScrollingTable extends StatelessWidget {
  const _ScrollingTable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(21),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DividerTheme(
                data: const DividerThemeData(color: AdminTable.divider),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
