import 'package:flutter/material.dart';
import 'package:receipt_validator/views/pages/payment.dart';
class BankSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            'Reciept Validator',
            style: TextStyle(color: Colors.black),
          ),
        ),
        
        elevation: 0,
        automaticallyImplyLeading: false,
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Bank',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            // Dropdown for CBE and other banks
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Text(
                  'Select Bank',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // CBE - Clickable
                        BankButton(
                          title: 'CBE',
                          backgroundColor: Colors.blueAccent,
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentEntryPage(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 10),
                        // Hiberet Bank - Disabled
                        BankButton(
                          title: 'Hiberet Bank',
                          backgroundColor: Colors.grey.shade300,
                          textColor: Colors.grey.shade600,
                          onPressed: null,
                        ),
                        SizedBox(height: 10),
                        // Buna Bank - Disabled
                        BankButton(
                          title: 'Buna Bank',
                          backgroundColor: Colors.grey.shade300,
                          textColor: Colors.grey.shade600,
                          onPressed: null,
                        ),
                        SizedBox(height: 10),
                        // Dashen Bank - Disabled
                        BankButton(
                          title: 'Dashen Bank',
                          backgroundColor: Colors.grey.shade300,
                          textColor: Colors.grey.shade600,
                          onPressed: null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }
}

class BankButton extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;

  const BankButton({
    required this.title,
    required this.backgroundColor,
    required this.textColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: onPressed == null ? 0 : 2,
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
