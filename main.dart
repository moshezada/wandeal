import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// הדבק כאן כתובת Worker כדי למשוך דילים מהשרת; ריק = רשימה מוטמעת
const String apiBase = "";

void main() => runApp(const TravelDealsApp());

class TravelDealsApp extends StatelessWidget {
  const TravelDealsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelDeals LIVE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E1320),
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF6B35),
          surface: Color(0xFF171F31),
        ),
      ),
      locale: const Locale('he'),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const HomePage(),
    );
  }
}

class Deal {
  final int id;
  final String cat, region, title, dest, now, old, urg, emoji;
  final int disc;
  final Color color;
  double ageMin;
  int viewers;
  String link;
  Deal({
    required this.id, required this.cat, required this.region, required this.title,
    required this.dest, required this.now, required this.old, required this.urg,
    required this.emoji, required this.disc, required this.color,
    required this.ageMin, required this.viewers, required this.link,
  });
}

final List<Deal> seedDeals = [
  Deal(id:1,cat:"טיסות",region:"יוון",title:"טיסה ישירה לאתונה",dest:"תל אביב→אתונה",now:"₪99",old:"₪240",disc:59,urg:"נגמר היום",emoji:"✈️",color:const Color(0xFF3A7BD5),ageMin:6,viewers:148,link:"https://www.aviasales.com/"),
  Deal(id:2,cat:"טיסות",region:"הונגריה",title:"בודפשט הלוך-חזור",dest:"תל אביב→בודפשט",now:"₪320",old:"₪520",disc:38,urg:"מחירים עולים",emoji:"✈️",color:const Color(0xFF3A7BD5),ageMin:41,viewers:73,link:"https://www.aviasales.com/"),
  Deal(id:3,cat:"מלונות",region:"יוון",title:"מלון 4★ על האי",dest:"האיים היווניים",now:"€310",old:"€480",disc:35,urg:"נשארו 4 חדרים",emoji:"🏖️",color:const Color(0xFFFF7A59),ageMin:18,viewers:96,link:"https://www.booking.com/"),
  Deal(id:4,cat:"מלונות",region:"איחוד האמירויות",title:"מלון יוקרה בדובאי",dest:"דובאי",now:"\$120",old:"\$200",disc:40,urg:"מבצע קיץ",emoji:"🌆",color:const Color(0xFFFF7A59),ageMin:120,viewers:54,link:"https://www.booking.com/"),
  Deal(id:5,cat:"אטרקציות",region:"יוון",title:"אקרופוליס — דלג על התור",dest:"אתונה",now:"€27",old:"€38",disc:29,urg:"אוזל מהר",emoji:"🏛️",color:const Color(0xFFFFD34D),ageMin:9,viewers:61,link:"https://www.getyourguide.com/"),
  Deal(id:6,cat:"אטרקציות",region:"צרפת",title:"הלובר — כניסה מהירה",dest:"פריז",now:"€22",old:"€30",disc:27,urg:"נגמר בסופ\"ש",emoji:"🎨",color:const Color(0xFFFFD34D),ageMin:33,viewers:40,link:"https://www.tiqets.com/"),
  Deal(id:7,cat:"הופעות",region:"בלגיה",title:"Tomorrowland 2026 — חבילה",dest:"בום, בלגיה",now:"חבילה",old:"",disc:0,urg:"כרטיסים אוזלים",emoji:"🎶",color:const Color(0xFFA06BFF),ageMin:75,viewers:210,link:"https://www.getyourguide.com/"),
  Deal(id:8,cat:"הופעות",region:"הונגריה",title:"פסטיבל Sziget",dest:"בודפשט",now:"כרטיס",old:"",disc:0,urg:"שלב עם טיסה",emoji:"🎤",color:const Color(0xFFA06BFF),ageMin:50,viewers:88,link:"https://www.getyourguide.com/"),
  Deal(id:9,cat:"הופעות",region:"אירופה",title:"The Weeknd — סיבוב אירופה",dest:"ערים נבחרות",now:"כרטיסים",old:"",disc:0,urg:"תאריכים מתמלאים",emoji:"⭐",color:const Color(0xFFA06BFF),ageMin:15,viewers:175,link:"https://www.getyourguide.com/"),
  Deal(id:10,cat:"חבילות",region:"ספרד",title:"ברצלונה בתקופת Sónar",dest:"ברצלונה",now:"₪1,290",old:"₪1,800",disc:28,urg:"סוף יוני מתקרב",emoji:"🏝️",color:const Color(0xFF27D086),ageMin:3,viewers:132,link:"https://www.booking.com/"),
  Deal(id:11,cat:"מלונות",region:"ישראל",title:"מלון בוטיק באילת",dest:"אילת",now:"₪690",old:"₪990",disc:30,urg:"לסופ\"ש הקרוב",emoji:"🌅",color:const Color(0xFFFF7A59),ageMin:22,viewers:67,link:"https://www.booking.com/"),
  Deal(id:12,cat:"אטרקציות",region:"ישראל",title:"כרטיסים לפארק מים",dest:"מרכז",now:"₪129",old:"₪179",disc:28,urg:"מבצע קיץ",emoji:"💦",color:const Color(0xFFFFD34D),ageMin:65,viewers:33,link:"https://www.getyourguide.com/"),
];

const cats = ["הכל", "טיסות", "מלונות", "אטרקציות", "הופעות", "חבילות"];

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Deal> deals = List.of(seedDeals);
  String sortMode = "hot"; // hot | you | new
  String activeCat = "הכל";
  int tab = 0; // 0 feed, 1 fav, 2 about
  Set<int> favs = {};
  Map<String, double> aff = {};
  Timer? _timer;
  final ScrollController _ticker = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
    _fetchRemote();
    // עדכון "חי": צופים וזמן מתקדמים
    _timer = Timer.periodic(const Duration(seconds: 7), (_) {
      setState(() {
        for (final d in deals) {
          d.viewers = (d.viewers + ((DateTime.now().millisecond % 7) - 3)).clamp(8, 999);
          d.ageMin += 0.25;
        }
      });
    });
    // טיקר נע
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoScroll());
  }

  void _autoScroll() async {
    while (mounted && _ticker.hasClients) {
      await Future.delayed(const Duration(milliseconds: 40));
      if (!_ticker.hasClients) break;
      final max = _ticker.position.maxScrollExtent;
      var next = _ticker.offset + 1.2;
      if (next >= max) next = 0;
      _ticker.jumpTo(next);
    }
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      favs = (p.getStringList('favs') ?? []).map(int.parse).toSet();
      final a = p.getString('aff');
      if (a != null) aff = Map<String, double>.from(json.decode(a).map((k, v) => MapEntry(k, (v as num).toDouble())));
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    p.setStringList('favs', favs.map((e) => e.toString()).toList());
    p.setString('aff', json.encode(aff));
  }

  Future<void> _fetchRemote() async {
    if (apiBase.isEmpty) return;
    try {
      final r = await http.get(Uri.parse("${apiBase.replaceAll(RegExp(r'/$'), '')}/api/deals"));
      if (r.statusCode == 200) {
        final j = json.decode(r.body);
        final list = (j['deals'] as List?) ?? [];
        if (list.isNotEmpty) {
          setState(() {
            deals = list.map<Deal>((d) => Deal(
              id: d['id'], cat: d['cat'] ?? '', region: d['region'] ?? '',
              title: d['title'] ?? '', dest: d['dest'] ?? '', now: d['now'] ?? '',
              old: d['old'] ?? '', urg: d['urg'] ?? '', emoji: d['emoji'] ?? '🔥',
              disc: d['disc'] ?? 0, color: const Color(0xFF3A7BD5),
              ageMin: (d['ageMin'] ?? 30).toDouble(), viewers: d['viewers'] ?? 50,
              link: d['link'] ?? '#',
            )).toList();
          });
        }
      }
    } catch (_) {}
  }

  double heat(Deal d) {
    final freshness = (42 - d.ageMin * 0.55).clamp(0, 42).toDouble();
    final scarcity = RegExp('נגמר|אוזל|נשאר|היום|מתמלא').hasMatch(d.urg) ? 16.0 : 0.0;
    final velocity = (d.viewers * 0.12).clamp(0, 22).toDouble();
    return d.disc * 0.6 + freshness + scarcity + velocity;
  }

  double personal(Deal d) => heat(d) + (aff[d.cat] ?? 0) * 9 + (aff[d.region] ?? 0) * 5;
  double score(Deal d) => sortMode == "you" ? personal(d) : heat(d);

  void learn(Deal d) {
    aff[d.cat] = (aff[d.cat] ?? 0) + 1;
    aff[d.region] = (aff[d.region] ?? 0) + 0.6;
    _save();
  }

  Color gauge(double s) => s > 70 ? const Color(0xFFFF3B3B) : s > 45 ? const Color(0xFFFF6B35) : const Color(0xFF3A7BD5);
  String ago(double m) => m < 60 ? "לפני ${m.round()} ד׳" : "לפני ${(m / 60).round()} ש׳";

  List<Deal> get visible => deals.where((d) => activeCat == "הכל" || d.cat == activeCat).toList();
  List<Deal> get ordered {
    final l = List.of(visible);
    if (sortMode == "new") {
      l.sort((a, b) => a.ageMin.compareTo(b.ageMin));
    } else {
      l.sort((a, b) => score(b).compareTo(score(a)));
    }
    return l;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          _header(),
          Expanded(child: _body()),
        ]),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0B1019),
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Text("📡", style: TextStyle(fontSize: 18)), label: "פיד חי"),
          NavigationDestination(icon: Text("⭐", style: TextStyle(fontSize: 18)), label: "שמורים"),
          NavigationDestination(icon: Text("⚙️", style: TextStyle(fontSize: 18)), label: "איך זה עובד"),
        ],
      ),
    );
  }

  Widget _header() {
    final top = (List.of(deals)..sort((a, b) => heat(b).compareTo(heat(a)))).take(7).toList();
    return Container(
      color: const Color(0xFF121A2B),
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFF27D086), shape: BoxShape.circle)),
          const SizedBox(width: 8),
          const Text("TravelDeals ", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const Text("LIVE", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFFFF6B35))),
        ]),
        const Text("לוח דילים חי · מתעדכן בזמן אמת", style: TextStyle(fontSize: 11, color: Color(0xFF8A93A8))),
        const SizedBox(height: 8),
        // ticker
        SizedBox(
          height: 30,
          child: ListView(
            controller: _ticker,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            children: [...top, ...top].map((d) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Text("🔥 ${d.title}  ${d.now}${d.disc > 0 ? " (${d.disc}%-)" : ""}",
                  style: const TextStyle(fontSize: 13, color: Color(0xFFFFD34D), fontWeight: FontWeight.w600)),
            )).toList(),
          ),
        ),
        const SizedBox(height: 8),
        _controls(),
        const SizedBox(height: 6),
      ]),
    );
  }

  Widget _controls() {
    Widget seg(String id, String label) => GestureDetector(
      onTap: () => setState(() => sortMode = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        color: sortMode == id ? const Color(0xFFFF6B35) : Colors.transparent,
        child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: sortMode == id ? Colors.white : const Color(0xFF8A93A8))),
      ),
    );
    return SizedBox(
      height: 36,
      child: ListView(scrollDirection: Axis.horizontal, children: [
        Container(
          decoration: BoxDecoration(color: const Color(0xFF161D2E), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF23304A))),
          clipBehavior: Clip.antiAlias,
          child: Row(children: [seg("hot", "🔥 חם עכשיו"), seg("you", "✨ בשבילך"), seg("new", "🆕 חדש")]),
        ),
        const SizedBox(width: 8),
        ...cats.map((c) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: GestureDetector(
            onTap: () => setState(() => activeCat = c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: activeCat == c ? Colors.white : const Color(0xFF161D2E),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF23304A)),
              ),
              child: Text(c, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: activeCat == c ? const Color(0xFF0E1320) : const Color(0xFF8A93A8))),
            ),
          ),
        )),
      ]),
    );
  }

  Widget _body() {
    if (tab == 2) return _about();
    final list = tab == 1 ? deals.where((d) => favs.contains(d.id)).toList() : ordered;
    if (list.isEmpty) {
      return Center(child: Text(tab == 1 ? "אין שמורים עדיין — לחץ ☆ על דיל." : "אין דילים בקטגוריה זו.",
          style: const TextStyle(color: Color(0xFF8A93A8))));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 18),
      itemCount: list.length,
      itemBuilder: (_, i) => _card(list[i]),
    );
  }

  Widget _card(Deal d) {
    final s = score(d).round().clamp(0, 99);
    final fav = favs.contains(d.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: const Color(0xFF171F31), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF23304A))),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(width: 4, color: d.color),
          Padding(
            padding: const EdgeInsets.all(11),
            child: Text(d.emoji, style: const TextStyle(fontSize: 24)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d.title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Wrap(spacing: 8, runSpacing: 2, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Text("📍${d.dest}", style: const TextStyle(fontSize: 12, color: Color(0xFF8A93A8))),
                  Text(d.now, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  if (d.old.isNotEmpty) Text(d.old, style: const TextStyle(fontSize: 11, color: Color(0xFF8A93A8), decoration: TextDecoration.lineThrough)),
                  if (d.disc > 0) Text("${d.disc}%-", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF27D086))),
                  Text(ago(d.ageMin), style: const TextStyle(fontSize: 12, color: Color(0xFF8A93A8))),
                  Text("👀 ${d.viewers} צופים", style: const TextStyle(fontSize: 12, color: Color(0xFFFF3B3B), fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  GestureDetector(
                    onTap: () => learn(d), // בפרודקשן: פתח את d.link עם url_launcher
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFF9F1C)]), borderRadius: BorderRadius.circular(9)),
                      child: const Text("להזמנה ←", style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(() {
                      if (fav) { favs.remove(d.id); } else { favs.add(d.id); }
                      _save();
                    }),
                    child: Text(fav ? "⭐" : "☆", style: const TextStyle(fontSize: 16)),
                  ),
                ]),
              ]),
            ),
          ),
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("$s", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: gauge(s.toDouble()))),
              const Text("כדאיות", style: TextStyle(fontSize: 9, color: Color(0xFF8A93A8))),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _about() => const Padding(
    padding: EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("איך הפיד עובד", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      SizedBox(height: 10),
      Text("כל דיל מקבל ציון \"כדאיות\" חי: אחוז ההנחה + כמה הדיל טרי (מתקרר עם הזמן) + דחיפות (\"נגמר היום\") + כמה אנשים צופים בו עכשיו.",
          style: TextStyle(fontSize: 14, height: 1.6, color: Color(0xFFC8D0E0))),
      SizedBox(height: 10),
      Text("במצב \"בשבילך\" הפיד לומד מההקלקות שלך ומקדם נושאים שאתה אוהב. קליל, מהיר, בלי תמונות כבדות — כמו לוח הודעות חי.",
          style: TextStyle(fontSize: 14, height: 1.6, color: Color(0xFFC8D0E0))),
    ]),
  );
}
