import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:receipt_validator/models/verification_response.dart';

class PaymentEntryPage extends StatefulWidget {
  static String route = 'signup-page';
  @override
  _PaymentEntryPageState createState() => _PaymentEntryPageState();
}

class _PaymentEntryPageState extends State<PaymentEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tinController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final FocusNode _accountFocusNode = FocusNode();
  
  List<String> recentAccounts = ['1000123456789', '1000098765432', '1000012345678'];
  List<String> filteredRecentAccounts = [];

  @override
  void initState() {
    super.initState();
    filteredRecentAccounts = recentAccounts;
    
    _accountNumberController.addListener(_filterAccounts);
    _tinController.addListener(_updateFormState);
    _accountNumberController.addListener(_updateFormState);
  }

  void _updateFormState() => setState(() {});
  
  void _filterAccounts() {
    final input = _accountNumberController.text;
    setState(() {
      filteredRecentAccounts = recentAccounts
          .where((account) => account.startsWith(input))
          .toList();
    });
  }

  bool get _isFormValid => _formKey.currentState?.validate() ?? false;

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.8.125:8000/verify'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'accountNumber': _accountNumberController.text,
            'referenceNumber': _tinController.text,
          }),
        );

        if (response.statusCode == 200) {
          final verificationResponse = VerificationResponse.fromJson(
            jsonDecode(response.body),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationResultPage(
                response: verificationResponse,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to verify payment')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _accountNumberController.removeListener(_filterAccounts);
    _tinController.removeListener(_updateFormState);
    _accountNumberController.removeListener(_updateFormState);
    _accountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 8),
                        Row(
                          children: [
                            Text(
                              'Verify your',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              ' Payment Details',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        _buildAccountNumberField(),
                        if (_accountNumberController.text.isNotEmpty &&
                            filteredRecentAccounts.isNotEmpty)
                          _buildAccountSuggestions(),
                        SizedBox(height: 16),
                        _buildReferenceNumberField(),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.qr_code_scanner, color: Colors.grey),
                                SizedBox(width: 5),
                                Text(
                                  'Scan Receipt (Coming Soon)',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _isFormValid ? _handleSubmit : null,
                child: Center(
                  child: Text(
                    'Check your receipt',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: _isFormValid ? Colors.blue : Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountNumberField() {
    return Stack(
      children: [
        TextFormField(
          controller: _accountNumberController,
          focusNode: _accountFocusNode,
          decoration: InputDecoration(
            labelText: null,
            contentPadding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color.fromARGB(255, 227, 227, 227)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'This field is required';
            if (!RegExp(r'^(1000\d{9}|10000\d{8})$').hasMatch(value)) {
              return 'Must be 13 digits starting with 1000/10000';
            }
            return null;
          },
          style: TextStyle(fontSize: 16),
        ),
        Positioned(
          left: 10,
          top: 2,
          child: Text(
            'Bank account number',
            style: TextStyle(
              color: _accountNumberController.text.isEmpty ? Colors.black : Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceNumberField() {
    return Stack(
      children: [
        TextFormField(
          controller: _tinController,
          decoration: InputDecoration(
            labelText: null,
            contentPadding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color.fromARGB(255, 227, 227, 227)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue, width: 2.0),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'This field is required';
            
            return null;
          },
          style: TextStyle(fontSize: 16),
        ),
        Positioned(
          left: 10,
          top: 2,
          child: Text(
            'Reference Number',
            style: TextStyle(
              color: _tinController.text.isEmpty ? Colors.black : Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSuggestions() {
    return Container(
      margin: EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: filteredRecentAccounts.length,
        separatorBuilder: (_, __) => Divider(height: 1),
        itemBuilder: (context, index) {
          final account = filteredRecentAccounts[index];
          return ListTile(
            dense: true,
            title: Text(account),
            onTap: () {
              _accountNumberController.text = account;
              _accountFocusNode.unfocus();
            },
          );
        },
      ),
    );
  }
}

// VerificationResultPage remains the same as in original code

class VerificationResultPage extends StatelessWidget {
  final VerificationResponse response;

  const VerificationResultPage({
    Key? key,
    required this.response,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: response.isValid
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 80),
                  SizedBox(height: 10),
                  Text(
                    'Payment Verified',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Amount: ${response.amount}'),
                  Text('Payer: ${response.payer}'),
                  Text('Date: ${response.date}'),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Check Another Transaction',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 80),
                  SizedBox(height: 10),
                  Text(
                    'Verification Failed',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('Please try again.'),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('Check Another Transaction'),
                  ),
                ],
              ),
      ),
    );
  }
}
