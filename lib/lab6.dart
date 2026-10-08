import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: Register()));

class Register extends StatefulWidget {
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final key = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final confirm = TextEditingController();

  bool terms = false, error = false;
  String role = 'Student';

  void submit() {
    setState(() => error = !terms);
    if (key.currentState!.validate() && terms) {
      print('${name.text}, ${email.text}, ${pass.text}, $role');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Registration')),
    body: SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: key,
        autovalidateMode: AutovalidateMode.always,
        child: Column(children: [
          TextFormField(
            controller: name,
            decoration: InputDecoration(labelText: 'Full Name'),
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Enter name' : null,
          ),
          TextFormField(
            controller: email,
            decoration: InputDecoration(labelText: 'Email'),
            validator: (v) => v == null ||
                !v.contains('@') || !v.contains('.')
                ? 'Invalid email' : null,
          ),
          TextFormField(
            controller: pass,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
            validator: (v) => (v?.length ?? 0) < 6
                ? 'Minimum 6 characters' : null,
          ),
          TextFormField(
            controller: confirm,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Confirm Password'),
            validator: (v) => v != pass.text
                ? 'Passwords do not match' : null,
          ),
          DropdownButtonFormField<String>(
            initialValue: role,
            items: ['Student', 'Teacher', 'Developer']
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) => setState(() => role = v!),
          ),
          CheckboxListTile(
            title: Text('I accept the Terms and Conditions'),
            value: terms,
            onChanged: (v) => setState(() {
              terms = v!;
              error = !terms;
            }),
          ),
          if (error)
            Text('Accept the terms',
                style: TextStyle(color: Colors.red)),
          ElevatedButton(onPressed: submit, child: Text('Register')),
        ]),
      ),
    ),
  );
}