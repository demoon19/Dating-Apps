import 'package:flutter/material.dart';

class PageImpression extends StatefulWidget {
  @override
  _PageImpressionState createState() => _PageImpressionState();
}

class _PageImpressionState extends State<PageImpression>
    with SingleTickerProviderStateMixin {
  String _displayText = '';
  double _opacity = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showText(String text) {
    setState(() {
      _displayText = text;
      _opacity = 1.0;
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF424242),
      appBar: AppBar(
        backgroundColor: Color(0xFF585752),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Kesan',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFFF4F5CA),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Matkul TPM ini sangat membantu saya dalam menambah insomnia dan melewati batas limit yang mungkin saya kira sudah mentok sampai disitu namun dengan adanya TPM saya yakin saya bisa melampauinya',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFFF4F5CA),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Pesan',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFFF4F5CA),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _showText(
                        'Semoga tidak ketemu lagi \n di matkul yang sama'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF585752),
                      foregroundColor: Color(0xFFfefad4),
                      fixedSize: Size(150, 50),
                    ),
                    child: Text('Kemungkinan'),
                  ),
                  ElevatedButton(
                    onPressed: () => _showText(
                        'Semoga panjang umur dan sehat selalu \n untuk kita semua'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF585752),
                      foregroundColor: Color(0xFFfefad4),
                      fixedSize: Size(150, 50),
                    ),
                    child: Text('Kemungkinan'),
                  ),
                ],
              ),
              SizedBox(height: 30),
              AnimatedOpacity(
                opacity: _opacity,
                duration: Duration(seconds: 1),
                child: ScaleTransition(
                  scale: _animation,
                  child: Text(
                    _displayText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFF4F5CA),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
