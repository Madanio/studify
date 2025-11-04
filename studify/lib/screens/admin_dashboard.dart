import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../database/database_helper.dart';
import '../models/absence.dart';
import '../models/student.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _authService = AuthService.instance;
  final _dbHelper = DatabaseHelper.instance;
  List<Student> _students = [];
  Student? _selectedStudent;
  List<Absence> _absences = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final students = await _dbHelper.getAllStudents();
    setState(() {
      _students = students;
      if (students.isNotEmpty) {
        _selectedStudent = students.first;
        _loadAbsences(students.first.studentId);
      }
      _isLoading = false;
    });
  }

  Future<void> _loadAbsences(String studentId) async {
    final absences = await _dbHelper.getAbsencesByStudent(studentId);
    setState(() {
      _absences = absences;
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _addAbsence() async {
    if (_selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un étudiant')),
      );
      return;
    }

    final result = await showDialog<Absence>(
      context: context,
      builder: (context) => _AddAbsenceDialog(student: _selectedStudent!),
    );

    if (result != null) {
      await _dbHelper.insertAbsence(result);
      await _loadAbsences(_selectedStudent!.studentId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Absence ajoutée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
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
        title: const Text('Administration'),
        backgroundColor: Colors.indigo.shade700,
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
          : Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.people),
                      selectedIcon: Icon(Icons.people),
                      label: Text('Étudiants'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.event_busy),
                      selectedIcon: Icon(Icons.event_busy),
                      label: Text('Absences'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _selectedIndex == 0
                      ? _buildStudentsView()
                      : _buildAbsencesView(),
                ),
              ],
            ),
    );
  }

  Widget _buildStudentsView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Liste des Étudiants',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddStudentDialog,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un étudiant'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _students.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun étudiant enregistré',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(student.name[0]),
                      ),
                      title: Text(student.name),
                      subtitle: Text('ID: ${student.studentId}'),
                      trailing: student.parentEmail != null
                          ? Chip(
                              label: Text(student.parentEmail!),
                              labelStyle: const TextStyle(fontSize: 10),
                            )
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAbsencesView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<Student>(
                value: _selectedStudent,
                hint: const Text('Sélectionner un étudiant'),
                items: _students.map((student) {
                  return DropdownMenuItem(
                    value: student,
                    child: Text(student.name),
                  );
                }).toList(),
                onChanged: (student) {
                  if (student != null) {
                    setState(() {
                      _selectedStudent = student;
                    });
                    _loadAbsences(student.studentId);
                  }
                },
              ),
              ElevatedButton.icon(
                onPressed: _addAbsence,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une absence'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _selectedStudent == null
              ? const Center(child: Text('Sélectionnez un étudiant'))
              : _absences.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: Colors.green.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucune absence pour ${_selectedStudent!.name}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _absences.length,
                      itemBuilder: (context, index) {
                        final absence = _absences[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
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
                                  backgroundColor:
                                      _getAbsenceTypeColor(absence.type),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _dbHelper.deleteAbsence(absence.id!);
                                await _loadAbsences(_selectedStudent!.studentId);
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Absence supprimée'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Future<void> _showAddStudentDialog() async {
    final nameController = TextEditingController();
    final studentIdController = TextEditingController();
    final parentEmailController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un étudiant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom complet',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: studentIdController,
              decoration: const InputDecoration(
                labelText: 'ID Étudiant',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: parentEmailController,
              decoration: const InputDecoration(
                labelText: 'Email parent (optionnel)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );

    if (result == true &&
        nameController.text.isNotEmpty &&
        studentIdController.text.isNotEmpty) {
      final student = Student(
        name: nameController.text,
        studentId: studentIdController.text,
        parentEmail: parentEmailController.text.isEmpty
            ? null
            : parentEmailController.text,
      );

      await _dbHelper.insertStudent(student);
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Étudiant ajouté avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class _AddAbsenceDialog extends StatefulWidget {
  final Student student;

  const _AddAbsenceDialog({required this.student});

  @override
  State<_AddAbsenceDialog> createState() => _AddAbsenceDialogState();
}

class _AddAbsenceDialogState extends State<_AddAbsenceDialog> {
  DateTime _selectedDate = DateTime.now();
  AbsenceType _selectedType = AbsenceType.unjustified;
  final _subjectController = TextEditingController();
  final _reasonController = TextEditingController();

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter une absence - ${widget.student.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat('dd MMMM yyyy', 'fr_FR').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Matière (optionnel)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Raison (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AbsenceType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: AbsenceType.values.map((type) {
                String label;
                switch (type) {
                  case AbsenceType.justified:
                    label = 'Justifiée';
                    break;
                  case AbsenceType.unjustified:
                    label = 'Non justifiée';
                    break;
                  case AbsenceType.late:
                    label = 'Retard';
                    break;
                }
                return DropdownMenuItem(
                  value: type,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            final absence = Absence(
              studentId: widget.student.studentId,
              date: _selectedDate,
              type: _selectedType,
              subject: _subjectController.text.isEmpty
                  ? null
                  : _subjectController.text,
              reason: _reasonController.text.isEmpty
                  ? null
                  : _reasonController.text,
            );
            Navigator.pop(context, absence);
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}
