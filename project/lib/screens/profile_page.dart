import 'package:flutter/material.dart';
import 'package:happiness_hub/models/user_profile.dart';
import 'package:happiness_hub/services/auth_service.dart';
import 'package:happiness_hub/services/firestore_service.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _professionController;
  DateTime? _dateOfBirth;
  UserProfile? _originalProfile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _professionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  // Populates controllers and updates the UI state
  void _setInitialValues(UserProfile profile) {
    _originalProfile = profile;
    _nameController.text = profile.name;
    _phoneController.text = profile.phoneNumber;
    _professionController.text = profile.profession;
    // This setState call is crucial to update the UI with the new data
    setState(() {
      _dateOfBirth = profile.dateOfBirth;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final uid = _authService.currentUser!.uid;
      final dataToUpdate = {
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'profession': _professionController.text.trim(),
        'dateOfBirth': _dateOfBirth,
      };
      _firestoreService.updateUserProfile(uid, dataToUpdate).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        setState(() {
          _isEditing = false;
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = _authService.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text("User not logged in.")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: StreamBuilder<UserProfile>(
        stream: _firestoreService.getUserProfile(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _originalProfile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load profile.'));
          }
          
          // When new data arrives from the stream, update the controllers.
          if (snapshot.hasData) {
            final userProfile = snapshot.data!;
            // FIX: Check if the data is new before scheduling an update.
            // This prevents an infinite loop of updates.
            if (_originalProfile == null || _originalProfile!.uid != userProfile.uid) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _setInitialValues(userProfile);
                    }
                });
            }
          }
          
          if (_originalProfile == null) {
             // Show a loader until the first set of data is processed.
             return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfileField(
                    label: 'Name',
                    controller: _nameController,
                  ),
                  _buildProfileField(
                    label: 'Profession',
                    controller: _professionController,
                  ),
                  _buildProfileField(
                    label: 'Email',
                    value: _originalProfile!.email,
                  ),
                  _buildProfileField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  _isEditing
                      ? _buildDatePicker()
                      : _buildProfileField(
                          label: 'Date of Birth',
                          value: _dateOfBirth == null
                              ? 'Not set'
                              : DateFormat.yMd().format(_dateOfBirth!),
                        ),
                  if (_isEditing) _buildActionButtons(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: !_isEditing
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Profile'),
            )
          : null,
    );
  }

  Widget _buildProfileField({
    required String label,
    String? value,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: _isEditing && controller != null
          ? TextFormField(
              controller: controller,
              decoration: InputDecoration(labelText: label),
              keyboardType: keyboardType,
            )
          : ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(label, style: const TextStyle(color: Colors.grey)),
              subtitle: Text(
                value ?? controller?.text ?? '',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Date of Birth: ${_dateOfBirth == null ? 'Not set' : DateFormat.yMd().format(_dateOfBirth!)}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                _isEditing = false;
                if (_originalProfile != null) {
                  _setInitialValues(_originalProfile!);
                }
              });
            },
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _saveProfile,
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}