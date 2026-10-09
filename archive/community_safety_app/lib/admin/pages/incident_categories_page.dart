import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/admin_data_service.dart';
import '../constants/admin_colors.dart';
import '../../widgets/custom_3d_card.dart';

class IncidentCategoriesPage extends StatefulWidget {
  const IncidentCategoriesPage({super.key});

  @override
  State<IncidentCategoriesPage> createState() => _IncidentCategoriesPageState();
}

class _IncidentCategoriesPageState extends State<IncidentCategoriesPage> {
  final dataService = AdminDataService();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth >= 1000
        ? 3
        : (screenWidth >= 600 ? 2 : 1);

    return ListenableBuilder(
      listenable: dataService,
      builder: (context, _) {
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
                child: dataService.categories.isEmpty
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
                        itemCount: dataService.categories.length,
                        itemBuilder: (context, index) {
                          final category = dataService.categories[index];
                          return _buildCategoryCard(context, category);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, IncidentCategory category) {
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
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Add New Category", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Category Name",
                      hintText: "e.g. Environmental Hazard",
                      filled: true,
                      fillColor: AdminColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? "Enter category name"
                        : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Description",
                      hintText: "Enter explanation of what this category covers...",
                      filled: true,
                      fillColor: AdminColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      alignLabelWithHint: true,
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? "Enter category explanation"
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryRose,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newCat = IncidentCategory(
                    id: "CAT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                  );
                  dataService.addCategory(newCat);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Category '${newCat.name}' created successfully",
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text("Add Category"),
            ),
          ],
        );
      },
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    IncidentCategory category,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: category.name);
    final descController = TextEditingController(text: category.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Edit Category: ${category.name}", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Category Name",
                      filled: true,
                      fillColor: AdminColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? "Enter category name"
                        : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Description",
                      filled: true,
                      fillColor: AdminColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      alignLabelWithHint: true,
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? "Enter category explanation"
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryRose,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final updated = category.copyWith(
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                  );
                  dataService.editCategory(updated);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Category successfully updated"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text("Save Changes"),
            ),
          ],
        );
      },
    );
  }

  void _confirmArchiveCategory(BuildContext context, IncidentCategory category) {
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
                dataService.archiveCategory(category.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Category '${category.name}' archived successfully",
                    ),
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
