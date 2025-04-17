import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

import '../../components/cards/big/big_card_image_slide.dart';
import '../../components/cards/big/restaurant_info_big_card.dart';
import '../../components/section_title.dart';
import '../../constants.dart';
import '../../demoData.dart';
import '../details/details_screen.dart';
import '../featured/most_popular.dart';
import 'components/medium_menu_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String locationStr = "loading...";
  int _selectedIndex = 0;

  _HomeScreenState() {
    requestLocation();
  }

  void requestLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    location.onLocationChanged.listen((LocationData currentLocation) async {
      double? lat = currentLocation.latitude;
      double? lon = currentLocation.longitude;
      if (lon == null || lat == null) return;

      String newLocation = await reverseSearchLocation(lat, lon);
      setState(() {
        locationStr = newLocation;
      });
    });
  }

  Future<String> reverseSearchLocation(double lat, double lon) async {
    http.Response res = await http.get(
      Uri.parse("https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=jsonv2&accept-language=th"),
      headers: {'Accept-Language': 'th'},
    );
    dynamic json = jsonDecode(res.body);
    String output = "${json['address']['road']}, ${json['address']['neighbourhood']}, ${json['address']['city']}";
    return output;
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Home - do nothing
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Search screen not implemented yet")),
        );
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Orders screen not implemented yet")),
        );
        break;
      case 3:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile screen not implemented yet")),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9999.0),
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image(
                image: FirebaseAuth.instance.currentUser?.photoURL != null
                ? NetworkImage(FirebaseAuth.instance.currentUser!.photoURL!)
                : AssetImage('assets/images/default_profile.png') as ImageProvider,
)

            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              "You Are At".toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: primaryColor),
            ),
            Text(locationStr, style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),


      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              //Banner
              const SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: BigCardImageSlide(images: demoBigImages),
              ),


              //Most Popular
              const SizedBox(height: defaultPadding * 2),
              SectionTitle(
                title: "Most Popular",
                press: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MostPopularScreen()),
                ),
              ),
              const SizedBox(height: defaultPadding),
              const MediumMenuList(),
              const SizedBox(height: 20),
              
              //Best Pick
              SectionTitle(
                title: "Best Pick",
                press: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MostPopularScreen()),
                ),
              ),
              const SizedBox(height: 16),
              const MediumMenuList(),
              const SizedBox(height: 20),


              //All Restaurants
              SectionTitle(title: "All Restaurants", press: () {}),
              const SizedBox(height: 16),
              Column(
                children: demoMediumCardData.map((restaurant) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                      defaultPadding,
                      0,
                      defaultPadding,
                      defaultPadding,
                    ),
                    child: RestaurantInfoBigCard(
                      images: [restaurant["image"]],
                      name: restaurant["name"],
                      rating: restaurant["rating"],
                      numOfRating: 200,
                      deliveryTime: restaurant["delivertTime"],
                      foodType: const ["Fried Chicken"],
                      press: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DetailsScreen()),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
     
     
     //Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
