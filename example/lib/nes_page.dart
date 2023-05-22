import 'package:flutter/material.dart';

class NESPage extends StatefulWidget {
  const NESPage({Key? key}) : super(key: key);

  @override
  State<NESPage> createState() => _NESPageState();
}

class _NESPageState extends State<NESPage> {
  Future<void> _loadNES() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _loadNES,
        child: const Icon(Icons.refresh),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 256 / 240,
          child: Container(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
