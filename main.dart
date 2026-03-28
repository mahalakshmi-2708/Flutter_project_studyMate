import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';

void main() {
  runApp(StudentHub());
}

// ================= GLOBAL DATA =================

class AppData {
  static int attended = 0;
  static int total = 0;
  static int required = 75;

  static List<String> notes = [];
  static List<Map> tasks = [];

  static int pomodoroSessions = 0;
}

// ================= APP =================

class StudentHub extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: HomeScreen(),
    );
  }
}

// ================= HOME =================

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int streak = 0;
  int selectedIndex = 0;

  List<String> quotes = [
    "Push yourself, no one else will 💪",
    "Focus now, relax later 😎",
    "Success needs consistency 🔥",
    "Your future is created today 🚀"
  ];

  String currentQuote = "";

  @override
  void initState() {
    super.initState();
    changeQuote();
  }

  void changeQuote() {
    final r = Random();
    currentQuote = quotes[r.nextInt(quotes.length)];
  }

  void markDone() {
    setState(() {
      streak++;
    });
  }

  Widget card(String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
            context, MaterialPageRoute(builder: (_) => screen));
        setState(() {}); // refresh dashboard
      },
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent]),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            SizedBox(height: 10),
            Text(title,
                style: TextStyle(color: Colors.white, fontSize: 16))
          ],
        ),
      ),
    );
  }

  // ================= DASHBOARD =================

  Widget dashboard() {
    double attendancePercent = 0;

    if (AppData.total > 0) {
      attendancePercent =
          (AppData.attended / AppData.total) * 100;
    }

    int pendingTasks =
        AppData.tasks.where((t) => t["done"] == false).length;

    int notesCount = AppData.notes.length;

    String focusStatus = AppData.pomodoroSessions == 0
        ? "Start"
        : AppData.pomodoroSessions < 3
            ? "Average"
            : "Good";

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(12),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.purpleAccent]),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(currentQuote,
                    style: TextStyle(color: Colors.white)),
                SizedBox(height: 10),
                Text("🔥 Streak: $streak days",
                    style: TextStyle(color: Colors.white)),
                ElevatedButton(
                    onPressed: markDone,
                    child: Text("Mark as Done"))
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                    child: perfCard("Attendance",
                        "${attendancePercent.toStringAsFixed(1)}%", Colors.green)),
                SizedBox(width: 10),
                Expanded(
                    child: perfCard("Focus", focusStatus, Colors.orange)),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                    child: perfCard(
                        "Tasks", "$pendingTasks Pending", Colors.red)),
                SizedBox(width: 10),
                Expanded(
                    child:
                        perfCard("Notes", "$notesCount Saved", Colors.blue)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget perfCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  Widget features() {
    return GridView.count(
      crossAxisCount: 2,
      children: [
        card("Attendance", Icons.school, AttendanceScreen()),
        card("Pomodoro", Icons.timer, PomodoroScreen()),
        card("Notes", Icons.note, NotesScreen()),
        card("ToDo", Icons.check, TodoScreen()),
        card("Planner", Icons.calendar_today, PlannerScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Student Hub")),
      body: selectedIndex == 0 ? dashboard() : features(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: "Features"),
        ],
      ),
    );
  }
}

// ================= ATTENDANCE =================

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  TextEditingController attendedCtrl = TextEditingController();
  TextEditingController totalCtrl = TextEditingController();
  TextEditingController reqCtrl = TextEditingController();

  String result = "";

  void calculate() {
    int attended = int.tryParse(attendedCtrl.text) ?? 0;
    int total = int.tryParse(totalCtrl.text) ?? 0;
    int req = int.tryParse(reqCtrl.text) ?? 75;

    AppData.attended = attended;
    AppData.total = total;
    AppData.required = req;

    int x = 0;

    while (((attended + x) / (total + x)) * 100 < req) {
      x++;
    }

    setState(() {
      result = "Attend next $x classes to reach $req%";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: attendedCtrl, decoration: InputDecoration(labelText: "Attended")),
            TextField(controller: totalCtrl, decoration: InputDecoration(labelText: "Total")),
            TextField(controller: reqCtrl, decoration: InputDecoration(labelText: "Required %")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: calculate, child: Text("Calculate")),
            SizedBox(height: 20),
            Text(result)
          ],
        ),
      ),
    );
  }
}

// ================= POMODORO =================

class PomodoroScreen extends StatefulWidget {
  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  int focusTime = 20 * 60;
  int breakTime = 5 * 60;
  int time = 20 * 60;

  Timer? timer;
  bool isRunning = false;
  bool isBreak = false;

  void start() {
    if (isRunning) return;

    isRunning = true;
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (time > 0) {
        setState(() => time--);
      } else {
        if (!isBreak) {
          AppData.pomodoroSessions++;
          setState(() {
            isBreak = true;
            time = breakTime;
          });
        } else {
          stop();
        }
      }
    });
  }

  void pause() {
    timer?.cancel();
    isRunning = false;
  }

  void stop() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      isBreak = false;
      time = focusTime;
    });
  }

  String format() {
    int m = time ~/ 60;
    int s = time % 60;
    return "$m:${s.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pomodoro")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isBreak ? "Break Time ☕" : "Focus Time 📚"),
            SizedBox(height: 20),
            Text(format(), style: TextStyle(fontSize: 50)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: start, child: Text("Start")),
                ElevatedButton(onPressed: pause, child: Text("Pause")),
                ElevatedButton(onPressed: stop, child: Text("Stop")),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// ================= NOTES =================

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<String> get notes => AppData.notes;
  TextEditingController controller = TextEditingController();

  void add() {
    if (controller.text.isEmpty) return;
    setState(() {
      notes.add(controller.text);
      controller.clear();
    });
  }

  void delete(int i) => setState(() => notes.removeAt(i));

  void update(int i) {
    controller.text = notes[i];
    notes.removeAt(i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notes")),
      body: Column(
        children: [
          TextField(controller: controller),
          ElevatedButton(onPressed: add, child: Text("Add")),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(notes[i]),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: Icon(Icons.edit), onPressed: () => update(i)),
                    IconButton(icon: Icon(Icons.delete), onPressed: () => delete(i)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ================= TODO =================

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Map> get tasks => AppData.tasks;
  TextEditingController controller = TextEditingController();

  void add() {
    if (controller.text.isEmpty) return;
    tasks.add({"task": controller.text, "done": false});
    controller.clear();
    setState(() {});
  }

  void delete(int i) => setState(() => tasks.removeAt(i));

  void toggle(int i) {
    tasks[i]["done"] = !tasks[i]["done"];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ToDo")),
      body: Column(
        children: [
          TextField(controller: controller),
          ElevatedButton(onPressed: add, child: Text("Add")),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(tasks[i]["task"]),
                leading: Checkbox(
                    value: tasks[i]["done"],
                    onChanged: (_) => toggle(i)),
                trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => delete(i)),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ================= PLANNER =================

class PlannerScreen extends StatefulWidget {
  @override
  _PlannerScreenState createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  List<Map> plans = [];

  void addPlan() async {
    TextEditingController ctrl = TextEditingController();

    DateTime? date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2023),
        lastDate: DateTime(2030));

    if (date == null) return;

    TimeOfDay? time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (time == null) return;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text("Add Plan"),
              content: TextField(controller: ctrl),
              actions: [
                TextButton(
                    onPressed: () {
                      plans.add({
                        "task": ctrl.text,
                        "date": DateFormat.yMd().format(date),
                        "time": time.format(context)
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: Text("Save"))
              ],
            ));
  }

  void delete(int i) => setState(() => plans.removeAt(i));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Planner")),
      floatingActionButton:
          FloatingActionButton(onPressed: addPlan, child: Icon(Icons.add)),
      body: ListView.builder(
        itemCount: plans.length,
        itemBuilder: (_, i) => ListTile(
          title: Text(plans[i]["task"]),
          subtitle: Text("${plans[i]["date"]} | ${plans[i]["time"]}"),
          trailing:
              IconButton(icon: Icon(Icons.delete), onPressed: () => delete(i)),
        ),
      ),
    );
  }
}
