// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import '../../constants/global_variables.dart';
import '../../constants/websocket.dart';
import '../Jelo/archive_jelo_screen.dart';
import '../Jelo/jelo_screen.dart';
import '../Kategorija/kategorija_screen.dart';
import '../Narudzba/narudzba_screen.dart';
import '../Report/report_screen.dart';
import 'account_admin_screen.dart';

class HomeAdminScreen extends StatefulWidget {
  static const String routeName = '/home-admin-screen';
  final dynamic userData;

  const HomeAdminScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<HomeAdminScreen> createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  int _page = 0;
  double bottomBarWidth = 42;
  double bottomBarBorderWidth = 6;

  late List<Widget> pages;

  void updatePage(int page) {
    setState(() {
      _page = page;
    });
  }

  WebSocketHandler webSocketHandler =
      WebSocketHandler('ws://localhost:7068/api');

  @override
  void initState() {
    super.initState();

    pages = [
      AccountScreen(userData: widget.userData),
      KategorijaScreen(
          userData: widget.userData, webSocketHandler: webSocketHandler),
      JeloScreen(userData: widget.userData, webSocketHandler: webSocketHandler),
      ArchiveJeloScreen(
          userData: widget.userData, webSocketHandler: webSocketHandler),
      NarudzbaScreen(userData: widget.userData),
      ReportScreen(userData: widget.userData),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_page],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        selectedItemColor: GlobalVariables.selectedNavBarColor,
        unselectedItemColor: GlobalVariables.unselectedNavBarColor,
        backgroundColor: GlobalVariables.backgroundColor,
        iconSize: 28,
        onTap: updatePage,
        items: [
          //ACCOUNT
          BottomNavigationBarItem(
            icon: Container(
              width: bottomBarWidth,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: _page == 0
                        ? GlobalVariables.selectedNavBarColor
                        : GlobalVariables.unselectedNavBarColor,
                    width: bottomBarBorderWidth,
                  ),
                ),
              ),
              child: const Icon(
                Icons.account_circle_outlined,
              ),
            ),
            label: '',
          ),

          //KATEGORIJA
          BottomNavigationBarItem(
            icon: Container(
              width: bottomBarWidth,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: _page == 1
                        ? GlobalVariables.selectedNavBarColor
                        : GlobalVariables.unselectedNavBarColor,
                    width: bottomBarBorderWidth,
                  ),
                ),
              ),
              child: const Icon(
                Icons.category_outlined,
              ),
            ),
            label: '',
          ),

          //JELO
          BottomNavigationBarItem(
            icon: Container(
              width: bottomBarWidth,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: _page == 2
                        ? GlobalVariables.selectedNavBarColor
                        : GlobalVariables.unselectedNavBarColor,
                    width: bottomBarBorderWidth,
                  ),
                ),
              ),
              child: const Icon(
                Icons.menu_book_outlined,
              ),
            ),
            label: '',
          ),

          //ARCHIVE JELO
          BottomNavigationBarItem(
            icon: Container(
              width: bottomBarWidth,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: _page == 3
                        ? GlobalVariables.selectedNavBarColor
                        : GlobalVariables.unselectedNavBarColor,
                    width: bottomBarBorderWidth,
                  ),
                ),
              ),
              child: const Icon(
                Icons.archive_outlined,
              ),
            ),
            label: '',
          ),

          //NARUDZBA
          BottomNavigationBarItem(
            icon: Container(
              width: bottomBarWidth,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: _page == 4
                        ? GlobalVariables.selectedNavBarColor
                        : GlobalVariables.unselectedNavBarColor,
                    width: bottomBarBorderWidth,
                  ),
                ),
              ),
              child: const Icon(
                Icons.list_alt_outlined,
              ),
            ),
            label: '',
          ),

          //IZVJESTAJ
          BottomNavigationBarItem(
            icon: Container(
              width: bottomBarWidth,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: _page == 5
                        ? GlobalVariables.selectedNavBarColor
                        : GlobalVariables.unselectedNavBarColor,
                    width: bottomBarBorderWidth,
                  ),
                ),
              ),
              child: const Icon(
                Icons.view_comfortable_sharp,
              ),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
