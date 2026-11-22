import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../models/expense_data.dart';
import '../theme/app_theme.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String _extractedText = '';
  bool _isProcessing = false;
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  // Parsed fields
  String _parsedAmount = '';
  String _parsedMerchant = '';
  String _parsedDate = '';
  String _parsedCategory = 'Others';

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        actions: [
          if (_imageFile != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearImage,
              tooltip: 'Clear',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview / Camera Button
            _buildImageSection(),
            const SizedBox(height: 24),

            // Extracted Text
            if (_extractedText.isNotEmpty) ...[
              _buildExtractedTextSection(),
              const SizedBox(height: 24),
            ],

            // Parsed Fields Form
            if (_imageFile != null) ...[
              _buildParsedFieldsForm(),
              const SizedBox(height: 24),
            ],

            // Save Button
            if (_imageFile != null && _parsedAmount.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveExpense,
                  icon: const Icon(Icons.save),
                  label: const Text('Save as Expense'),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _imageFile == null
          ? FloatingActionButton.extended(
              onPressed: _showImageSourceDialog,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Receipt'),
            )
          : null,
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: _imageFile != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _imageFile!,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _clearImage,
                    ),
                  ),
                ),
                if (_isProcessing)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            )
          : InkWell(
              onTap: _showImageSourceDialog,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 48, color: AppTheme.primaryColor),
                    const SizedBox(height: 12),
                    Text('Tap to Scan Receipt', style: TextStyle(fontSize: 18, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Take a photo or choose from gallery', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildExtractedTextSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Extracted Text', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                TextButton.icon(
                  onPressed: _copyToClipboard,
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _extractedText,
                style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParsedFieldsForm() {
    final categories = ['Petrol', 'Grocery', 'Outside Food', 'Others'];
    final paymentMethods = ['Cash', 'Card', 'UPI', 'Bank Transfer'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review & Edit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _parsedAmount,
              decoration: const InputDecoration(
                labelText: 'Amount (AED) *',
                prefixText: 'AED ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => _parsedAmount = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _parsedMerchant,
              decoration: const InputDecoration(
                labelText: 'Merchant / Description *',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => _parsedMerchant = v,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _parsedCategory,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _parsedCategory = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _parsedDate,
              decoration: const InputDecoration(
                labelText: 'Date (optional)',
                border: OutlineInputBorder(),
                hintText: 'YYYY-MM-DD',
              ),
              onChanged: (v) => _parsedDate = v,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: 'Cash',
              decoration: const InputDecoration(labelText: 'Payment Method', border: OutlineInputBorder()),
              items: paymentMethods.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (v) {},
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                hintText: 'Extracted from receipt: $_parsedMerchant',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
      );
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _extractedText = '';
          _parsedAmount = '';
          _parsedMerchant = '';
          _parsedDate = '';
          _parsedCategory = 'Others';
        });
        await _processImage();
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _processImage() async {
    if (_imageFile == null) return;

    setState(() => _isProcessing = true);

    try {
      final inputImage = InputImage.fromFilePath(_imageFile!.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      setState(() {
        _extractedText = recognizedText.text;
        _parseReceiptText(recognizedText.text);
      });
    } catch (e) {
      _showError('OCR failed: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _parseReceiptText(String text) {
    // Simple regex-based parsing for common receipt patterns
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    // Try to find amount (look for currency patterns)
    final amountRegex = RegExp(r'(?:AED|د\.إ|\$|USD)?\s*(\d+[.,]\d{2})');
    for (final line in lines) {
      final matches = amountRegex.allMatches(line);
      for (final match in matches) {
        final amount = double.tryParse(match.group(1)!.replaceAll(',', ''));
        if (amount != null && amount > 0 && amount < 100000) {
          _parsedAmount = amount.toStringAsFixed(2);
          break;
        }
      }
      if (_parsedAmount.isNotEmpty) break;
    }

    // Try to find merchant name (usually first meaningful line)
    for (final line in lines) {
      if (line.length > 3 &&
          !line.contains(RegExp(r'^\d+[.,]\d{2}$')) &&
          !line.toLowerCase().contains('total') &&
          !line.toLowerCase().contains('subtotal') &&
          !line.toLowerCase().contains('tax') &&
          !line.toLowerCase().contains('vat') &&
          !line.toLowerCase().contains('change') &&
          !line.toLowerCase().contains('cash') &&
          !line.toLowerCase().contains('card') &&
          !line.toLowerCase().contains('receipt') &&
          !line.toLowerCase().contains('thank')) {
        _parsedMerchant = line;
        break;
      }
    }

    // Try to find date
    final dateRegex = RegExp(r'(\d{1,2}[-/]\d{1,2}[-/]\d{2,4}|\d{4}[-/]\d{1,2}[-/]\d{1,2})');
    for (final line in lines) {
      final match = dateRegex.firstMatch(line);
      if (match != null) {
        _parsedDate = match.group(1)!;
        break;
      }
    }

    // Try to guess category from merchant name
    final merchantLower = _parsedMerchant.toLowerCase();
    if (merchantLower.contains('petrol') ||
        merchantLower.contains('fuel') ||
        merchantLower.contains('gas') ||
        merchantLower.contains('adnoc') ||
        merchantLower.contains('enoc') ||
        merchantLower.contains('emarat')) {
      _parsedCategory = 'Petrol';
    } else if (merchantLower.contains('grocery') ||
        merchantLower.contains('supermarket') ||
        merchantLower.contains('lulu') ||
        merchantLower.contains('carrefour') ||
        merchantLower.contains('spinneys') ||
        merchantLower.contains('waitrose') ||
        merchantLower.contains('choithrams')) {
      _parsedCategory = 'Grocery';
    } else if (merchantLower.contains('restaurant') ||
        merchantLower.contains('cafe') ||
        merchantLower.contains('food') ||
        merchantLower.contains('kfc') ||
        merchantLower.contains('mcdonald') ||
        merchantLower.contains('subway') ||
        merchantLower.contains('pizza') ||
        merchantLower.contains('burger') ||
        merchantLower.contains('starbucks') ||
        merchantLower.contains('costa')) {
      _parsedCategory = 'Outside Food';
    }
  }

  void _clearImage() {
    setState(() {
      _imageFile = null;
      _extractedText = '';
      _parsedAmount = '';
      _parsedMerchant = '';
      _parsedDate = '';
      _parsedCategory = 'Others';
    });
  }

  void _copyToClipboard() {
    // In a real app, use clipboard package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  void _saveExpense() {
    final amount = double.tryParse(_parsedAmount);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    if (_parsedMerchant.isEmpty) {
      _showError('Please enter a description');
      return;
    }

    final expenseData = context.read<ExpenseData>();
    final entry = ExpenseLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _parsedDate.isNotEmpty
          ? DateTime.tryParse(_parsedDate) ?? DateTime.now()
          : DateTime.now(),
      category: _parsedCategory,
      description: _parsedMerchant,
      paymentMethod: 'Cash', // Could be from form
      amount: amount,
      notes: 'Scanned from receipt',
    );

    expenseData.addExpenseLogEntry(entry);

    _clearImage();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved: $_parsedMerchant - AED ${amount.toStringAsFixed(2)}')),
    );

    // Navigate back to expense log
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.dangerColor),
    );
  }
}