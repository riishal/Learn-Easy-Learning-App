import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:learn_easy/view/course_details.dart';
import 'package:learn_easy/view/home_page.dart';

class PdfViewPage extends StatelessWidget {
  final List<dynamic> data;
  final int index;
  const PdfViewPage({super.key, required this.index, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.grey[800],
            title: Text(
              data[buttonIndex]["pdf"][pdfIndex]["pdfName"],
              style: GoogleFonts.adamina(
                letterSpacing: 1,
                fontWeight: FontWeight.bold,
              ),
            )),
        body: PDF(
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: false,
          pageFling: false,
          onError: (error) {
            print(error.toString());
          },
          onPageError: (page, error) {
            print('$page: ${error.toString()}');
          },
          onPageChanged: (int? page, int? total) {
            print('page change: $page/$total');
          },
        ).cachedFromUrl(
          'https://africau.edu/images/default/sample.pdf',
          placeholder: (progress) => Center(child: Text('$progress %')),
          errorWidget: (error) => Center(child: Text(error.toString())),
        ));
  }
}
