import 'package:flutter/material.dart';
import 'package:community_safety_app/core/theme/admin_colors.dart';
import 'package:community_safety_app/core/presentation/widgets/custom_3d_card.dart';

class IncidentCategoryDummy {
  final String id;
  final String name;
  final String description;

  IncidentCategoryDummy({required this.id, required this.name, required this.description});
}

class IncidentCategoriesPage extends StatefulWidget {
  const IncidentCategoriesPage({super.key});

  @override
  State<IncidentCategoriesPage> createState() => _IncidentCategoriesPageState();
}

class _IncidentCategoriesPageState extends State<IncidentCategoriesPage> {
  // Dummy data representing state from BLoC
  final List<IncidentCategoryDummy> _dummyCategories = [
    IncidentCategoryDummy(
      id: "CAT-101",
      name: "Medical Emergency",
      description: "Heart attacks, severe injuries, sudden illness, and other life-threatening medical situations.",
    ),
    IncidentCategoryDummy(
      id: "CAT-102",
      name: "Fire Hazard",
      description: "Building fires, wildfires, gas leaks, and severe electrical hazards.",
    ),
    IncidentCategoryDummy(
      id: "CAT-103",
      name: "Crime / Violence",
      description: "Theft, assault, vandalism, suspicious activities, and active threats.",
    ),
    IncidentCategoryDummy(
      id: "CAT-104",
      name: "Traffic Accident",
      description: "Vehicle collisions, hit-and-runs, and major road blockages.",
    ),
    IncidentCategoryDummy(
      id: "CAT-105",
      name: "Natural Disaster",
      description: "Flooding, earthquakes, landslides, and severe weather damage.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth >= 1000
        ? 3
        : (screenWidth >= 600 ? 2 : 1);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Manage Incident Categories",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AdminColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Define incident categories available in the mobile reporting app.",
                    style: TextStyle(
                      fontSize: 13,
                      color: AdminColors.textLight,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdminColors.primaryRose,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                onPressed: () => _showAddCategoryDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  "Add Category",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          Expanded(
            child: _dummyCategories.isEmpty
                ? const Center(
                    child: Text(
                      "No incident categories defined yet.",
                      style: TextStyle(
                        color: AdminColors.textLight,
                        fontSize: 15,
                      ),
                    ),
                  )
                : GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: _dummyCategories.length,
                    itemBuilder: (context, index) {
                      final category = _dummyCategories[index];
                      return _buildCategoryCard(context, category);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, IncidentCategoryDummy category) {
    return Custom3dCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AdminColors.primaryRose.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.folder_open_outlined,
                      color: AdminColors.primaryRose,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AdminColors.textDark,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                    tooltip: "Edit Category",
                    onPressed: () => _showEditCategoryDialog(context, category),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.archive,
                      color: AdminColors.dangerRed,
                      size: 18,
                    ),
                    tooltip: "Archive Category",
                    onPressed: () => _confirmArchiveCategory(context, category),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              category.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AdminColors.textLight,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    // TODO: Trigger AddCategoryEvent to BLoC
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Add New Category", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const SizedBox(
            width: 400,
            child: Text("BLoC integration pending for adding categories."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(BuildContext context, IncidentCategoryDummy category) {
    // TODO: Trigger EditCategoryEvent to BLoC
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Edit Category: ${category.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: const SizedBox(
            width: 400,
            child: Text("BLoC integration pending for editing categories."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _confirmArchiveCategory(BuildContext context, IncidentCategoryDummy category) {
    // TODO: Trigger ArchiveCategoryEvent to BLoC
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Archive Category", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            "Are you sure you want to archive category '${category.name}'? This won't affect past submitted reports of this type but will prevent new submissions.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.dangerRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Mock: Category archived. Pending BLoC integration."),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text("Archive"),
            ),
          ],
        );
      },
    );
  }
}
