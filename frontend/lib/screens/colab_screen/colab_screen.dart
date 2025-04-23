import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'node_communication_animation.dart'; // Import the new animation widget

class SocialAppWidget extends StatefulWidget {
  final String username;
  final double width;

  const SocialAppWidget({
    Key? key,
    required this.username,
    this.width = 350,
  }) : super(key: key);

  @override
  _SocialAppWidgetState createState() => _SocialAppWidgetState();
}

class _SocialAppWidgetState extends State<SocialAppWidget> {
  final TextEditingController _messageController = TextEditingController();
  List<dynamic> _tickets = [];
  List<dynamic> _responses = [];
  bool _isLoadingResponses = false;
  Timer? _timer;
  String? _selectedTicketId;
  bool _showAnimation = false; // Flag to control animation visibility
  Map<String, dynamic>? _agentFeedback; // Add this property to store agent feedback

  // Predefined list of good colors in ARGB format
  static const List<Color> _cardColors = [
    Color.fromARGB(109, 28, 227, 35), // Greenish
    Color.fromARGB(109, 35, 28, 227), // Bluish
    Color.fromARGB(109, 227, 28, 35), // Reddish
    Color.fromARGB(109, 227, 148, 28), // Orangish
    Color.fromARGB(109, 28, 227, 148), // Tealish
    Color.fromARGB(109, 148, 28, 227), // Purplish
  ];

  @override
  void initState() {
    super.initState();
    _fetchTickets();
    _fetchResponses();
    _startPeriodicFetch();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _startPeriodicFetch() {
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      _fetchResponses(_selectedTicketId);
    });
  }

  Future<void> _sendTicket() async {
    final String query = _messageController.text;

    // Show the animation immediately
    setState(() {
      _showAnimation = true;
    });

    try {
      final url = Uri.parse('https://agrosage.pagekite.me/api/tickets');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'PostmanRuntime/7.36.0',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'user_id': widget.username,
          'title': 'New Ticket',
          'description': query,
        }),
      );

      if (response.statusCode == 201) {
        _messageController.clear();
        _fetchTickets();
        // Fetch agent feedback and only hide animation when feedback is loaded
        await _fetchAgentFeedback(query);
      } else {
        print('Failed to send ticket: ${response.body}');
        // Hide animation on error
        setState(() {
          _showAnimation = false;
        });
      }
    } catch (e) {
      print('Error sending ticket: $e');
      // Hide animation on error
      setState(() {
        _showAnimation = false;
      });
    }
  }

  Future<void> _fetchAgentFeedback(String query) async {
    try {
      final url = Uri.parse('https://agrosage.pagekite.me/feedback');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'PostmanRuntime/7.36.0',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          "query": query
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Extract the 'data' field, which contains the actual feedback
        final Map<String, dynamic>? feedbackData = responseData['data'];
        if (feedbackData != null && responseData['success'] == true) {
          setState(() {
            _agentFeedback = feedbackData; // Store feedbackData (contains query, feedback, timestamp)
            _showAnimation = false; // Hide animation after feedback is loaded
          });
          print('Agent feedback received: $feedbackData');
        } else {
          print('Feedback data is null or success is false: ${response.body}');
          setState(() {
            _agentFeedback = null; // Reset feedback if invalid
            _showAnimation = false; // Hide animation if invalid feedback
          });
        }
      } else {
        print('Failed to fetch agent feedback: ${response.body}');
        setState(() {
          _agentFeedback = null; // Reset feedback on failure
          _showAnimation = false; // Hide animation on failure
        });
      }
    } catch (e) {
      print('Error fetching agent feedback: $e');
      setState(() {
        _agentFeedback = null; // Reset feedback on error
        _showAnimation = false; // Hide animation on error
      });
    }
  }

  Future<void> _fetchTickets() async {
    final url = Uri.parse('https://agrosage.pagekite.me/api/tickets');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'PostmanRuntime/7.36.0',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _tickets = jsonDecode(response.body)['tickets'] ?? [];
      });
    } else {
      print('Failed to fetch tickets: ${response.body}');
    }
  }

  Future<void> _fetchResponses([String? ticketId]) async {
    // Only show loading indicator on initial load or ticket change
    if (_responses.isEmpty || ticketId != _selectedTicketId) {
      setState(() {
        _isLoadingResponses = true;
      });
    }

    final url = Uri.parse('https://agrosage.pagekite.me/api/responses');
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'PostmanRuntime/7.36.0',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final allResponses = jsonData['responses'] ?? [];
      final newResponses = ticketId != null
          ? allResponses
              .where((r) => r['ticket_id'].toString() == ticketId)
              .toList()
          : allResponses;

      // Check if the responses changed before updating state
      final responsesChanged = _areResponsesDifferent(newResponses, _responses);
      final ticketChanged = ticketId != _selectedTicketId;

      // Only update state if there are changes or ticket selection changed
      if (responsesChanged || ticketChanged) {
        setState(() {
          _responses = newResponses;
          _isLoadingResponses = false;
          _selectedTicketId = ticketId;
        });
        print('Responses updated: $_responses');
      } else if (_isLoadingResponses) {
        // Just turn off loading if it was on but no changes occurred
        setState(() {
          _isLoadingResponses = false;
        });
      }
    } else {
      if (_isLoadingResponses) {
        setState(() {
          _responses = [];
          _isLoadingResponses = false;
        });
      }
      print('Failed to fetch responses: ${response.body}');
    }
  }

  // Helper method to check if responses are different
  bool _areResponsesDifferent(List<dynamic> newResponses, List<dynamic> oldResponses) {
    if (newResponses.length != oldResponses.length) {
      return true;
    }

    for (int i = 0; i < newResponses.length; i++) {
      final newRes = newResponses[i];
      final oldRes = oldResponses[i];

      // Compare essential fields for equality
      if (newRes['id'] != oldRes['id'] ||
          newRes['description'] != oldRes['description'] ||
          newRes['title'] != oldRes['title']) {
        return true;
      }
    }

    return false;
  }

  // Get a color from the predefined list, cycling through based on index
  Color _getCardColor(int index) {
    return _cardColors[index % _cardColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return _showAnimation
        ? NodeCommunicationAnimation()
        : Container(
            width: widget.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(109, 28, 227, 35).withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  _buildInputField(),
                  _buildTimeOptions(),
                  _buildTicketsList(),
                  _buildGreenLine(),
                  _buildResponsesSection(),
                ],
              ),
            ),
          );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Have a Good day,',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 5, 170, 145),
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(
                'assets/wave.gif',
                width: 26,
                height: 26,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Fuel your days with the boundless enthusiasm of a\nlifelong explorer.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromARGB(44, 24, 220, 47),
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(
                  color: Color.fromARGB(255, 3, 61, 5),
                ),
                cursorColor: Colors.green,
                decoration: const InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Color.fromARGB(255, 15, 32, 1)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 46,
            width: 46,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendTicket,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimeOption(Icons.access_time, 'Now'),
          _buildTimeOption(Icons.calendar_today, 'Tomorrow'),
          _buildTimeOption(Icons.calendar_view_week, 'Next week'),
          _buildTimeOption(Icons.calendar_month, 'Custom'),
        ],
      ),
    );
  }

  Widget _buildTimeOption(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color.fromARGB(134, 177, 240, 94),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketsList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tickets:',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          if (_tickets.isEmpty)
            const Text('No tickets available.')
          else
            ..._tickets.map((ticket) => Card(
                  child: ListTile(
                    title: Text(ticket['title'] ?? 'No Title'),
                    subtitle: Text(ticket['description'] ?? 'No Description'),
                    onTap: () => _fetchResponses(ticket['id'].toString()),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildGreenLine() {
    return Container(
      height: 4,
      color: Colors.green,
      margin: const EdgeInsets.symmetric(vertical: 0),
    );
  }

  Widget _buildResponsesSection() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Responses:',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 154, 66, 216)),
          ),
          const SizedBox(height: 8),
          if (_isLoadingResponses)
            const Center(child: CircularProgressIndicator())
          else if (_responses.isEmpty && _agentFeedback == null)
            const Text('No responses available.')
          else
            SizedBox(
              height: 270,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Make all children stretch full width
                  children: [
                    // Agent Feedback Card
                    if (_agentFeedback != null &&
                        _agentFeedback!['feedback'] is List<dynamic>)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: const Color.fromARGB(255, 2, 47, 181),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Agent Feedback ✨',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Query: ${_agentFeedback!['query'] ?? 'No query'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              ...(_agentFeedback!['feedback'] as List<dynamic>)
                                  .map((point) => Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          point.toString(),
                                          style: const TextStyle(
                                              color: Colors.white70),
                                        ),
                                      ))
                                  .toList(),
                            ],
                          ),
                        ),
                      ),

                    // Regular responses
                    ..._responses.asMap().entries.map((entry) {
                      final index = entry.key;
                      final response = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: _getCardColor(index),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(
                            response['title'] ?? 'No Title',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            response['description'] ?? 'No Description',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
