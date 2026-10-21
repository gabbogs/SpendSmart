import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _accountType = 'Student';

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;

      _nameController.text = data['name'] ?? '';

      _accountType =
          data['accountType'] ?? 'Student';
    } else {
      _nameController.text =
          user.email?.split('@').first ?? '';
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() => _isSaving = true);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
      'name': _nameController.text.trim(),
      'email': user.email ?? '',
      'accountType': _accountType,
      'currency': 'PHP',
      'defaultIncomeLabel':
      _accountType == 'Student'
          ? 'Baon'
          : 'Salary',
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Profile updated successfully',
        ),
      ),
    );

    Navigator.pop(context);
  }

  Widget _accountTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _accountType == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _accountType = title);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primary.withOpacity(0.12)
                : Colors.white,
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? AppTheme.primary
                  : Colors.grey.shade300,
              width: selected ? 1.7 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected
                    ? AppTheme.primary
                    : AppTheme.textLight,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: selected
                      ? AppTheme.primary
                      : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.fromLTRB(
            22,
            12,
            22,
            30,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w800,
                    color:
                    AppTheme.textDark,
                  ),
                ),

                const SizedBox(height: 14),

                TextFormField(
                  controller:
                  _nameController,
                  decoration:
                  const InputDecoration(
                    hintText:
                    'Name',
                    prefixIcon: Icon(
                      Icons
                          .person_outline_rounded,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value
                            .trim()
                            .isEmpty) {
                      return 'Name is required';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 26),

                const Text(
                  'Account Type',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.w800,
                    color:
                    AppTheme.textDark,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    _accountTypeCard(
                      title:
                      'Student',
                      subtitle:
                      'Baon, school gastos',
                      icon: Icons
                          .school_rounded,
                    ),

                    const SizedBox(
                        width: 12),

                    _accountTypeCard(
                      title:
                      'Young Professional',
                      subtitle:
                      'Salary, bills, savings',
                      icon: Icons
                          .work_rounded,
                    ),
                  ],
                ),

                const SizedBox(height: 34),

                ElevatedButton.icon(
                  onPressed:
                  _isSaving
                      ? null
                      : _saveProfile,
                  icon: const Icon(
                    Icons.save_rounded,
                  ),
                  label: Text(
                    _isSaving
                        ? 'Saving...'
                        : 'Save Profile',
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight
                          .w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}