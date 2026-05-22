import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/incident_model.dart';
import '../blocs/incident_bloc.dart';
import '../widgets/incident_card.dart';

class IncidentOverviewPage extends StatefulWidget {
  const IncidentOverviewPage({super.key});

  @override
  State<IncidentOverviewPage> createState() => _IncidentOverviewPageState();
}

class _IncidentOverviewPageState extends State<IncidentOverviewPage> {
  @override
  void initState() {
    super.initState();
    // Dispatch LoadIncidents event when the screen is initialized
    context.read<IncidentBloc>().add(const LoadIncidents());
  }

  Widget logoBox() {
    return Container(
      height: 40,
      width: 40,
      padding: const EdgeInsets.all(3),
      color: Colors.white,
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkGreen = Color(0xFF004D00); // Exact color from unrefactored screen theme

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            logoBox(),
            const SizedBox(width: 10),
            const Text(
              "Safe Moonwalk My Report",
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.grey),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("My Reports", style: TextStyle(fontSize: 16)),
                const Spacer(),
                Container(
                  width: 90,
                  height: 28,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(width: 8),
                      Icon(Icons.search, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                color: Colors.grey.shade300,
                child: BlocBuilder<IncidentBloc, IncidentState>(
                  builder: (context, state) {
                    if (state is IncidentLoading || state is IncidentInitial) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(darkGreen),
                        ),
                      );
                    }

                    if (state is IncidentError) {
                      return Center(
                        child: Text(
                          state.errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (state is IncidentLoaded) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              filterButton(
                                context,
                                "ALL",
                                null,
                                state.selectedFilter == null,
                              ),
                              const SizedBox(width: 8),
                              filterButton(
                                context,
                                "Pending",
                                IncidentStatus.pending,
                                state.selectedFilter == IncidentStatus.pending,
                              ),
                              const SizedBox(width: 8),
                              filterButton(
                                context,
                                "In Progress",
                                IncidentStatus.verified,
                                state.selectedFilter == IncidentStatus.verified,
                              ),
                              const SizedBox(width: 8),
                              filterButton(
                                context,
                                "Resolve",
                                IncidentStatus.resolved,
                                state.selectedFilter == IncidentStatus.resolved,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: state.filteredIncidents.isEmpty
                                ? const Center(
                                    child: Text(
                                      "No reports found",
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: state.filteredIncidents.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 22),
                                    itemBuilder: (context, index) {
                                      return IncidentCard(
                                        incident: state.filteredIncidents[index],
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterButton(
    BuildContext context,
    String text,
    IncidentStatus? status,
    bool isActive,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<IncidentBloc>().add(FilterIncidents(status));
        },
        child: Container(
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
