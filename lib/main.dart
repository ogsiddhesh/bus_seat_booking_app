// main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(const BusBookingApp());
}

class BusBookingApp extends StatelessWidget {
  const BusBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Booking App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// Splash screen with animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Start animation and navigate after completion
    _controller.forward().then((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BusSeatSelectionScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: const Text(
            'Sidd APP',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}

// Bus seat selection screen
class BusSeatSelectionScreen extends StatefulWidget {
  const BusSeatSelectionScreen({super.key});

  @override
  State<BusSeatSelectionScreen> createState() => _BusSeatSelectionScreenState();
}

class _BusSeatSelectionScreenState extends State<BusSeatSelectionScreen> {
  // Set to store selected and unavailable seats
  final Set<int> selectedSeats = {};
  final Set<int> unavailableSeats = {};
  static const int totalSeats = 28;

  @override
  void initState() {
    super.initState();
    // Initialize unavailable seats from previous selections (simulated persistence)
    unavailableSeats.addAll(SeatPersistenceManager.getUnavailableSeats());
  }

  // Handle seat selection
  void _handleSeatSelection(int seatNumber) {
    if (unavailableSeats.contains(seatNumber)) {
      _showMessage('Seat $seatNumber is unavailable');
      return;
    }

    if (selectedSeats.contains(seatNumber)) {
      setState(() {
        selectedSeats.remove(seatNumber);
      });
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Seat'),
        content: Text('Would you like to select seat $seatNumber?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                selectedSeats.add(seatNumber);
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Bus Seats'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: totalSeats,
              itemBuilder: (context, index) {
                final seatNumber = index + 1;
                Color seatColor = Colors.green;
                
                if (unavailableSeats.contains(seatNumber)) {
                  seatColor = Colors.red;
                } else if (selectedSeats.contains(seatNumber)) {
                  seatColor = Colors.blue;
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: seatColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () => _handleSeatSelection(seatNumber),
                    child: Center(
                      child: Text(
                        '$seatNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: selectedSeats.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ConfirmationScreen(
                            selectedSeats: selectedSeats.toList()..sort(),
                          ),
                        ),
                      );
                    },
              child: const Text('Proceed to Confirmation'),
            ),
          ),
        ],
      ),
    );
  }
}

// Confirmation screen
class ConfirmationScreen extends StatelessWidget {
  final List<int> selectedSeats;

  const ConfirmationScreen({
    super.key,
    required this.selectedSeats,
  });

  void _handleConfirmation(BuildContext context) {
    // Store selected seats as unavailable for next app launch
    SeatPersistenceManager.addUnavailableSeats(selectedSeats);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Confirmed'),
        content: Text(
          'Your seats (${selectedSeats.join(", ")}) have been booked successfully!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context)
                ..pop() // Close dialog
                ..pop() // Return to seat selection
                ..pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const BusSeatSelectionScreen(),
                  ),
                );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selected Seats:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: selectedSeats.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.event_seat),
                      title: Text('Seat ${selectedSeats[index]}'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleConfirmation(context),
                child: const Text('Confirm Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simulated persistence manager
class SeatPersistenceManager {
  static final Set<int> _unavailableSeats = {};

  static Set<int> getUnavailableSeats() {
    return Set.from(_unavailableSeats);
  }

  static void addUnavailableSeats(List<int> seats) {
    _unavailableSeats.addAll(seats);
  }
}