import 'package:flutter/material.dart';
import '../models/food_model.dart';
import '../services/firebase_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Food> _foods = [];
  List<Food> _filteredFoods = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _hasConnection = true;
  StreamSubscription<ConnectivityResult>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => _onSearchChanged(_searchController.text),
    );
    // initial connectivity check and listen for changes
    Connectivity().checkConnectivity().then((result) {
      _hasConnection = result != ConnectivityResult.none;
      if (_hasConnection) _loadData();
      setState(() {});
    });

    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      final nowConnected = result != ConnectivityResult.none;
      if (nowConnected && !_hasConnection) {
        // regained connection -> retry loading
        _loadData();
      }
      _hasConnection = nowConnected;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _connectivitySub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _firebaseService.fetchFoods();
      setState(() {
        _foods = data;
        _filteredFoods = List.from(_foods);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filteredFoods = List.from(_foods));
      return;
    }

    setState(() {
      _filteredFoods = _foods
          .where((f) => f.name.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TH3 - Lê Tiến Minh - 2351060465'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_hasConnection) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.signal_wifi_off, size: 72, color: Colors.red),
              const SizedBox(height: 12),
              const Text(
                'Không có kết nối mạng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ứng dụng sẽ tự động thử lại khi có mạng.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final res = await Connectivity().checkConnectivity();
                  if (res != ConnectivityResult.none) {
                    _hasConnection = true;
                    setState(() {});
                    _loadData();
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Đã xảy ra lỗi:\n$_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Tìm món ăn theo tên',
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.78,
            ),
            itemCount: _filteredFoods.length,
            itemBuilder: (context, index) {
              final food = _filteredFoods[index];
              return Card(
                elevation: 3,
                child: InkWell(
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(food.name),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    food.imageUrl,
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    height: 140,
                                    fit: BoxFit.contain,
                                    errorBuilder: (c, e, s) =>
                                        const Icon(Icons.fastfood, size: 80),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Giá: ${food.price} đ',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(food.description),
                              const SizedBox(height: 12),
                              const Text(
                                'Nguyên liệu:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                food.ingredients.isNotEmpty
                                    ? food.ingredients
                                    : 'Không có thông tin nguyên liệu',
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Đóng'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top: image area with price badge
                      Expanded(
                        child: Stack(
                          children: [
                            // Full-size image (rounded top corners only)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8.0),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: Image.network(
                                  food.imageUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.fastfood, size: 48),
                                ),
                              ),
                            ),
                            // Price badge
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${food.price} đ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bottom: textual info
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              food.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              food.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
