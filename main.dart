import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB1YaEdU2o4-7du52rF_NJbRmRhL_VrBzQ",
      authDomain: "minderly-5692b.firebaseapp.com",
      projectId: "minderly-5692b",
      storageBucket: "minderly-5692b.firebasestorage.app",
      messagingSenderId: "643567499004",
      appId: "1:643567499004:web:0d7648f26984dae5990979",
    ),
  );
  runApp(const MinderlyApp());
}

class MinderlyApp extends StatelessWidget {
  const MinderlyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF0D121F)),
    home: const AuthWrapper(),
  );
}

// --- JAR LOGO PAINTER ---
class JarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF4A89FF)..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromLTRBR(15, 0, size.width - 15, 12, const Radius.circular(4)), paint);
    canvas.drawRRect(RRect.fromLTRBR(5, 18, size.width - 5, size.height, const Radius.circular(12)), paint);
    final crossPaint = Paint()..color = const Color(0xFF0D121F)..strokeWidth = 8;
    canvas.drawLine(Offset(size.width/2, 45), Offset(size.width/2, 75), crossPaint);
    canvas.drawLine(Offset(size.width/2 - 15, 60), Offset(size.width/2 + 15, 60), crossPaint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- SHARED LOGOUT ---
Future<void> performLogout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  await FirebaseAuth.instance.signOut();
  if (!context.mounted) return;
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginPage()), (r) => false);
}

// --- LOGIN PAGE ---
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _fId = TextEditingController();
  _login(String role) async {
    if (_fId.text.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('familyId', _fId.text.trim());
    await prefs.setString('role', role);
    await FirebaseAuth.instance.signInAnonymously();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => role == 'caretaker' ? CaretakerDashboard(familyId: _fId.text) : SeniorDashboard(familyId: _fId.text)));
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CustomPaint(size: const Size(80, 100), painter: JarPainter()),
      const SizedBox(height: 20),
      const Text("Minderly", style: TextStyle(fontSize: 54, fontWeight: FontWeight.bold)),
      const SizedBox(height: 40),
      SizedBox(width: 320, child: TextField(controller: _fId, textAlign: TextAlign.center, decoration: const InputDecoration(hintText: "Enter Family ID", border: OutlineInputBorder()))),
      const SizedBox(height: 30),
      Row(mainAxisSize: MainAxisSize.min, children: [
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1F2C), shape: const StadiumBorder()), onPressed: () => _login('caretaker'), child: const Text("Caretaker")),
        const SizedBox(width: 20),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1F2C), shape: const StadiumBorder()), onPressed: () => _login('senior'), child: const Text("Senior")),
      ])
    ])),
  );
}

// --- CARETAKER SIDE ---
class CaretakerDashboard extends StatefulWidget {
  final String familyId;
  const CaretakerDashboard({super.key, required this.familyId});
  @override State<CaretakerDashboard> createState() => _CaretakerDashboardState();
}

class _CaretakerDashboardState extends State<CaretakerDashboard> {
  final TextEditingController _med = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();
  final List<String> weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  List<String> selectedDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: Colors.transparent, title: const Text("Caretaker View"), actions: [
      TextButton(onPressed: () => performLogout(context), child: const Text("logout", style: TextStyle(color: Colors.redAccent))),
    ]),
    body: Column(children: [
      Padding(padding: const EdgeInsets.all(12), child: Card(color: const Color(0xFF161B22), child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
        TextField(controller: _med, decoration: const InputDecoration(labelText: "Medicine Name")),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("Time: ${_time.format(context)}"),
          IconButton(icon: const Icon(Icons.timer), onPressed: () async {
            final t = await showTimePicker(context: context, initialTime: _time);
            if (t != null) setState(() => _time = t);
          }),
        ]),
        Wrap(spacing: 4, children: weekDays.map((d) => FilterChip(label: Text(d, style: const TextStyle(fontSize: 10)), selected: selectedDays.contains(d), onSelected: (v) => setState(() => v ? selectedDays.add(d) : selectedDays.remove(d)))).toList()),
        ElevatedButton(onPressed: () {
          if(_med.text.isEmpty) return;
          FirebaseFirestore.instance.collection('families').doc(widget.familyId).collection('reminders').add({'med': _med.text, 'hour': _time.hour, 'minute': _time.minute, 'days': selectedDays, 'lastFired': ''});
          _med.clear();
        }, child: const Text("SAVE REMINDER")),
      ])))),
      Expanded(child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('families').doc(widget.familyId).collection('reminders').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const LinearProgressIndicator();
          String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
          return ListView(children: snap.data!.docs.map((doc) {
            var d = doc.data() as Map;
            bool taken = d['lastFired'] == today;
            return ListTile(
              leading: Icon(taken ? Icons.check_circle : Icons.pending, color: taken ? Colors.green : Colors.orange),
              title: Text(d['med'], style: TextStyle(decoration: taken ? TextDecoration.lineThrough : null)),
              subtitle: Text("${d['hour']}:${d['minute'].toString().padLeft(2,'0')} | ${taken ? 'TAKEN' : 'PENDING'}"),
              trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.white24), onPressed: () => doc.reference.delete()),
            );
          }).toList());
        },
      ))
    ]),
  );
}

// --- SENIOR SIDE ---
class SeniorDashboard extends StatefulWidget {
  final String familyId;
  const SeniorDashboard({super.key, required this.familyId});
  @override State<SeniorDashboard> createState() => _SeniorDashboardState();
}

class _SeniorDashboardState extends State<SeniorDashboard> {
  final FlutterTts tts = FlutterTts();
  Timer? _loop;
  Timer? _clockTimer;
  String? _ringingId;
  bool _unlocked = false;
  String _currentTime = "";

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _currentTime = DateFormat('hh:mm:ss a').format(DateTime.now()));
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _stop();
    super.dispose();
  }

  void _ring(String med, String id) {
    if (_ringingId == id) return;
    _ringingId = id;
    _loop?.cancel();
    _loop = Timer.periodic(const Duration(seconds: 6), (t) {
      if (_ringingId == id) { tts.speak("Time for $med. Please take it now."); } else { t.cancel(); }
    });
  }

  void _stop() { _ringingId = null; _loop?.cancel(); tts.stop(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(automaticallyImplyLeading: false, backgroundColor: Colors.transparent, title: const Text("Senior Dashboard"), actions: [
      TextButton(onPressed: () { _stop(); performLogout(context); }, child: const Text("logout", style: TextStyle(color: Colors.redAccent))),
    ]),
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('families').doc(widget.familyId).collection('reminders').snapshots(),
      builder: (context, snap) {
        if (!_unlocked) return Center(child: ElevatedButton(onPressed: () => setState(() => _unlocked = true), child: const Text("START MONITORING")));
        
        DateTime now = DateTime.now();
        String today = DateFormat('yyyy-MM-dd').format(now);
        String dayName = DateFormat('E').format(now);

        var active = snap.hasData ? snap.data!.docs.where((doc) {
          var d = doc.data() as Map;
          bool isCorrectDay = (d['days'] as List).contains(dayName);
          bool isTime = (now.hour > d['hour']) || (now.hour == d['hour'] && now.minute >= d['minute']);
          return isCorrectDay && isTime && d['lastFired'] != today;
        }).toList() : [];

        return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // LIVE CLOCK
            Text(_currentTime, style: const TextStyle(fontSize: 32, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),

            if (active.isNotEmpty) ...[
              const Icon(Icons.alarm, color: Colors.red, size: 80),
              Text(active.first['med'].toString().toUpperCase(), style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(60), shape: const CircleBorder()),
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('families').doc(widget.familyId).collection('reminders').doc(active.first.id).update({'lastFired': today});
                  _stop();
                  setState(() {});
                },
                child: const Text("DONE")),
              // Trigger sound
              Builder(builder: (c) { 
                WidgetsBinding.instance.addPostFrameCallback((_) => _ring(active.first['med'], active.first.id));
                return const SizedBox();
              }),
            ] else 
              const Text("No pending medicines.", style: TextStyle(fontSize: 18, color: Colors.white54)),
          ]),
        );
      },
    ),
  );
}

// --- AUTH WRAPPER ---
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});
  @override State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() { super.initState(); _check(); }
  _check() async {
    final prefs = await SharedPreferences.getInstance();
    final String? fId = prefs.getString('familyId'), role = prefs.getString('role');
    if (fId != null && role != null && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => 
        role == 'caretaker' ? CaretakerDashboard(familyId: fId) : SeniorDashboard(familyId: fId)));
    } else { Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginPage())); }
  }
  @override Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}