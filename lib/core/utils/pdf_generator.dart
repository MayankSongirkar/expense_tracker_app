/// PDF Receipt Generator Utility
/// 
/// A comprehensive utility class for generating professional PDF receipts
/// for expense records. Provides formatted, printable receipts with
/// Indian currency formatting and numbering system support.
/// 
/// Key Features:
/// - Professional receipt layout with headers and footers
/// - Indian Rupee formatting with Lakh/Crore notation
/// - Amount in words conversion (Indian numbering system)
/// - Proper PDF structure with sections and styling
/// - Device storage integration for saving receipts
/// - Timestamp and metadata inclusion
/// 
/// Technical Implementation:
/// - Uses pdf package for document generation
/// - Supports A4 page format for standard printing
/// - Includes proper styling with colors and borders
/// - Handles edge cases for amount conversion
/// - Provides clean, readable receipt format
/// 
/// Usage:
/// ```dart
/// final pdfBytes = await PdfGenerator.generateExpenseReceipt(expense);
/// final filePath = await PdfGenerator.savePdfToDevice(pdfBytes, 'receipt.pdf');
/// ```

import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../features/expenses/domain/entities/expense.dart';
import 'currency_formatter.dart';

/// Professional PDF receipt generator for expense records
/// 
/// This utility class creates formatted, printable PDF receipts for individual
/// expenses with professional styling and comprehensive information display.
/// 
/// The generated receipts include:
/// - Professional header with app branding
/// - Complete expense details (ID, date, title, category, notes)
/// - Formatted amount display with Indian currency
/// - Amount in words using Indian numbering system
/// - Generation timestamp and footer information
/// - Proper PDF structure for printing and sharing
class PdfGenerator {
  /// Generates a professional PDF receipt for a single expense
  /// 
  /// Creates a complete A4-sized PDF document with professional formatting,
  /// including all expense details, amount formatting, and metadata.
  /// 
  /// The receipt includes:
  /// - Header section with app branding
  /// - Expense details in a structured format
  /// - Highlighted amount section with currency formatting
  /// - Amount in words for verification
  /// - Footer with generation timestamp
  /// 
  /// [expense] The expense entity to generate a receipt for
  /// 
  /// Returns:
  /// - [Uint8List] containing the PDF document bytes
  /// 
  /// Example:
  /// ```dart
  /// final expense = Expense(
  ///   id: 'exp_123',
  ///   title: 'Business Lunch',
  ///   amount: 1250.0,
  ///   category: 'Food',
  ///   date: DateTime.now(),
  /// );
  /// final pdfBytes = await PdfGenerator.generateExpenseReceipt(expense);
  /// ```
  static Future<Uint8List> generateExpenseReceipt(Expense expense) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Professional header section with branding
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'EXPENSE RECEIPT',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Smart Expense Tracker',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.blue600,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // Detailed expense information section
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildReceiptRow('Receipt ID:', expense.id),
                    pw.SizedBox(height: 12),
                    _buildReceiptRow('Date:', DateFormat('dd MMM yyyy, hh:mm a').format(expense.date)),
                    pw.SizedBox(height: 12),
                    _buildReceiptRow('Title:', expense.title),
                    pw.SizedBox(height: 12),
                    _buildReceiptRow('Category:', expense.category),
                    pw.SizedBox(height: 12),
                    if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                      _buildReceiptRow('Notes:', expense.notes!),
                      pw.SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Highlighted amount section
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  border: pw.Border.all(color: PdfColors.green200),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Amount:',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      CurrencyFormatter.format(expense.amount),
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green800,
                      ),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 30),
              
              // Amount in words for verification
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Amount in Words:',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      _convertAmountToWords(expense.amount),
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              pw.Spacer(),
              
              // Footer with generation metadata
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.grey300),
                  ),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Generated on ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'This is a digitally generated receipt from Smart Expense Tracker',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Builds a formatted row for receipt information display
  /// 
  /// Creates a consistent layout for label-value pairs in the receipt,
  /// with proper spacing and typography for professional appearance.
  /// 
  /// [label] The field label (e.g., 'Receipt ID:', 'Date:')
  /// [value] The corresponding value to display
  /// 
  /// Returns a formatted PDF widget with label and value
  static pw.Widget _buildReceiptRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  /// Converts monetary amount to words using Indian numbering system
  /// 
  /// Provides a complete textual representation of the amount including
  /// rupees and paise, following Indian currency conventions.
  /// 
  /// Features:
  /// - Supports Indian numbering system (Lakh, Crore)
  /// - Handles both rupees and paise
  /// - Provides 'Only' suffix for completeness
  /// - Handles zero amounts appropriately
  /// 
  /// [amount] The monetary amount to convert
  /// 
  /// Returns formatted string like "One Thousand Two Hundred Fifty Rupees Only"
  /// 
  /// Example:
  /// ```dart
  /// _convertAmountToWords(1250.75) // "One Thousand Two Hundred Fifty Rupees and Seventy Five Paise Only"
  /// ```
  static String _convertAmountToWords(double amount) {
    final rupees = amount.floor();
    final paise = ((amount - rupees) * 100).round();
    
    String result = _convertNumberToWords(rupees);
    if (result.isNotEmpty) {
      result += ' Rupees';
    }
    
    if (paise > 0) {
      if (result.isNotEmpty) {
        result += ' and ';
      }
      result += '${_convertNumberToWords(paise)} Paise';
    }
    
    if (result.isEmpty) {
      result = 'Zero Rupees';
    }
    
    return result + ' Only';
  }

  /// Converts a number to its word representation
  /// 
  /// Handles the conversion of integers to English words following
  /// Indian numbering conventions with support for:
  /// - Basic numbers (1-19)
  /// - Tens (20, 30, 40, etc.)
  /// - Hundreds
  /// - Thousands
  /// - Lakhs (100,000s)
  /// - Crores (10,000,000s)
  /// 
  /// [number] The integer to convert to words
  /// 
  /// Returns the word representation or empty string for zero
  /// 
  /// Example:
  /// ```dart
  /// _convertNumberToWords(1250) // "One Thousand Two Hundred Fifty"
  /// _convertNumberToWords(125000) // "One Lakh Twenty Five Thousand"
  /// ```
  static String _convertNumberToWords(int number) {
    if (number == 0) return '';
    
    // Basic number words for 0-19
    final ones = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
      'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
      'Seventeen', 'Eighteen', 'Nineteen'
    ];
    
    // Tens words for 20, 30, 40, etc.
    final tens = [
      '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
    ];
    
    // Handle different number ranges with Indian numbering system
    if (number < 20) {
      return ones[number];
    } else if (number < 100) {
      return tens[number ~/ 10] + (number % 10 != 0 ? ' ${ones[number % 10]}' : '');
    } else if (number < 1000) {
      return '${ones[number ~/ 100]} Hundred' + 
             (number % 100 != 0 ? ' ${_convertNumberToWords(number % 100)}' : '');
    } else if (number < 100000) {
      return '${_convertNumberToWords(number ~/ 1000)} Thousand' +
             (number % 1000 != 0 ? ' ${_convertNumberToWords(number % 1000)}' : '');
    } else if (number < 10000000) {
      return '${_convertNumberToWords(number ~/ 100000)} Lakh' +
             (number % 100000 != 0 ? ' ${_convertNumberToWords(number % 100000)}' : '');
    } else {
      return '${_convertNumberToWords(number ~/ 10000000)} Crore' +
             (number % 10000000 != 0 ? ' ${_convertNumberToWords(number % 10000000)}' : '');
    }
  }

  /// Saves PDF bytes to device storage
  /// 
  /// Writes the generated PDF to the device's documents directory
  /// for user access and sharing capabilities.
  /// 
  /// [pdfBytes] The PDF document as bytes
  /// [fileName] The desired filename for the saved PDF
  /// 
  /// Returns the full file path where the PDF was saved
  /// 
  /// Example:
  /// ```dart
  /// final filePath = await PdfGenerator.savePdfToDevice(pdfBytes, 'expense_receipt.pdf');
  /// print('PDF saved to: $filePath');
  /// ```
  static Future<String> savePdfToDevice(Uint8List pdfBytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }
}