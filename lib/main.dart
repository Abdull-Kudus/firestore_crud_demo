import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/todo_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Read the saved theme before the first frame so the app opens in it
  final isDarkMode = await ThemeService.loadIsDarkMode();
  runApp(TodoApp(isDarkMode: isDarkMode));
}

class TodoApp extends StatelessWidget {
  final bool isDarkMode;

  const TodoApp({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<ThemeService>(
          create: (_) => ThemeService(isDarkMode),
        ),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Todo App with Auth',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: themeService.themeMode,
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          // Keyed by uid so the todo list rebuilds with the right user's data
          return TodoList(key: ValueKey(user.uid));
        }
        return const AuthScreen();
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showLoginScreen = true;

  void toggleScreen() {
    setState(() {
      showLoginScreen = !showLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return showLoginScreen
        ? LoginScreen(showRegisterScreen: toggleScreen)
        : RegisterScreen(showLoginScreen: toggleScreen);
  }
}
