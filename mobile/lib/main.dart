import 'package:flutter/material.dart';

void main() => runApp(const ShajarehApp());

const forest = Color(0xFF174C3C);
const cream = Color(0xFFF7F4EC);

class ShajarehApp extends StatelessWidget {
  const ShajarehApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'شجره‌نامه',
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(seedColor: forest, surface: cream),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(backgroundColor: forest, foregroundColor: Colors.white),
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  final pages = const [Overview(), TreePage(), MembersPage(), ArchivePage()];
  final titles = ['خانه خاندان', 'شجره‌نامه', 'اعضای خاندان', 'آرشیو خانوادگی'];
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: Text(titles[tab]), actions: [IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('در نسخه بعدی فعال می‌شود'))), icon: const Icon(Icons.notifications_none))]),
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'خانه'),
          NavigationDestination(icon: Icon(Icons.account_tree_outlined), label: 'شجره'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'اعضا'),
          NavigationDestination(icon: Icon(Icons.photo_library_outlined), label: 'آرشیو'),
        ],
      ),
    ),
  );
}

class Overview extends StatelessWidget {
  const Overview({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(18), children: [
    Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(colors: [forest, Color(0xFF286A51)])),
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('به خانواده خوش آمدید', style: TextStyle(color: Colors.white70, fontSize: 14)),
        SizedBox(height: 9),
        Text('خاندان احمدی', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('پیوند نسل‌ها، ماندگاری خاطرات', style: TextStyle(color: Colors.white70)),
      ]),
    ),
    const SizedBox(height: 18),
    const Row(children: [
      Expanded(child: StatCard(icon: Icons.people_alt_outlined, number: '۱۲۸', label: 'عضو خاندان')),
      SizedBox(width: 10),
      Expanded(child: StatCard(icon: Icons.account_tree_outlined, number: '۶', label: 'نسل ثبت‌شده')),
      SizedBox(width: 10),
      Expanded(child: StatCard(icon: Icons.collections_outlined, number: '۴۲', label: 'سند و عکس')),
    ]),
    const SizedBox(height: 22),
    const Text('رویدادهای پیش رو', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),
    const EventTile(icon: Icons.cake_outlined, title: 'تولد مریم احمدی', subtitle: 'پنج‌شنبه · ۱۸ آبان'),
    const EventTile(icon: Icons.favorite_border, title: 'سالگرد ازدواج', subtitle: 'شنبه · ۲۰ آبان'),
    const EventTile(icon: Icons.park_outlined, title: 'دورهمی خانوادگی', subtitle: 'جمعه · ۲۶ آبان'),
    const SizedBox(height: 16),
    const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('این نسخه، پیش‌نمایش اولیه اپلیکیشن است. اطلاعات و نام‌ها نمونه هستند و هنوز به سرور متصل نشده‌اند.', style: TextStyle(height: 1.9)))),
  ]);
}

class StatCard extends StatelessWidget {
  final IconData icon; final String number; final String label;
  const StatCard({super.key, required this.icon, required this.number, required this.label});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 7), child: Column(children: [
    Icon(icon, color: forest), const SizedBox(height: 9),
    Text(number, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: forest)),
    const SizedBox(height: 5), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black54)),
  ])));
}

class EventTile extends StatelessWidget {
  final IconData icon; final String title; final String subtitle;
  const EventTile({super.key, required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: CircleAvatar(backgroundColor: const Color(0xFFF0E9D9), child: Icon(icon, color: forest)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text(subtitle)));
}

class TreePage extends StatelessWidget {
  const TreePage({super.key});
  Widget person(String name, String role, {bool highlight = false}) => Container(
    width: 145, padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: highlight ? const Color(0xFFEAF2EB) : Colors.white, border: Border.all(color: highlight ? forest : const Color(0xFFE0E6DF), width: highlight ? 2 : 1), borderRadius: BorderRadius.circular(15)),
    child: Column(children: [
      CircleAvatar(backgroundColor: const Color(0xFFE6EEE7), child: Icon(Icons.person, color: forest)),
      const SizedBox(height: 7), Text(name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 4), Text(role, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black54)),
    ]),
  );
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('نمای نمونه از نسل‌های خاندان', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
    const SizedBox(height: 22),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [person('احمد احمدی', 'پدربزرگ'), const SizedBox(width: 12), person('زهرا رضایی', 'مادربزرگ')]),
    const Center(child: Icon(Icons.more_vert, size: 34, color: Colors.black38)),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [person('محمد احمدی', 'پدر شما'), const SizedBox(width: 12), person('حسین احمدی', 'عمو')]),
    const Center(child: Icon(Icons.more_vert, size: 34, color: Colors.black38)),
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [person('علی احمدی', 'شما', highlight: true), const SizedBox(width: 12), person('سارا احمدی', 'دخترعمو')]),
    const Center(child: Icon(Icons.more_vert, size: 34, color: Colors.black38)),
    Center(child: person('آراد احمدی', 'فرزند شما')),
    const SizedBox(height: 20),
    const Text('در نسخه کامل، شاخه‌ها و نسبت‌های خانوادگی به‌صورت تعاملی و بر اساس روابط تأییدشده نمایش داده می‌شوند.', textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, height: 1.8)),
  ]);
}

class MembersPage extends StatelessWidget {
  const MembersPage({super.key});
  @override
  Widget build(BuildContext context) {
    final people = [('محمد احمدی','پدر · مدیر خاندان'),('زهرا رضایی','مادربزرگ'),('سارا احمدی','دخترعمو'),('آراد احمدی','فرزند شما')];
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('افراد ثبت‌شده در خاندان احمدی', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      ...people.map((p) => Card(child: ListTile(leading: const CircleAvatar(backgroundColor: Color(0xFFE7EEE8), child: Icon(Icons.person, color: forest)), title: Text(p.$1), subtitle: Text(p.$2), trailing: const Icon(Icons.chevron_left)))),
    ]);
  }
}

class ArchivePage extends StatelessWidget {
  const ArchivePage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: const [
    Text('گنجینه خاطرات خاندان', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    SizedBox(height: 14),
    EventTile(icon: Icons.photo_library_outlined, title: 'عکس‌های خانوادگی', subtitle: '۳۲ تصویر نمونه'),
    EventTile(icon: Icons.description_outlined, title: 'نامه‌ها و دست‌نوشته‌ها', subtitle: '۶ سند نمونه'),
    EventTile(icon: Icons.menu_book_outlined, title: 'خاطرات و روایت‌ها', subtitle: '۴ روایت نمونه'),
  ]);
}
