// import 'dart:io';
// import 'package:farm_vest/features/investor/data/models/unit_response.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:printing/printing.dart';

import 'package:farm_vest/core/localization/translation_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// class InvoicePdfView extends ConsumerStatefulWidget {
//   final Order order;
//   final String filePath;

//   InvoicePdfView({
//     super.key,
//     required this.order,
//     required this.filePath,
//   });

//   @override
//   State<InvoicePdfView> createState() => _InvoicePdfViewState();
// }

// class _InvoicePdfViewState extends ConsumerState<InvoicePdfView> {
//   late final Future<_PdfSource> _sourceFuture;
//   Object? _viewerError;
//   int? _totalPages;
//   int? _currentPage;

//   @override
//   void initState() {
//     super.initState();
//     _sourceFuture = _preparePdf(widget.filePath);
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: AppBar(
//         title: Text('Invoice'.tr(ref)),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.share),
//             onPressed: () async {
//               try {
//                 final bytes = await File(widget.filePath).readAsBytes();
//                 await Printing.sharePdf(
//                   bytes: bytes,
//                   filename: 'invoice_${widget.order.id}.pdf',
//                 );
//               } catch (e, st) {
//                 debugPrint('Failed to share invoice PDF: $e\n$st');
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Failed to share invoice: $e')),
//                   );
//                 }
//               }
//             },
//           ),
//         ],
//       ),
//       body: FutureBuilder<_PdfSource>(
//         future: _sourceFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState != ConnectionState.done) {
//             return Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return _ErrorView(
//               title: 'Unable to open invoice PDF',
//               message: snapshot.error.toString(),
//               filePath: widget.filePath,
//             );
//           }

//           if (_viewerError != null) {
//             return _ErrorView(
//               title: 'PDF renderer error',
//               message: _viewerError.toString(),
//               filePath: widget.filePath,
//             );
//           }

//           final src = snapshot.data;
//           if (src == null) {
//             return _ErrorView(
//               title: 'Unable to open invoice PDF',
//               message: 'Unknown error (no data)',
//               filePath: widget.filePath,
//             );
//           }

//           return Column(
//             children: [
//               Expanded(
//                 child: PDFView(
//                   filePath: src.path,
//                   enableSwipe: true,
//                   swipeHorizontal: true,
//                   autoSpacing: false,
//                   pageFling: true,
//                   onRender: (pages) {
//                     if (!mounted) return;
//                     setState(() {
//                       _totalPages = pages;
//                       _currentPage ??= 1;
//                     });
//                   },
//                   onPageChanged: (page, total) {
//                     if (!mounted) return;
//                     setState(() {
//                       _currentPage = (page ?? 0) + 1;
//                       _totalPages = total;
//                     });
//                   },
//                   onError: (error) {
//                     debugPrint('PDFView error: $error');
//                     if (!mounted) return;
//                     setState(() => _viewerError = error);
//                   },
//                   onPageError: (page, error) {
//                     debugPrint('PDFView page error (page: $page): $error');
//                     if (!mounted) return;
//                     setState(() => _viewerError = error);
//                   },
//                 ),
//               ),
//               if (_totalPages != null && _currentPage != null)
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: 8),
//                   child: Text(
//                     'Page $_currentPage of $_totalPages',
//                     style: Theme.of(context).textTheme.bodySmall,
//                   ),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Future<_PdfSource> _preparePdf(String filePath) async {
//     final normalized = filePath.trim();
//     if (normalized.isEmpty) {
//       throw ArgumentError('Empty PDF filePath');
//     }

//     final file = File(normalized);
//     final exists = await file.exists();
//     if (!exists) {
//       throw FileSystemException('PDF file does not exist', normalized);
//     }

//     final length = await file.length();
//     if (length <= 0) {
//       throw FileSystemException('PDF file is empty (0 bytes)', normalized);
//     }

//     return _PdfSource(path: normalized);
//   }
// }

// class _PdfSource {
//   final String path;

//   _PdfSource({required this.path});
// }

// class _ErrorView extends ConsumerWidget {
//   final String title;
//   final String message;
//   final String filePath;

//   _ErrorView({
//     required this.title,
//     required this.message,
//     required this.filePath,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               title,
//               style: Theme.of(
//                 context,
//               ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 12),
//             Text(
//               message,
//               style: Theme.of(
//                 context,
//               ).textTheme.bodySmall?.copyWith(color: Colors.red.shade700),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 12),
//             Text(
//               filePath,
//               style: Theme.of(context).textTheme.bodySmall,
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
