import 'package:flutter/material.dart';
import 'package:eato/Model/coustomUser.dart';
import 'package:eato/pages/provider/RequestHome.dart';
import 'package:eato/pages/provider/ProfilePage.dart';
import 'package:eato/pages/provider/AddFoodPage.dart';
import 'package:eato/pages/provider/ProviderHomePage.dart';
import 'package:provider/provider.dart';
import 'package:eato/Provider/StoreProvider.dart';
import 'package:eato/Provider/userProvider.dart';

// Order model
class Order {
  final String id;
  final String customerName;
  final String foodName;
  final int quantity;
  final double price;
  final String imageUrl;
  final DateTime orderTime;
  final String deliveryLocation;
  final String contactNumber;
  final OrderStatus status;
  final bool isPastOrder;

  Order({
    required this.id,
    required this.customerName,
    required this.foodName,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.orderTime,
    required this.deliveryLocation,
    required this.contactNumber,
    required this.status,
    this.isPastOrder = false,
  });
}

enum OrderStatus { pending, ready, onTheWay, delivered }

// OrderProvider
class OrderProvider with ChangeNotifier {
  List<Order> _presentOrders = [];
  List<Order> _pastOrders = [];
  bool _isLoading = false;
  bool _isPresentTab = true; // Flag to track which tab is selected

  bool get isLoading => _isLoading;
  List<Order> get presentOrders => _presentOrders;
  List<Order> get pastOrders => _pastOrders;
  bool get isPresentTab => _isPresentTab;

  void toggleTab(bool isPresentTab) {
    _isPresentTab = isPresentTab;
    notifyListeners();
  }

  // Fetch orders from backend (mocked for now)
  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    // Simulating API call
    await Future.delayed(Duration(seconds: 1));

    // Mock present orders
    _presentOrders = [
      Order(
        id: '01',
        customerName: 'Mihail Ahamed',
        foodName: 'Rice and curry - Chicken',
        quantity: 5,
        price: 250,
        imageUrl: 'https://example.com/food1.jpg',
        orderTime: DateTime.now().subtract(Duration(minutes: 30)),
        deliveryLocation: 'Faculty Gate',
        contactNumber: '077*******',
        status: OrderStatus.pending,
      ),
      Order(
        id: '02',
        customerName: 'Ishmika',
        foodName: 'Rice and curry - Chicken',
        quantity: 5,
        price: 250,
        imageUrl: 'https://example.com/food2.jpg',
        orderTime: DateTime.now().subtract(Duration(hours: 1, minutes: 15)),
        deliveryLocation: 'Banagowra Mawatha',
        contactNumber: '076*******',
        status: OrderStatus.ready,
      ),
      Order(
        id: '03',
        customerName: 'Rishmika',
        foodName: 'Rice and curry - Chicken',
        quantity: 5,
        price: 250,
        imageUrl: 'https://example.com/food3.jpg',
        orderTime: DateTime.now().subtract(Duration(hours: 1, minutes: 25)),
        deliveryLocation: 'Faculty',
        contactNumber: '071*******',
        status: OrderStatus.onTheWay,
      ),
      Order(
        id: '04',
        customerName: 'Vitana',
        foodName: 'Rice and curry - Chicken',
        quantity: 5,
        price: 250,
        imageUrl: 'https://example.com/food4.jpg',
        orderTime: DateTime.now().subtract(Duration(hours: 2)),
        deliveryLocation: 'Main Canteen',
        contactNumber: '070*******',
        status: OrderStatus.delivered,
      ),
    ];

    // Mock past orders
    _pastOrders = [
      Order(
        id: '05',
        customerName: 'Mihail Ahamed',
        foodName: 'Rice and curry - Chicken',
        quantity: 5,
        price: 250,
        imageUrl: 'https://example.com/food5.jpg',
        orderTime: DateTime.now().subtract(Duration(days: 1)),
        deliveryLocation: 'Faculty Gate',
        contactNumber: '077*******',
        status: OrderStatus.delivered,
        isPastOrder: true,
      ),
      Order(
        id: '06',
        customerName: 'Mihail Ahamed',
        foodName: 'Rice and curry - Egg',
        quantity: 12,
        price: 200,
        imageUrl: 'https://example.com/food6.jpg',
        orderTime: DateTime.now().subtract(Duration(days: 1, hours: 2)),
        deliveryLocation: 'Faculty Gate',
        contactNumber: '077*******',
        status: OrderStatus.delivered,
        isPastOrder: true,
      ),
      Order(
        id: '07',
        customerName: 'Mihail Ahamed',
        foodName: 'Rice and curry - Fish',
        quantity: 3,
        price: 300,
        imageUrl: 'https://example.com/food7.jpg',
        orderTime: DateTime.now().subtract(Duration(days: 2)),
        deliveryLocation: 'Faculty Gate',
        contactNumber: '077*******',
        status: OrderStatus.delivered,
        isPastOrder: true,
      ),
      Order(
        id: '08',
        customerName: 'Mihail Ahamed',
        foodName: 'Rice and curry - Chicken',
        quantity: 5,
        price: 250,
        imageUrl: 'https://example.com/food8.jpg',
        orderTime: DateTime.now().subtract(Duration(days: 2, hours: 3)),
        deliveryLocation: 'Faculty Gate',
        contactNumber: '077*******',
        status: OrderStatus.delivered,
        isPastOrder: true,
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    _isLoading = true;
    notifyListeners();

    // Simulating API call
    await Future.delayed(Duration(milliseconds: 500));

    // Find and update the order
    final orderIndex = _presentOrders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final updatedOrder = Order(
        id: _presentOrders[orderIndex].id,
        customerName: _presentOrders[orderIndex].customerName,
        foodName: _presentOrders[orderIndex].foodName,
        quantity: _presentOrders[orderIndex].quantity,
        price: _presentOrders[orderIndex].price,
        imageUrl: _presentOrders[orderIndex].imageUrl,
        orderTime: _presentOrders[orderIndex].orderTime,
        deliveryLocation: _presentOrders[orderIndex].deliveryLocation,
        contactNumber: _presentOrders[orderIndex].contactNumber,
        status: newStatus,
      );

      // If the order is delivered, move it to past orders
      if (newStatus == OrderStatus.delivered) {
        _presentOrders.removeAt(orderIndex);
        _pastOrders.insert(0, Order(
          id: updatedOrder.id,
          customerName: updatedOrder.customerName,
          foodName: updatedOrder.foodName,
          quantity: updatedOrder.quantity,
          price: updatedOrder.price,
          imageUrl: updatedOrder.imageUrl,
          orderTime: updatedOrder.orderTime,
          deliveryLocation: updatedOrder.deliveryLocation,
          contactNumber: updatedOrder.contactNumber,
          status: updatedOrder.status,
          isPastOrder: true,
        ));
      } else {
        _presentOrders[orderIndex] = updatedOrder;
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}

class OrderHomePage extends StatefulWidget {
  final CustomUser currentUser;

  const OrderHomePage({Key? key, required this.currentUser}) : super(key: key);

  @override
  _OrderHomePageState createState() => _OrderHomePageState();
}

class _OrderHomePageState extends State<OrderHomePage> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;  // Default to Orders tab
  final OrderProvider _orderProvider = OrderProvider();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _orderProvider.fetchOrders();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      _orderProvider.toggleTab(_tabController.index == 0);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0: // Orders (current page)
        // Already on the page
        break;
      case 1: // Requests
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RequestHome(currentUser: widget.currentUser),
          ),
        );
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
            _currentIndex = 0; // Reset to Orders tab when returning
          });
        });
        break;
    }
  }

  void _viewOrderDetails(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailsPage(
          order: order,
          orderProvider: _orderProvider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _orderProvider,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Orders', style: TextStyle(color: Colors.black, fontSize: 20)),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.purple,
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'PRESENT ORDERS'),
              Tab(text: 'PAST ORDERS'),
            ],
          ),
        ),
        body: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            if (orderProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: Colors.purple),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // Present Orders Tab
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Present Orders Table Headers
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Food Name',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Delivery Location',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                'Ordered time',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1),
                      
                      // Present Orders List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: orderProvider.presentOrders.length,
                        separatorBuilder: (context, index) => Divider(height: 1),
                        itemBuilder: (context, index) {
                          final order = orderProvider.presentOrders[index];
                          return _buildOrderRow(order);
                        },
                      ),
                    ],
                  ),
                ),
                
                // Past Orders Tab
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Today Section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            SizedBox(width: 60, child: Text('Date')),
                            Expanded(child: Text('Name')),
                            SizedBox(width: 80, child: Text('Quantity')),
                          ],
                        ),
                      ),
                      Divider(height: 1),
                      
                      // Today's Orders
                      Container(
                        color: Colors.purple.withOpacity(0.15),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        alignment: Alignment.centerLeft,
                        child: Text('Today', style: TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: orderProvider.pastOrders.where((o) => 
                          DateTime.now().difference(o.orderTime).inDays < 1).length,
                        itemBuilder: (context, index) {
                          final todayOrders = orderProvider.pastOrders.where((o) => 
                            DateTime.now().difference(o.orderTime).inDays < 1).toList();
                          return _buildPastOrderRow(todayOrders[index]);
                        },
                      ),
                      
                      // Yesterday Section
                      Container(
                        color: Colors.purple.withOpacity(0.15),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        alignment: Alignment.centerLeft,
                        child: Text('Yesterday', style: TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: orderProvider.pastOrders.where((o) => 
                          DateTime.now().difference(o.orderTime).inDays == 1).length,
                        itemBuilder: (context, index) {
                          final yesterdayOrders = orderProvider.pastOrders.where((o) => 
                            DateTime.now().difference(o.orderTime).inDays == 1).toList();
                          return _buildPastOrderRow(yesterdayOrders[index]);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildOrderRow(Order order) {
    return InkWell(
      onTap: () => _viewOrderDetails(order),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Food Image and Name
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(Icons.restaurant, color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.foodName,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "${order.quantity}",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Delivery Location
            Expanded(
              flex: 2,
              child: Text(
                order.deliveryLocation,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            
            // Order Time
            Expanded(
              flex: 1,
              child: Text(
                '${_formatTime(order.orderTime)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastOrderRow(Order order) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              _formatDate(order.orderTime),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.restaurant, color: Colors.grey[600], size: 20),
                ),
                SizedBox(width: 12),
                Text(order.foodName),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              '${order.quantity}',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}';
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]}';
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

// Order Details Page
class OrderDetailsPage extends StatefulWidget {
  final Order order;
  final OrderProvider orderProvider;

  const OrderDetailsPage({
    Key? key, 
    required this.order,
    required this.orderProvider,
  }) : super(key: key);

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.order.id}', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Number
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: Icon(Icons.restaurant, size: 40, color: Colors.grey[600]),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order No',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          SizedBox(height: 4),
                          Text(
                            widget.order.id,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              // Food details
              Text('Food name', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 4),
              Text(widget.order.foodName),
              SizedBox(height: 16),
              
              // Price
              Text('Food price', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 4),
              Text('Rs.${widget.order.price.toStringAsFixed(0)}'),
              SizedBox(height: 16),
              
              // Delivery place
              Text('Delivery place', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 4),
              Text(widget.order.deliveryLocation),
              SizedBox(height: 16),
              
              // Customer Name
              Text('Customer Name', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 4),
              Text(widget.order.customerName),
              SizedBox(height: 16),
              
              // Customer number
              Text('Customer number', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 4),
              Text(widget.order.contactNumber),
              SizedBox(height: 32),
              
              // Order Status Buttons
              if (!widget.order.isPastOrder) ...[
                Text(
                  'Order Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                
                // Ready button
                _buildStatusButton(
                  title: 'Order is ready',
                  icon: Icons.check_circle_outline,
                  color: Color(0xFF808080),
                  isActive: widget.order.status == OrderStatus.ready,
                  onTap: () {
                    widget.orderProvider.updateOrderStatus(widget.order.id, OrderStatus.ready);
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 12),
                
                // On the way button
                _buildStatusButton(
                  title: 'Order is on the way',
                  icon: Icons.directions_bike_outlined,
                  color: Color(0xFF808080),
                  isActive: widget.order.status == OrderStatus.onTheWay,
                  onTap: () {
                    widget.orderProvider.updateOrderStatus(widget.order.id, OrderStatus.onTheWay);
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 12),
                
                // Delivered button
                _buildStatusButton(
                  title: 'Order delivered',
                  icon: Icons.thumb_up_outlined,
                  color: Color(0xFF808080),
                  isActive: widget.order.status == OrderStatus.delivered,
                  onTap: () {
                    widget.orderProvider.updateOrderStatus(widget.order.id, OrderStatus.delivered);
                    Navigator.pop(context);
                  },
                ),
              ] else ...[
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Delivered',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusButton({
    required String title,
    required IconData icon,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isActive ? null : onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? Colors.grey[700] : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey[700],
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}