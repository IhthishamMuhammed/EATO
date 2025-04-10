import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eato/Model/Food&Store.dart';
import 'package:eato/Provider/FoodProvider.dart';
import 'package:eato/Provider/StoreProvider.dart';
import 'package:eato/Provider/userProvider.dart';
import 'package:eato/Model/coustomUser.dart';
import 'package:eato/pages/provider/AddFoodPage.dart';
import 'package:eato/pages/provider/ProfilePage.dart';
import 'package:eato/pages/provider/OwnerProfil.dart';
import 'package:eato/pages/provider/OrderHomePage.dart';
import 'package:eato/pages/provider/RequestHome.dart';

class ProviderHomePage extends StatefulWidget {
  final CustomUser currentUser;

  const ProviderHomePage({Key? key, required this.currentUser}) : super(key: key);

  @override
  _ProviderHomePageState createState() => _ProviderHomePageState();
}

class _ProviderHomePageState extends State<ProviderHomePage> {
  String _selectedMealTime = 'Breakfast';
  int _currentIndex = 2;
  final List<String> _mealTimes = ['Breakfast', 'Lunch', 'Dinner'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStoreAndFoods();
  }

  Future<void> _loadStoreAndFoods() async {
    setState(() {
      _isLoading = true;
    });

    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    final foodProvider = Provider.of<FoodProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Set current user in provider
      if (userProvider.currentUser == null) {
        userProvider.currentUser = widget.currentUser;
      }

      await storeProvider.fetchUserStore(widget.currentUser);
      if (storeProvider.userStore != null) {
        await foodProvider.fetchFoods(storeProvider.userStore!.id);
      } else {
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StoreDetailsPage(currentUser: widget.currentUser),
            ),
          );
        });
      }
    } catch (e) {
      print("Error loading store and foods: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });

      switch (index) {
        case 0: // Orders
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderHomePage(currentUser: widget.currentUser),
            ),
          );
          break;
        case 1: // Requests
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequestHome(currentUser: widget.currentUser),
            ),
          );
          break;
        case 2: // Add food - current page
          // Already on this page, no navigation needed
          break;
        case 3: // Profile
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(currentUser: widget.currentUser),
            ),
          ).then((_) {
            setState(() {
              _currentIndex = 2;
            });
          });
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final foodProvider = Provider.of<FoodProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final storeId = storeProvider.userStore?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Food', style: TextStyle(fontSize: 16, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.purple))
          : SafeArea(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _mealTimes.map((mealTime) {
                        bool isActive = _selectedMealTime == mealTime;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMealTime = mealTime;
                            });
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                child: Text(
                                  mealTime,
                                  style: TextStyle(
                                    color: isActive ? Colors.purple : Colors.grey,
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                height: 2,
                                width: 90,
                                color: isActive ? Colors.purple : Colors.transparent,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddFoodPage(storeId: storeId),
                          ),
                        ).then((_) {
                          if (storeId.isNotEmpty) {
                            _loadStoreAndFoods(); // Refresh data when returning
                          }
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 20),
                            SizedBox(width: 6),
                            Text(
                              'Add New food',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: storeProvider.userStore == null
                        ? Center(
                            child: Text(
                              'Please set up your shop details first',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : _buildFoodList(foodProvider),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFoodList(FoodProvider foodProvider) {
    // Filter foods based on selected meal time
    final filteredFoods = foodProvider.foods
        .where((food) => food.time.toLowerCase() == _selectedMealTime.toLowerCase())
        .toList();

    if (filteredFoods.isEmpty) {
      return Center(
        child: Text(
          'No food items added yet for $_selectedMealTime',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredFoods.length,
      itemBuilder: (context, index) {
        final food = filteredFoods[index];
        final storeId = Provider.of<StoreProvider>(context).userStore!.id;
        return _buildFoodItem(
          food.name,
          'Rs.${food.price.toStringAsFixed(0)}',
          food.imageUrl,
          food.id,
          storeId,
        );
      },
    );
  }

  Widget _buildFoodItem(String name, String price, String imageUrl, String foodId, String storeId) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Icon(Icons.fastfood, size: 40, color: Colors.grey[600]),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.fastfood, size: 40, color: Colors.grey[600]),
                        ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    Text(price, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () async {
                try {
                  await Provider.of<FoodProvider>(context, listen: false).deleteFood(storeId, foodId);
                  _loadStoreAndFoods(); // Refresh after deletion
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Food item deleted')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: $e')),
                  );
                }
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline, color: Colors.black, size: 18),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 40,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Edit functionality coming soon')),
                );
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit_outlined, color: Colors.black, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
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
        BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Requests'),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add food'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}