import 'package:flutter/material.dart';
import 'package:happiness_hub/models/person.dart';
import 'package:happiness_hub/services/firestore_service.dart';

class AddEditPersonPage extends StatefulWidget {
  final Person? person; // If person is null, it's a new entry

  const AddEditPersonPage({super.key, this.person});

  @override
  State<AddEditPersonPage> createState() => _AddEditPersonPageState();
}

class _AddEditPersonPageState extends State<AddEditPersonPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late TextEditingController _nameController;
  late TextEditingController _relationshipController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _notesController;
  late double _connectionStrength;

  @override
  void initState() {
    super.initState();
    
    _nameController = TextEditingController(text: widget.person?.name ?? '');
    _relationshipController = TextEditingController(text: widget.person?.relationship ?? '');
    _phoneController = TextEditingController(text: widget.person?.phone ?? '');
    _emailController = TextEditingController(text: widget.person?.email ?? '');
    _notesController = TextEditingController(text: widget.person?.notes ?? '');
    _connectionStrength = widget.person?.connectionStrength.toDouble() ?? 3.0;
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newPerson = Person(
        id: widget.person?.id ?? '', 
        name: _nameController.text,
        relationship: _relationshipController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        notes: _notesController.text,
        connectionStrength: _connectionStrength.toInt(),
      );

      if (widget.person == null) {
        
        _firestoreService.addPerson(newPerson);
      } else {
        
        _firestoreService.updatePerson(newPerson);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person == null ? 'Add Person' : 'Edit Person'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _relationshipController,
                decoration: const InputDecoration(labelText: 'Relationship (e.g., Best Friend)'),
                validator: (value) => value!.isEmpty ? 'Please enter a relationship' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 30),
              Text('Connection Strength: ${_connectionStrength.toInt()}', style: Theme.of(context).textTheme.titleMedium),
              Slider(
                value: _connectionStrength,
                min: 1,
                max: 5,
                divisions: 4,
                label: _connectionStrength.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _connectionStrength = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes & Details',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                maxLines: 7,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
