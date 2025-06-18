import 'package:flutter/material.dart';
import 'package:contri/database/contri_database.dart';
import 'package:contri/screens/session_card.dart';
import 'package:contri/screens/session_dialog.dart';
import 'package:contri/screens/session_result.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> sessions = [];

  final List<Color> sessionColors = [
    const Color(0xFFF3E5F5), // Light Purple
    const Color(0xFFFFF3E0), // Light Orange
    const Color(0xFFE1F5FE), // Light Blue
    const Color(0xFFFCE4EC), // Light Pink
    const Color(0xFF89CFF0), // Baby Blue
    const Color(0xFFFFABAB), // Light Red
    const Color(0xFFB2F9FC), // Light Cyan
    const Color(0xFFFFD59A), // Light Peach
    const Color(0xFFFFE485), // Moccasin
    const Color(0xFF98FB98), // Pale Green
  ];

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    final fetchedSessions = await ContriDatabase.instance.getSessions();
    setState(() {
      sessions = fetchedSessions;
    });
  }

  void showSessionDialog({Map<String, dynamic>? session}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return SessionDialog(
          session: session,
          sessionColors: sessionColors,
          onSessionSaved: (sessionData) async {
            if (session == null) {
              await ContriDatabase.instance.addSession(sessionData);
            } else {
              await ContriDatabase.instance.updateSession(sessionData, session['id']);
            }
            fetchSessions();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Contri.',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showSessionDialog(),
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.black87),
      ),
      body: sessions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[700],
            ),
            const SizedBox(height: 20),
            Text(
              'Create a new bill to get started!',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return SessionCard(
              session: session,
              sessionColors: sessionColors,
              onDelete: () async {
                await ContriDatabase.instance.deleteSession(session['id']);
                fetchSessions();
              },
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Session Options'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          showSessionDialog(session: session);
                        },
                        child: const Text('Edit'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SessionResult(session: session),
                            ),
                          );
                        },
                        child: const Text('View Results'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}