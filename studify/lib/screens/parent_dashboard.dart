import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../database/database_helper.dart';
import '../models/absence.dart';
import '../models/student.dart';
import 'login_screen.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final _authService = AuthService.instance;
  final _dbHelper = DatabaseHelper.instance;
  List<Student> _children = [];
  Map<String, List<Absence>> _absencesByChild = {};
  Student? _selectedChild;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final username = await _authService.getLoggedInUsername();
    if (username != null) {
      final children = await _dbHelper.getStudentsByParent(username);
      final Map<String, List<Absence>> absencesMap = {};

      for (var child in children) {
        final absences = await _dbHelper.getAbsencesByStudent(child.studentId);
        absencesMap[child.studentId] = absences;
      }

      setState(() {
        _children = children;
        _absencesByChild = absencesMap;
        if (children.isNotEmpty) {
          _selectedChild = children.first;
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Color _getAbsenceTypeColor(AbsenceType type) {
    switch (type) {
      case AbsenceType.justified:
        return Colors.green;
      case AbsenceType.unjustified:
        return Colors.red;
      case AbsenceType.late:
        return Colors.orange;
    }
  }

  String _getAbsenceTypeText(AbsenceType type) {
    switch (type) {
      case AbsenceType.justified:
        return 'Justifiée';
      case AbsenceType.unjustified:
        return 'Non justifiée';
      case AbsenceType.late:
        return 'Retard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi des Absences'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _children.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.child_care,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun enfant associé à votre compte',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.purple.shade100,
                                  child: Icon(
                                    Icons.family_restroom,
                                    size: 30,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Accès Parental',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_children.length} enfant${_children.length > 1 ? 's' : ''}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_children.length > 1) ...[
                          Text(
                            'Sélectionner un enfant:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _children.length,
                              itemBuilder: (context, index) {
                                final child = _children[index];
                                final isSelected =
                                    _selectedChild?.studentId == child.studentId;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(child.name),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedChild = child;
                                        });
                                      }
                                    },
                                    selectedColor: Colors.purple.shade200,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (_selectedChild != null) ...[
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.purple.shade100,
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedChild!.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'ID: ${_selectedChild!.studentId}',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      '${_absencesByChild[_selectedChild!.studentId]?.length ?? 0} absence(s)',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor: Colors.purple.shade100,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Absences',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _buildAbsencesList(
                              _absencesByChild[_selectedChild!.studentId] ??
                                  []),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildAbsencesList(List<Absence> absences) {
    if (absences.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.green.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune absence enregistrée',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: absences.length,
      itemBuilder: (context, index) {
        final absence = absences[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getAbsenceTypeColor(absence.type).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                absence.type == AbsenceType.late
                    ? Icons.schedule
                    : absence.type == AbsenceType.justified
                        ? Icons.check_circle
                        : Icons.cancel,
                color: _getAbsenceTypeColor(absence.type),
              ),
            ),
            title: Text(
              DateFormat('dd MMMM yyyy', 'fr_FR').format(absence.date),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (absence.subject != null)
                  Text('Matière: ${absence.subject}'),
                if (absence.reason != null)
                  Text('Raison: ${absence.reason}'),
                const SizedBox(height: 4),
                Chip(
                  label: Text(
                    _getAbsenceTypeText(absence.type),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: _getAbsenceTypeColor(absence.type),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
