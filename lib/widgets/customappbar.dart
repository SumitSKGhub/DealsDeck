import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: TextField(
              decoration:
              InputDecoration(
                  hintText: "Search here",
                  prefixIcon: Icon(Icons.deck,color: Colors.redAccent,),
                  suffixIcon: InkWell(child: Icon(Icons.search_outlined)),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  )
              ),
              controller: searchController,
            ),
          ),
          IconButton(onPressed: (){}, icon: Icon(Icons.notifications_outlined))
        ],
      ),
    );
  }
}
