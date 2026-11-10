import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Загружаем настройки до runApp.
  final darkMode = prefs.getBool('app_theme_dark_mode') ?? false;
  final username = prefs.getString('user_display_name') ?? 'Guest User';

  final notes = <NoteItem>[];
  final savedNotes = prefs.getString('user_notes_json');

  if (savedNotes != null) {
    try {
      final decoded = jsonDecode(savedNotes) as List<dynamic>;
      notes.addAll(
        decoded.map(
              (item) => NoteItem.fromJson(item as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      notes.clear();
    }
  }

  runApp(
    NotesApp(
      prefs: prefs,
      initialDarkMode: darkMode,
      initialUsername: username,
      initialNotes: notes,
    ),
  );
}

class NoteItem {
  final String id;
  final String title;
  final String dateText;
  final bool isCompleted;

  const NoteItem({
    required this.id,
    required this.title,
    required this.dateText,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dateText': dateText,
      'isCompleted': isCompleted,
    };
  }

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      id: json['id'] as String,
      title: json['title'] as String,
      dateText: json['dateText'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  NoteItem toggle() {
    return NoteItem(
      id: id,
      title: title,
      dateText: dateText,
      isCompleted: !isCompleted,
    );
  }
}

class NotesApp extends StatefulWidget {
  final SharedPreferences prefs;
  final bool initialDarkMode;
  final String initialUsername;
  final List<NoteItem> initialNotes;

  const NotesApp({
    super.key,
    required this.prefs,
    required this.initialDarkMode,
    required this.initialUsername,
    required this.initialNotes,
  });

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  late bool _darkMode;
  late String _username;
  late List<NoteItem> _notes;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _darkMode = widget.initialDarkMode;
    _username = widget.initialUsername;
    _notes = List.of(widget.initialNotes);
    _nameController.text = _username;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Ждём запись, затем обновляем экран.
  Future<void> _save(Future<void> Function() action) async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      await action();
    } catch (_) {
      _messengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Could not save. Try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _changeTheme(bool value) async {
    final saved = await widget.prefs.setBool(
      'app_theme_dark_mode',
      value,
    );

    if (!saved) throw StateError('Theme was not saved');
    _darkMode = value;
  }

  Future<void> _saveUsername() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final saved = await widget.prefs.setString(
      'user_display_name',
      name,
    );

    if (!saved) throw StateError('Name was not saved');
    _username = name;
  }

  Future<void> _saveNotes(List<NoteItem> updatedNotes) async {
    final jsonString = jsonEncode(
      updatedNotes.map((note) => note.toJson()).toList(),
    );

    final saved = await widget.prefs.setString(
      'user_notes_json',
      jsonString,
    );

    if (!saved) throw StateError('Notes were not saved');
    _notes = updatedNotes;
  }

  Future<void> _addNote() async {
    final title = _noteController.text.trim();
    if (title.isEmpty) return;

    final now = DateTime.now();

    final note = NoteItem(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      dateText: now.toString().substring(0, 16),
    );

    // Новая заметка добавляется в начало.
    await _saveNotes([note, ..._notes]);
    _noteController.clear();
  }

  Future<void> _toggleNote(String id) async {
    final updatedNotes = _notes.map((note) {
      return note.id == id ? note.toggle() : note;
    }).toList();

    await _saveNotes(updatedNotes);
  }

  Future<void> _deleteNote(String id) async {
    final updatedNotes = _notes.where((note) => note.id != id).toList();
    await _saveNotes(updatedNotes);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messengerKey,
      title: 'Notes',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(title: const Text('Notes')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Hello, $_username',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Dark mode'),
                    value: _darkMode,
                    onChanged: _saving
                        ? null
                        : (value) => _save(() => _changeTheme(value)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    enabled: !_saving,
                    maxLength: 60,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saving ? null : () => _save(_saveUsername),
                    child: const Text('Save'),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _noteController,
                    enabled: !_saving,
                    minLines: 1,
                    maxLines: 3,
                    maxLength: 120,
                    decoration: const InputDecoration(
                      labelText: 'New note',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saving ? null : () => _save(_addNote),
                    child: const Text('Add note'),
                  ),
                  const SizedBox(height: 16),
                  if (_notes.isEmpty)
                    const Text('No notes yet.'),
                  for (final note in _notes)
                    Card(
                      key: ValueKey(note.id),
                      child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        value: note.isCompleted,
                        onChanged: _saving
                            ? null
                            : (_) => _save(() => _toggleNote(note.id)),
                        title: Text(
                          note.title,
                          style: TextStyle(
                            decoration: note.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(note.dateText),
                        secondary: IconButton(
                          tooltip: 'Delete note',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: _saving
                              ? null
                              : () => _save(() => _deleteNote(note.id)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}