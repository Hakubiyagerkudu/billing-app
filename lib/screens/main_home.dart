import 'package:flutter/material.dart';
import 'package:kontor/screens/home/home_screen.dart';
import 'package:kontor/screens/invoice/invoice_screen.dart';
import 'package:kontor/screens/settings/settings_screen.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/utils/pref_data.dart';
import 'package:kontor/utils/resizer/fetch_pixels.dart';
import 'package:kontor/utils/widget_utils.dart';
import 'package:kontor/widgets/custom_text.dart';

class MainHome extends StatefulWidget {
  const MainHome({Key? key}) : super(key: key);

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int _currentIndex = 0;
  Map<String, dynamic> userData = {};

  final List<Widget> _screens = const [
    HomeScreen(),
    InvoiceScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    var fetchedData = await PrefData.getUserData();
    setState(() => userData = fetchedData);
  }

  int badgeCount = 3;

  void _onNotificationTap() {
    // Do something here
    print("Reset badge count");
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        extendBody: true,
        body: Column(
          children: [
            CustomHeaderBar(
              userCode: userData["username"] ?? "",
              userName:
                  '${userData["last_name"]?[0] ?? ''}.${userData["first_name"] ?? ''}',
              badgeCount: badgeCount,
              onNotificationTap: _onNotificationTap,
            ),
            Expanded(
              child: _screens[_currentIndex],
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16, left: 85, right: 85),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: primaryColor,
                  unselectedItemColor: Colors.grey.shade500,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13, // 👈 Set same size
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13, // 👈 Match this size
                  ),
                  items: [
                    BottomNavigationBarItem(
                      // icon: getAssetImage(
                      //   'home.png',
                      //   width: 21,
                      //   height: 21,
                      //   color: _currentIndex == 0
                      //       ? primaryColor
                      //       : Colors.grey.shade500,
                      // ),
                      icon: Icon(Icons.home_outlined),
                      label: 'Нүүр',
                    ),
                    BottomNavigationBarItem(
                      // icon: getAssetImage(
                      //   'credit-card.png',
                      //   width: 21,
                      //   height: 21,
                      //   color: _currentIndex == 1
                      //       ? primaryColor
                      //       : Colors.grey.shade500,
                      // ),
                      icon: Icon(Icons.payment_outlined),
                      label: 'Төлбөр',
                    ),
                    BottomNavigationBarItem(
                      // icon: getAssetImage(
                      //   'settings.png',
                      //   width: 21,
                      //   height: 21,
                      //   color: _currentIndex == 2
                      //       ? primaryColor
                      //       : Colors.grey.shade500,
                      // ),
                      icon: Icon(Icons.settings_outlined),
                      label: 'Тохиргоо',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomHeaderBar extends StatelessWidget {
  final int badgeCount;
  final String userCode, userName;
  final VoidCallback onNotificationTap;

  const CustomHeaderBar({
    Key? key,
    required this.userCode,
    required this.userName,
    required this.badgeCount,
    required this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FetchPixels(context);
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, statusBarHeight + 8, 16, 8), // add top padding for status bar
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Leading area with user info
          IntrinsicWidth(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  minWidth: 180, maxWidth: 240), // Cap at 180 < x < 240
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min, // ⬅️ Important: fit to content
                  children: [
                    getAssetImage('logo.png', width: 36, height: 36),
                    const SizedBox(width: 12),

                    // This part expands to fill available width, within constraints
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: userCode,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            maxLines: 1,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          CustomText(
                            text: userName,
                            fontSize: 13,
                            textOverflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          // Notification icon with badge
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topRight,
            children: [
              // GestureDetector(
              //   child: getAssetImage('notification.png', width: 25, height: 25),
              //   onTap: onNotificationTap,
              // ),
              IconButton(
                onPressed: onNotificationTap,
                icon: const Icon(
                  Icons.notifications_outlined,
                ),
              ),
              if (badgeCount > 0)
                Positioned(
                  right: 7,
                  top: 7,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 10,
                      minHeight: 10,
                    ),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
