import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../database/database_helper.dart';
import '../models/absence.dart';
import '../models/student.dart';
import 'login_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final _authService = AuthService.instance;
  final _dbHelper = DatabaseHelper.instance;
  List<Absence> _absences = [];
  Student? _student;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final username = await _authService.getLoggedInUsername();
    if (username != null) {
      final student = await _dbHelper.getStudent(username);
      final absences = await _dbHelper.getAbsencesByStudent(username);

      setState(() {
        _student = student;
        _absences = absences;
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
        title: const Text('Mes Absences'),
        backgroundColor: Colors.blue.shade700,
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
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _student == null
                  ? const Center(child: Text('Étudiant non trouvé'))
                  : SingleChildScrollView(
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
                                    backgroundColor: Colors.blue.shade100,
                                    child: Icon(
                                      Icons.person,
                                      size: 30,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _student!.name,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'ID: ${_student!.studentId}',
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mes Absences',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Chip(
                                label: Text(
                                  'Total: ${_absences.length}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: Colors.blue.shade100,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_absences.isEmpty)
                            Card(
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
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _absences.length,
                              itemBuilder: (context, index) {
                                final absence = _absences[index];
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
                                        color: _getAbsenceTypeColor(absence.type)
                                            .withOpacity(0.2),
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
                                      DateFormat('dd MMMM yyyy', 'fr_FR')
                                          .format(absence.date),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          backgroundColor:
                                              _getAbsenceTypeColor(absence.type),
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
            ),
    );
  }
}
