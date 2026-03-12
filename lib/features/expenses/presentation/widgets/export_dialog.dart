import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';

/// Dialog for exporting expenses to CSV
class ExportDialog extends ConsumerStatefulWidget {
  const ExportDialog({super.key});

  @override
  ConsumerState<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<ExportDialog> {
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Expenses'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Export all your expenses to CSV format.'),
          const SizedBox(height: 16),
          const Text(
            'The CSV will include:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('• Date'),
          const Text('• Title'),
          const Text('• Category'),
          const Text('• Amount'),
          const Text('• Notes'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isExporting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isExporting ? null : _exportToCsv,
          child: _isExporting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Export'),
        ),
      ],
    );
  }

  Future<void> _exportToCsv() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final csvData = await ref.read(expenseProvider.notifier).exportToCsv();
      
      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: csvData));
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV data copied to clipboard!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}