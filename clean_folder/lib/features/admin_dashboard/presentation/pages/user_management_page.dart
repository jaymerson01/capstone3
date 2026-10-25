import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';
import 'package:community_safety_app/features/auth/data/models/user_model.dart';
import 'package:community_safety_app/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_bloc.dart';
import 'package:community_safety_app/features/incident/presentation/bloc/incident_state.dart';
import 'package:community_safety_app/core/services/injection_container.dart';
import 'package:community_safety_app/features/admin_dashboard/data/datasources/audit_log_remote_data_source.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';

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
          // ── Title & Header ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AdminColors.violet, AdminColors.violetDeep],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AdminColors.violet.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.people_alt_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Citizen Directory & User Management",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AdminColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        "Registered Barangay Moonwalk residents, emergency contact dossiers, and moderation",
                        style: TextStyle(
                          fontSize: 12,
                          color: AdminColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),

          // ── Search & Filter Controls ───────────────────────────────
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AdminColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AdminColors.border),
                  ),
                  child: TextField(
                    style: const TextStyle(
                      color: AdminColors.textDark,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          "Search by citizen name, email, phone, sector...",
                      hintStyle: const TextStyle(
                        color: AdminColors.textMuted,
                        fontSize: 12.5,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AdminColors.textLight,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: AdminColors.cardBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
              ),
              SizedBox(width: 16),

              // Status Filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AdminColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdminColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _statusFilter,
                    dropdownColor: AdminColors.cardBackground,
                    style: const TextStyle(
                      color: AdminColors.textDark,
                      fontSize: 13,
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AdminColors.violet,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "All",
                        child: Text("All Statuses"),
                      ),
                      DropdownMenuItem(
                        value: "Active",
                        child: Text("Active Accounts"),
                      ),
                      DropdownMenuItem(
                        value: "Suspended",
                        child: Text("Suspended Accounts"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _statusFilter = val);
                    },
                  ),
                ),
              ),
              SizedBox(width: 12),

              // Role Filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AdminColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdminColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _roleFilter,
                    dropdownColor: AdminColors.cardBackground,
                    style: const TextStyle(
                      color: AdminColors.textDark,
                      fontSize: 13,
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AdminColors.violet,
                    ),
                    items: const [
                      DropdownMenuItem(value: "All", child: Text("All Roles")),
                      DropdownMenuItem(
                        value: "resident",
                        child: Text("Residents Only"),
                      ),
                      DropdownMenuItem(
                        value: "admin",
                        child: Text("Admins Only"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _roleFilter = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

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
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AdminColors.violet,
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

                return Custom3dCard(
                  padding: const EdgeInsets.all(12),
                  borderRadius: 22,
                  child: filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_search_outlined,
                                color: AdminColors.borderStrong,
                                size: 56,
                              ),
                              SizedBox(height: 14),
                              Text(
                                "No citizen accounts match the criteria",
                                style: TextStyle(
                                  color: AdminColors.textLight,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowHeight: 50,
                              headingRowColor: WidgetStateProperty.all(
                                AdminColors.background,
                              ),
                              dataRowColor: WidgetStateProperty.resolveWith(
                                (states) => states.contains(WidgetState.hovered)
                                    ? AdminColors.cardBackground
                                        .withValues(alpha: 0.8)
                                    : Colors.transparent,
                              ),
                              dividerThickness: 0.5,
                              columns: const [
                                DataColumn(
                                  label: Text(
                                    "Citizen Name",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AdminColors.textLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Contact Info",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AdminColors.textLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Barangay Sector / Address",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AdminColors.textLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Role",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AdminColors.textLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Status",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AdminColors.textLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Verification",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AdminColors.textLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    "Actions",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AdminColors.textLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                              rows: filteredUsers.map((user) {
                                final bool isActive = user.isActive;
                                final Color statusColor = isActive
                                    ? AdminColors.success
                                    : AdminColors.danger;

                                return DataRow(
                                  cells: [
                                    // Name + Avatar
                                    DataCell(
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
                                              borderRadius: BorderRadius.circular(16),
                                              child: CircleAvatar(
                                                radius: 16,
                                                backgroundColor: user.isAdmin
                                                    ? AdminColors.violet
                                                        .withValues(alpha: 0.25)
                                                    : AdminColors.cyan
                                                        .withValues(alpha: 0.2),
                                                backgroundImage: (user.photoUrl != null &&
                                                        user.photoUrl!.isNotEmpty)
                                                    ? NetworkImage(user.photoUrl!)
                                                    : null,
                                                child: (user.photoUrl == null ||
                                                        user.photoUrl!.isEmpty)
                                                    ? Text(
                                                        (user.displayName != null &&
                                                                user.displayName!
                                                                    .isNotEmpty)
                                                            ? user.displayName![0]
                                                                .toUpperCase()
                                                            : 'U',
                                                        style: TextStyle(
                                                          color: user.isAdmin
                                                              ? AdminColors.violet
                                                              : AdminColors.cyan,
                                                          fontWeight: FontWeight.w900,
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user.displayName ??
                                                    "Unnamed Citizen",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: AdminColors.textDark,
                                                  fontSize: 12.5,
                                                ),
                                              ),
                                              Text(
                                                "ID: ${user.id.length > 8 ? user.id.substring(0, 8) : user.id}",
                                                style: const TextStyle(
                                                  color: AdminColors.textMuted,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Contact (Email + Phone)
                                    DataCell(
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.email,
                                            style: const TextStyle(
                                              color: AdminColors.textSoft,
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (user.phoneNumber != null &&
                                              user.phoneNumber!.isNotEmpty)
                                            Text(
                                              user.phoneNumber!,
                                              style: const TextStyle(
                                                color: AdminColors.textLight,
                                                fontSize: 11,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Sector / Address
                                    DataCell(
                                      SizedBox(
                                        width: 160,
                                        child: Text(
                                          user.barangayArea ??
                                              user.address ??
                                              "Barangay Moonwalk",
                                          style: const TextStyle(
                                            color: AdminColors.textLight,
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    // Role Badge (Read-Only)
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: user.isAdmin
                                              ? AdminColors.violet
                                                  .withValues(alpha: 0.15)
                                              : AdminColors.cyan
                                                  .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: user.isAdmin
                                                ? AdminColors.violet
                                                    .withValues(alpha: 0.4)
                                                : AdminColors.cyan
                                                    .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Text(
                                          user.isAdmin
                                              ? "Barangay Admin"
                                              : "Citizen Resident",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: user.isAdmin
                                                ? AdminColors.violetLight
                                                : AdminColors.cyan,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Status Badge
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                            alpha: 0.15,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: statusColor.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          isActive ? "Active" : "Suspended",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Verification Badge
                                    DataCell(
                                      Row(
                                        children: [
                                          Icon(
                                            user.isVerified
                                                ? Icons.verified_rounded
                                                : Icons.pending_outlined,
                                            size: 15,
                                            color: user.isVerified
                                                ? AdminColors.primary
                                                : AdminColors.textLight,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            user.isVerified
                                                ? "Verified"
                                                : "Unverified",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: user.isVerified
                                                  ? AdminColors.primary
                                                  : AdminColors.textLight,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Actions
                                    DataCell(
                                      Row(
                                        children: [
                                          // View Citizen Dossier Modal
                                          IconButton(
                                            icon: Icon(
                                              Icons.badge_outlined,
                                              color: AdminColors.cyan,
                                              size: 20,
                                            ),
                                            tooltip:
                                                "View Citizen Emergency Dossier",
                                            onPressed: () =>
                                                _showCitizenDossier(
                                              context,
                                              user,
                                            ),
                                          ),
                                          // Suspend / Reactivate Account Toggle
                                          IconButton(
                                            icon: Icon(
                                              isActive
                                                  ? Icons.block_flipped
                                                  : Icons.check_circle_outline,
                                              color: isActive
                                                  ? AdminColors.amber
                                                  : AdminColors.success,
                                              size: 20,
                                            ),
                                            tooltip: isActive
                                                ? "Suspend Account (Spam / Fake Reports)"
                                                : "Reactivate Account",
                                            onPressed: () =>
                                                _toggleUserActiveStatus(
                                              context,
                                              user,
                                            ),
                                          ),
                                          // Verify Resident Toggle
                                          IconButton(
                                            icon: Icon(
                                              user.isVerified
                                                  ? Icons.verified
                                                  : Icons.verified_outlined,
                                              color: user.isVerified
                                                  ? AdminColors.primary
                                                  : AdminColors.textLight,
                                              size: 20,
                                            ),
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

        return Dialog(
          backgroundColor: AdminColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AdminColors.border),
          ),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modal Top Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // Interactive Citizen Avatar (Click to enlarge)
                            Builder(
                              builder: (avatarCtx) {
                                final bool hasPhoto = user.photoUrl != null &&
                                    user.photoUrl!.isNotEmpty;
                                return Tooltip(
                                  message: hasPhoto
                                      ? "Click to view enlarged photo"
                                      : "No photo uploaded",
                                  waitDuration:
                                      const Duration(milliseconds: 300),
                                  child: InkWell(
                                    onTap: () {
                                      if (hasPhoto) {
                                        _showEnlargedPhotoDialog(context, user);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
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
                                    borderRadius: BorderRadius.circular(36),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(2.5),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: hasPhoto
                                                  ? AdminColors.cyan
                                                      .withValues(alpha: 0.6)
                                                  : AdminColors.border,
                                              width: 2,
                                            ),
                                            boxShadow: hasPhoto
                                                ? [
                                                    BoxShadow(
                                                      color:
                                                          AdminColors.cyan
                                                              .withValues(
                                                                  alpha: 0.25),
                                                      blurRadius: 10,
                                                      spreadRadius: 1,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: CircleAvatar(
                                            radius: 28,
                                            backgroundColor: user.isAdmin
                                                ? AdminColors.violet
                                                    .withValues(alpha: 0.25)
                                                : AdminColors.cyan
                                                    .withValues(alpha: 0.2),
                                            backgroundImage: hasPhoto
                                                ? NetworkImage(user.photoUrl!)
                                                : null,
                                            child: !hasPhoto
                                                ? Text(
                                                    (user.displayName != null &&
                                                            user.displayName!
                                                                .isNotEmpty)
                                                        ? user.displayName![0]
                                                            .toUpperCase()
                                                        : 'U',
                                                    style: TextStyle(
                                                      color: user.isAdmin
                                                          ? const Color(
                                                              0xFF7C4DFF)
                                                          : const Color(
                                                              0xFF00E5FF),
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 20,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ),
                                        if (hasPhoto)
                                          Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AdminColors.cardBackground,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color:
                                                      AdminColors.cyan,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.zoom_in_rounded,
                                                size: 13,
                                                color: AdminColors.cyan,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.displayName ?? "Citizen Resident",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: AdminColors.textDark,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "UID: ${user.id}",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AdminColors.textLight,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (user.photoUrl != null &&
                                      user.photoUrl!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.touch_app_outlined,
                                            size: 11,
                                            color: AdminColors.cyan,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            "Click avatar to enlarge",
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AdminColors.cyan,
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
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: AdminColors.textLight),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  Divider(color: AdminColors.border),
                  SizedBox(height: 14),

                  // Resident Identity & Account Attributes
                  _dossierSectionHeader("Citizen Profile & Identification"),
                  SizedBox(height: 8),
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

                  SizedBox(height: 18),
                  // EMERGENCY CONTACT DOSSIER (Critical for dispatchers!)
                  _dossierSectionHeader("Life-Safety Emergency Contacts"),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AdminColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AdminColors.danger.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.contact_emergency_rounded,
                              color: AdminColors.danger,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Designated Emergency Contact",
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: AdminColors.danger,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Person: ${user.emergencyContactName ?? 'None on file'}",
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AdminColors.textDark,
                              ),
                            ),
                            Text(
                              "Phone: ${user.emergencyContactNumber ?? 'None on file'}",
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AdminColors.cyan,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18),
                  // Report Ledger Activity
                  _dossierSectionHeader("Incident Blotter Activity"),
                  SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AdminColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AdminColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              "$citizenReportsCount",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AdminColors.primary,
                              ),
                            ),
                            Text(
                              "Submitted Reports",
                              style: TextStyle(
                                fontSize: 10,
                                color: AdminColors.textLight,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              user.isVerified ? "YES" : "NO",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: user.isVerified
                                    ? AdminColors.success
                                    : AdminColors.textLight,
                              ),
                            ),
                            Text(
                              "Residency Verified",
                              style: TextStyle(
                                fontSize: 10,
                                color: AdminColors.textLight,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              user.isActive ? "ACTIVE" : "SUSPENDED",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: user.isActive
                                    ? AdminColors.success
                                    : AdminColors.danger,
                              ),
                            ),
                            Text(
                              "Account Standing",
                              style: TextStyle(
                                fontSize: 10,
                                color: AdminColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        "Close Dossier",
                        style: TextStyle(color: AdminColors.textLight),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
        return Dialog(
          backgroundColor: AdminColors.dialogBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AdminColors.border, width: 1.5),
          ),
          child: Container(
            width: 520,
            constraints: const BoxConstraints(maxHeight: 680),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AdminColors.cyan
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.portrait_rounded,
                              color: AdminColors.cyan,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.displayName ?? "Citizen Resident",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AdminColors.textDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2),
                                Text(
                                  "UID: ${user.id} • ${user.barangayArea ?? 'Barangay Moonwalk'}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AdminColors.textLight,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AdminColors.textLight),
                      onPressed: () => Navigator.pop(ctx),
                      splashRadius: 20,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(color: AdminColors.border, height: 1),
                SizedBox(height: 16),

                // High-resolution photo container with InteractiveViewer
                Flexible(
                  child: Container(
                    width: double.infinity,
                    constraints:
                        const BoxConstraints(maxHeight: 440, minHeight: 280),
                    decoration: BoxDecoration(
                      color: AdminColors.well,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AdminColors.border),
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
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
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
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.broken_image_rounded,
                                          size: 48,
                                          color: AdminColors.danger,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          "Failed to load image",
                                          style: TextStyle(
                                            color: AdminColors.textDark,
                                            fontWeight: FontWeight.bold,
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
                ),

                SizedBox(height: 14),

                // Controls and footer actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.zoom_in, size: 14, color: AdminColors.textLight),
                        SizedBox(width: 4),
                        Text(
                          "Pinch or scroll to zoom • Drag to pan",
                          style: TextStyle(
                            fontSize: 11,
                            color: AdminColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            final uri = Uri.tryParse(user.photoUrl!);
                            if (uri != null) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: Icon(Icons.open_in_new, size: 14),
                          label: Text("Open Original"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AdminColors.cyan,
                            side: const BorderSide(color: AdminColors.cyan),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminColors.border,
                            foregroundColor: AdminColors.textDark,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text("Close",
                              style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dossierSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AdminColors.textLight,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _dossierRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AdminColors.textLight),
          SizedBox(width: 8),
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AdminColors.textLight,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AdminColors.textDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AdminColors.border),
        ),
        title: Text(
          "$actionText Citizen Account?",
          style: const TextStyle(
            color: AdminColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          newStatus
              ? "Are you sure you want to reactivate ${user.displayName ?? user.email}'s account?"
              : "Suspending ${user.displayName ?? user.email} will immediately prevent them from submitting emergency reports or signing into the civic app (curbing spam / prank calls).",
          style: const TextStyle(color: AdminColors.textLight, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel", style: TextStyle(color: AdminColors.textLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus
                  ? AdminColors.success
                  : AdminColors.danger,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              actionText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
              backgroundColor: Colors.red,
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
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
