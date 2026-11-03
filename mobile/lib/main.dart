import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const green = Color(0xFF174C3C);

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: green),
    ),
    home: const Directionality(
      textDirection: TextDirection.rtl,
      child: TreeApp(),
    ),
  ));
}

class TreeApp extends StatefulWidget {
  const TreeApp({super.key});
  @override
  State<TreeApp> createState() => _TreeAppState();
}

class _TreeAppState extends State<TreeApp> {
  List<Map<String, String>> people = [];
  bool busy = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonDecode(prefs.getString('tree') ?? '[]') as List;
    final loaded = raw.map((e) => Map<String, String>.from(e)).toList();
    if (!mounted) return;
    setState(() {
      people = loaded;
      busy = false;
    });
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tree', jsonEncode(people));
  }

  String personName(String id) {
    for (final p in people) {
      if (p['id'] == id) return p['name'] ?? '';
    }
    return '';
  }

  Future<void> addPerson() async {
    final name = TextEditingController();
    final birth = TextEditingController();
    String? father;
    String? mother;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, refreshDialog) => AlertDialog(
          title: const Text('افزودن فرد به شجره'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'نام و نام خانوادگی *'),
                ),
                TextField(
                  controller: birth,
                  decoration: const InputDecoration(labelText: 'سال تولد (اختیاری)'),
                ),
                DropdownButtonFormField<String?>(
                  value: father,
                  decoration: const InputDecoration(labelText: 'پدر'),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('ثبت نشده')),
                    ...people.map((p) => DropdownMenuItem<String?>(
                      value: p['id'], child: Text(p['name'] ?? ''),
                    )),
                  ],
                  onChanged: (v) => refreshDialog(() => father = v),
                ),
                DropdownButtonFormField<String?>(
                  value: mother,
                  decoration: const InputDecoration(labelText: 'مادر'),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('ثبت نشده')),
                    ...people.map((p) => DropdownMenuItem<String?>(
                      value: p['id'], child: Text(p['name'] ?? ''),
                    )),
                  ],
                  onChanged: (v) => refreshDialog(() => mother = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('لغو'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );

    if (ok == true && name.text.trim().isNotEmpty) {
      setState(() {
        people.add({
          'id': DateTime.now().microsecondsSinceEpoch.toString(),
          'name': name.text.trim(),
          'birth': birth.text.trim(),
          'father': father ?? '',
          'mother': mother ?? '',
        });
      });
      await save();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فرد در گوشی ذخیره شد.')),
        );
      }
    }
    name.dispose();
    birth.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شجره‌نامه خانواده'),
        backgroundColor: green,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addPerson,
        backgroundColor: green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('افزودن فرد'),
      ),
      body: busy
          ? const Center(child: CircularProgressIndicator())
          : people.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Text(
                      'برای شروع، بزرگ‌ترهای خانواده را ثبت کن. سپس هنگام افزودن فرزندان، پدر و مادرشان را انتخاب کن.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, height: 1.8),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.people, color: green),
                        title: Text('تعداد افراد: ${people.length}'),
                      ),
                    ),
                    ...people.map((p) {
                      final details = <String>[];
                      if ((p['birth'] ?? '').isNotEmpty) {
                        details.add('تولد: ${p['birth']}');
                      }
                      if ((p['father'] ?? '').isNotEmpty) {
                        details.add('پدر: ${personName(p['father']!)}');
                      }
                      if ((p['mother'] ?? '').isNotEmpty) {
                        details.add('مادر: ${personName(p['mother']!)}');
                      }
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(p['name'] ?? ''),
                          subtitle: Text(details.isEmpty
                              ? 'اطلاعات تکمیلی ثبت نشده'
                              : details.join(' • ')),
                        ),
                      );
                    }),
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'اطلاعات فعلاً فقط روی همین گوشی ذخیره می‌شود و همگام‌سازی اینترنتی ندارد.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
    );
  }
}
