import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());

  // Також запускаємо демонстрацію в консолі для перевірки завдань
  runAsyncDemo();
}


// 1. Отримання інформації про користувача
Future<String> getUser() async {
  print('⏳ Завантаження даних користувача...');
  await Future.delayed(const Duration(seconds: 2));
  // Можна симулювати помилку, ракоментувавши рядок нижче:
  // throw Exception('Помилка сервера: Не вдалося завантажити користувача');

  return 'Користувач: Іван (ID: 777, email: ivan@example.com)';
}

// 2. Отримання списку доступних товарів
Future<List<String>> getProducts() async {
  print('⏳ Завантаження каталогу товарів...');
  await Future.delayed(const Duration(seconds: 3));

  return ['Смартфон', 'Ноутбук', 'Навушники', 'Планшет'];
}

// 3. Отримання історії замовлень користувача
Future<List<String>> getOrders() async {
  print('⏳ Завантаження історії замовлень...');
  await Future.delayed(const Duration(seconds: 2));

  return ['Замовлення #101 (Доставлено)', 'Замовлення #102 (В обробці)'];
}

// ================= ГОЛОВНА АСИНХРОННА ФУНКЦІЯ ДЕМОНСТРАЦІЇ =================

Future<void> runAsyncDemo() async {
  print('=== СТАРТ АСИНХРОННИХ ОПЕРАЦІЙ ===');

  try {
    // 1. Послідовне виконання (sequential) за допомогою await
    print('\n--- Послідовне завантаження ---');
    Stopwatch stopwatch = Stopwatch()..start();

    String user = await getUser();
    print(user);

    List<String> products = await getProducts();
    print('Товари: $products');

    List<String> orders = await getOrders();
    print('Замовлення: $orders');

    stopwatch.stop();
    print('⏱️ Послідовне виконання зайняло: ${stopwatch.elapsedMilliseconds} мс');

    // 2. Паралельне/конкурентне виконання за допомогою Future.wait
    print('\n--- Паралельне завантаження (Future.wait) ---');
    stopwatch.reset();
    stopwatch.start();

    // Запускаємо всі три операції одночасно
    ResultsContainer results = await Future.wait([
      getUser(),
      getProducts(),
      getOrders(),
    ]).then((responses) => ResultsContainer(
      user: responses[0] as String,
      products: responses[1] as List<String>,
      orders: responses[2] as List<String>,
    ));

    print('Отримано паралельно:');
    print(results.user);
    print('Товари: ${results.products}');
    print('Замовлення: ${results.orders}');

    stopwatch.stop();
    print('⏱️ Паралельне виконання зайняло: ${stopwatch.elapsedMilliseconds} мс');

  } catch (e) {
    // Обробка помилок (Error Handling)
    print('❌ Сталася помилка під час асинхронного запиту: $e');
  } finally {
    print('\n=== ЗАВЕРШЕННЯ РОБОТИ ===');
  }
}

// Допоміжний клас для зручного розпакування результатів Future.wait
class ResultsContainer {
  final String user;
  final List<String> products;
  final List<String> orders;

  ResultsContainer({
    required this.user,
    required this.products,
    required this.orders,
  });
}

// ================= UI ЧАСТИНА (Щоб додаток не був просто пустим) =================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Async Demo App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const AsyncScreen(),
    );
  }
}

class AsyncScreen extends StatefulWidget {
  const AsyncScreen({super.key});

  @override
  State<AsyncScreen> createState() => _AsyncScreenState();
}

class _AsyncScreenState extends State<AsyncScreen> {
  String _statusMessage = 'Натисніть кнопку для завантаження даних';
  bool _isLoading = false;

  // Метод для завантаження даних усередині UI з використанням FutureBuilder / setState
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Завантаження даних магазину...';
    });

    try {
      // Конкурентне виконання через Future.wait
      final results = await Future.wait([
        getUser(),
        getProducts(),
        getOrders(),
      ]);

      setState(() {
        _statusMessage = 'Успішно завантажено!\n\n'
            '${results[0]}\n\n'
            'Товари: ${(results[1] as List).join(", ")}\n\n'
            'Замовлення: ${(results[2] as List).join(", ")}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Помилка: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Асинхронне програмування в Dart'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else
                const Icon(Icons.store, size: 64, color: Colors.teal),
              const SizedBox(height: 24),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _loadData,
                icon: const Icon(Icons.download),
                label: const Text('Завантажити дані інтернет-магазину'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}