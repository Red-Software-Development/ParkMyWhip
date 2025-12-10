import 'package:flutter/material.dart';

class ReportsTabWrapper extends StatefulWidget {
  const ReportsTabWrapper({super.key});

  @override
  State<ReportsTabWrapper> createState() => _ReportsTabWrapperState();
}

class _ReportsTabWrapperState extends State<ReportsTabWrapper>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          /// ----- TAB BAR -----
          TabBar(
            controller: _controller,
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "My Reports"),
              Tab(text: "All Reports"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _controller,
              children: const [
                Center(child: Text("My Reports Page")),
                Center(child: Text("All Reports Page")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
