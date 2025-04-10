import 'package:flutter/material.dart';
import 'package:eato/Model/coustomUser.dart';
import 'package:eato/pages/provider/OrderHomePage.dart';
import 'package:eato/pages/provider/ProviderHomePage.dart';
import 'package:eato/pages/provider/ProfilePage.dart';
import 'package:eato/pages/provider/AddFoodPage.dart';
import 'package:provider/provider.dart';
import 'package:eato/Provider/StoreProvider.dart';
import 'package:eato/Provider/userProvider.dart';

// Model classes for requests
class OrderRequest {
  final String id;
  final String customerName;
  final String foodName;
  final double price;
  final String imageUrl;
  final DateTime orderTime;
  final bool isCancellationRequest;
  
  OrderRequest({
    required this.id,
    required this.customerName,
    required this.foodName,
    required this.price,
    required this.imageUrl,
    required this.orderTime,
    this.isCancellationRequest = false,
  });
}

class RequestProvider with ChangeNotifier {
  List<OrderRequest> _newRequests = [];
  List<OrderRequest> _cancellationRequests = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<OrderRequest> get newRequests => _newRequests;
  List<OrderRequest> get cancellationRequests => _cancellationRequests;

  // Mock data loading
  Future<void> fetchRequests() async {
    _isLoading = true;
    notifyListeners();

    // Simulating API call
    await Future.delayed(Duration(seconds: 1));

    // Mock data
    _newRequests = [
      OrderRequest(
        id: '1',
        customerName: 'Mihail Ayepetov',
        foodName: 'Rice and curry - Egg',
        price: 250,
        imageUrl: 'https://example.com/food1.jpg',
        orderTime: DateTime.now().subtract(Duration(minutes: 15)),
      ),
      OrderRequest(
        id: '2',
        customerName: 'Mohammed M.I.',
        foodName: 'Rice and curry - Chicken',
        price: 300,
        imageUrl: 'https://example.com/food2.jpg',
        orderTime: DateTime.now().subtract(Duration(minutes: 10)),
      ),
    ];

    _cancellationRequests = [
      OrderRequest(
        id: '3',
        customerName: 'Mihail Ajamied',
        foodName: 'Rice and curry - Egg',
        price: 250,
        imageUrl: 'https://example.com/food3.jpg',
        orderTime: DateTime.now().subtract(Duration(minutes: 30)),
        isCancellationRequest: true,
      ),
      OrderRequest(
        id: '4',
        customerName: 'Mohammed M.I.',
        foodName: 'Rice and curry - Chicken',
        price: 300,
        imageUrl: 'https://example.com/food4.jpg',
        orderTime: DateTime.now().subtract(Duration(minutes: 25)),
        isCancellationRequest: true,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  // Accept a new order request
  Future<void> acceptRequest(String requestId) async {
    _isLoading = true;
    notifyListeners();

    // Simulating API call
    await Future.delayed(Duration(milliseconds: 500));

    // Remove the request from the list
    _newRequests.removeWhere((request) => request.id == requestId);

    _isLoading = false;
    notifyListeners();
  }

  // Decline a new order request
  Future<void> declineRequest(String requestId) async {
    _isLoading = true;
    notifyListeners();

    // Simulating API call
    await Future.delayed(Duration(milliseconds: 500));

    // Remove the request from the list
    _newRequests.removeWhere((request) => request.id == requestId);

    _isLoading = false;
    notifyListeners();
  }

  // Accept a cancellation request
  Future<void> acceptCancellation(String requestId) async {
    _isLoading = true;
    notifyListeners();

    // Simulating API call
    await Future.delayed(Duration(milliseconds: 500));

    // Remove the request from the list
    _cancellationRequests.removeWhere((request) => request.id == requestId);

    _isLoading = false;
    notifyListeners();
  }

  // Decline a cancellation request
  Future<void> declineCancellation(String requestId) async {
    _isLoading = true;
    notifyListeners();

    // Simulating API call
    await Future.delayed(Duration(milliseconds: 500));

    // Remove the request from the list
    _cancellationRequests.removeWhere((request) => request.id == requestId);

    _isLoading = false;
    notifyListeners();
  }
}

class RequestHome extends StatefulWidget {
  final CustomUser currentUser;

  const RequestHome({Key? key, required this.currentUser}) : super(key: key);

  @override
  _RequestHomeState createState() => _RequestHomeState();
}

class _RequestHomeState extends State<RequestHome> {
  int _currentIndex = 1; // Default to Requests tab
  final RequestProvider _requestProvider = RequestProvider();

  @override
  void initState() {
    super.initState();
    _requestProvider.fetchRequests();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Orders
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderHomePage(currentUser: widget.currentUser),
          ),
        );
        break;
      case 1: // Requests - current page
        // Already on this page
        break;
      case 2: // Add Food
        final storeProvider = Provider.of<StoreProvider>(context, listen: false);
        if (storeProvider.userStore != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFoodPage(
                storeId: storeProvider.userStore!.id,
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderHomePage(currentUser: widget.currentUser),
            ),
          );
        }
        break;
      case 3: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(currentUser: widget.currentUser),
          ),
        ).then((_) {
          setState(() {
            _currentIndex = 1; // Reset to Requests tab when returning
          });
        });
        break;
    }
  }

  void _viewOrderDetails(OrderRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildOrderDetails(request),
    );
  }

  Widget _buildOrderDetails(OrderRequest request) {
    return Container(
      padding: EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                request.isCancellationRequest ? 'Cancel order Request' : 'Order Request',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Customer info
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 40, color: Colors.grey[700]),
                ),
                SizedBox(height: 8),
                Text(
                  request.customerName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          // Food details
          Text('Food Name', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(request.foodName),
              Text('Rs.${request.price.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 16),
          
          // Location
          Text('LOCATION', style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 4),
          Text('NEAR FACULTY GATE'),
          SizedBox(height: 16),
          
          // Mobile number
          Text('Mobile number', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 4),
          Text('077*******'),
          
          Spacer(),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (request.isCancellationRequest) {
                      _requestProvider.declineCancellation(request.id);
                    } else {
                      _requestProvider.declineRequest(request.id);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Request declined')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Decline'),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (request.isCancellationRequest) {
                      _requestProvider.acceptCancellation(request.id);
                    } else {
                      _requestProvider.acceptRequest(request.id);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Request accepted')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _requestProvider,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Requests', style: TextStyle(color: Colors.black, fontSize: 20)),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Consumer<RequestProvider>(
          builder: (context, requestProvider, _) {
            if (requestProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: Colors.purple),
              );
            }
            
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // New Orders Section
                    Text(
                      'New Orders (${requestProvider.newRequests.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    // New Order Requests
                    requestProvider.newRequests.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'No new order requests',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : Column(
                            children: requestProvider.newRequests.map((request) {
                              return _buildRequestCard(request, requestProvider);
                            }).toList(),
                          ),
                    
                    SizedBox(height: 24),
                    
                    // Cancel Order Requests Section
                    Text(
                      'Cancel Order Requests (${requestProvider.cancellationRequests.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),
                    
                    // Cancel Order Requests
                    requestProvider.cancellationRequests.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'No cancellation requests',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : Column(
                            children: requestProvider.cancellationRequests.map((request) {
                              return _buildRequestCard(request, requestProvider);
                            }).toList(),
                          ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildRequestCard(OrderRequest request, RequestProvider provider) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: request.isCancellationRequest ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: Icon(Icons.restaurant, color: Colors.grey[600]),
                  ),
                ),
                SizedBox(width: 12),
                
                // Order details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.customerName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        request.foodName,
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Rs.${request.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Time
                Text(
                  '${_formatTime(request.orderTime)}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _viewOrderDetails(request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple,
                      side: BorderSide(color: Colors.purple),
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text('View order'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (request.isCancellationRequest) {
                        provider.acceptCancellation(request.id);
                      } else {
                        provider.acceptRequest(request.id);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Request accepted')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text('Accept'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inHours > 0) {
      return '${difference.inHours}:${(difference.inMinutes % 60).toString().padLeft(2, '0')} pm';
    } else {
      return '${difference.inMinutes}:${(difference.inSeconds % 60).toString().padLeft(2, '0')} pm';
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          label: 'Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: 'Add food',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}