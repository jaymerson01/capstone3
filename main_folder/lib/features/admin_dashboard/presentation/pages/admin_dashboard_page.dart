import 'package:flutter/material.dart';
import '../../data/models/incident_report.dart';
import '../services/admin_data_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/custom_line_chart.dart';
import '../widgets/custom_pie_chart.dart';
import '../constants/admin_colors.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = AdminDataService();
    final double screenWidth = MediaQuery.of(context).size.width;
    
    // Breakpoints for charts and cards layout
    final bool isDesktop = screenWidth >= 1100;
    final bool isTablet = screenWidth >= 700 && screenWidth < 1100;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: ListenableBuilder(
        listenable: dataService,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Text header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome, ${dataService.adminName}!",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Here is a summary of community safety incident reports in Moonwalk.",
                        style: TextStyle(
                          fontSize: 14,
                          color: AdminColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  // Date indicator matching screenshot style
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AdminColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: AdminColors.primaryGreen),
                        const SizedBox(width: 8),
                        Text(
                          "Today: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Statistics Cards Grid (rearranges based on breakpoint)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.6,
                children: [
                  StatCard(
                    title: "Incident Reports",
                    value: dataService.totalIncidents.toString(),
                    icon: Icons.warning_amber_rounded,
                    backgroundColor: AdminColors.cardRed, // Red color from mockup
                  ),
                  StatCard(
                    title: "Total Area",
                    value: dataService.totalAreas.toString(),
                    icon: Icons.map_outlined,
                    backgroundColor: AdminColors.cardBlue, // Blue color from mockup
                  ),
                  StatCard(
                    title: "Solved Cases",
                    value: dataService.solvedCases.toString(),
                    icon: Icons.check_circle_outline,
                    backgroundColor: AdminColors.cardGreen, // Green color from mockup
                  ),
                  StatCard(
                    title: "Registered Users",
                    value: dataService.registeredUsers.toString(),
                    icon: Icons.people_alt_outlined,
                    backgroundColor: AdminColors.cardYellow, // Yellow color from mockup
                    textColor: Colors.black87,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Charts Layout (horizontal on desktop, vertical on tablet/mobile)
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      flex: 6,
                      child: CustomLineChart(),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      flex: 4,
                      child: CustomPieChart(),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    const CustomLineChart(),
                    const SizedBox(height: 20),
                    const CustomPieChart(),
                  ],
                ),
              const SizedBox(height: 24),

              // Recent Incidents list quick widget (for premium admin feel)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Recent Urgent Incidents",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.textDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Quick tip: navigation handled inside the shell's stateful layout.
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Navigate to 'Incident Reports' tab from sidebar to view full list."),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: const Text(
                            "View All Reports",
                            style: TextStyle(
                              color: AdminColors.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: dataService.reports.take(3).length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final report = dataService.reports[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: report.statusColor.withOpacity(0.15),
                            child: Icon(
                              report.status == IncidentStatus.solved 
                                  ? Icons.check 
                                  : report.status == IncidentStatus.inProgress 
                                      ? Icons.rotate_right 
                                      : Icons.priority_high,
                              color: report.statusColor == AdminColors.pendingYellow 
                                  ? Colors.orange.shade800 // Make yellow text readable on white
                                  : report.statusColor,
                            ),
                          ),
                          title: Text(
                            "${report.incidentType} - ${report.location}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            "Reported by ${report.reporterName} • ${report.date.day}/${report.date.month}/${report.date.year}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: report.statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              report.statusLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: report.statusColor == AdminColors.pendingYellow 
                                    ? Colors.orange.shade800
                                    : report.statusColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
