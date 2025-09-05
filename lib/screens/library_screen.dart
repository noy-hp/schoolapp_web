// lib/screens/library_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/nav_bar.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  /// Covers -> assets/covers/, PDFs -> assets/library_pdfs/
  /// Make sure pubspec.yaml includes both folders.
  final List<_Book> _allBooks = const [
    _Book(
      title: 'ພະຍາດເບົາຫວານປະເພດ 2',
      cover: 'assets/covers/1.png',
      pdf: 'assets/library_pdfs/1.pdf',
    ),
    _Book(
      title: 'ເບົາຫວານໃນຄົນເຈັບຜະດຸງຄັນ',
      cover: 'assets/covers/2.png',
      pdf: 'assets/library_pdfs/2.pdf',
    ),
    _Book(
      title: 'ພະຍາດເບົາຫວານ',
      cover: 'assets/covers/3.png',
      pdf: 'assets/library_pdfs/3.pdf',
    ),
    _Book(
      title: 'ພະຍາດໄຂ້ຍຸງ',
      cover: 'assets/covers/4.png',
      pdf: 'assets/library_pdfs/4.pdf',
    ),
    _Book(
      title: 'ເນື້ອໃນພະຍາດສຸກເສີນ ແລະ ພື້ນພູຊິບ',
      cover: 'assets/covers/5.png',
      pdf: 'assets/library_pdfs/5.pdf',
    ),
    _Book(
      title: 'ພະຍາດພາຍໃນ',
      cover: 'assets/covers/6.png',
      pdf: 'assets/library_pdfs/6.pdf',
    ),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _allBooks
        .where((b) => b.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 1400
        ? 5
        : width >= 1200
            ? 4
            : width >= 900
                ? 3
                : width >= 600
                    ? 2
                    : 1;

    return Scaffold(
      appBar: const NavBar(),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // Heading
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Library',
                style: GoogleFonts.merriweather(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search by title, author, tag, or year…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF7F5FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFDDDEE6)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: filtered.isEmpty
                  ? const _EmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        // Slightly taller so long Lao titles don't overflow
                        childAspectRatio: 3 / 4.65,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _BookCard(book: filtered[i]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final _Book book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Open dedicated in-app PDF viewer page (NOT News)
        Navigator.pushNamed(
          context,
          '/pdf-view',
          arguments: {'asset': book.pdf, 'title': book.title},
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cover
            AspectRatio(
              aspectRatio: 3 / 4,
              child: _CoverImage(path: book.cover),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String path;
  const _CoverImage({required this.path});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F2F5),
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.image_not_supported_rounded,
              size: 40, color: Colors.black38),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No books found',
        style: TextStyle(color: Colors.black54),
      ),
    );
  }
}

class _Book {
  final String title;
  final String cover;
  final String pdf;
  const _Book({
    required this.title,
    required this.cover,
    required this.pdf,
  });
}
