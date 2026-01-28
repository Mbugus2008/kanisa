import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kanisa/widgets/app_drawer.dart';

class LanguageOption {
  const LanguageOption({required this.id, required this.name});

  final String id;
  final String name;
}

class BookMeta {
  const BookMeta({
    required this.name,
    required this.chapters,
    required this.verses,
    required this.theme,
    this.aliases = const <String>[],
  });

  final String name;
  final int chapters;
  final int verses;
  final String theme;
  final List<String> aliases;
}

class BookReference {
  const BookReference({required this.bookName, this.chapter, this.verse});

  final String bookName;
  final int? chapter;
  final int? verse;
}

class BookMetadataRepository {
  BookMetadataRepository._();

  static const List<BookMeta> _bookMetadata = [
    BookMeta(
      name: 'Genesis',
      chapters: 50,
      verses: 1533,
      aliases: ['gen', 'ge', 'gn'],
      theme:
          "Origins of creation, humanity, and God's covenant with the patriarchs.",
    ),
    BookMeta(
      name: 'Exodus',
      chapters: 40,
      verses: 1213,
      aliases: ['exo', 'ex'],
      theme:
          'God delivers Israel from Egypt and establishes His covenant at Sinai.',
    ),
    BookMeta(
      name: 'Leviticus',
      chapters: 27,
      verses: 859,
      aliases: ['lev', 'lv'],
      theme:
          'Holiness laws and sacrificial worship for life in God\'s presence.',
    ),
    BookMeta(
      name: 'Numbers',
      chapters: 36,
      verses: 1288,
      aliases: ['num', 'nm', 'nb'],
      theme:
          'Israel\'s wilderness journey and God\'s faithful guidance despite rebellion.',
    ),
    BookMeta(
      name: 'Deuteronomy',
      chapters: 34,
      verses: 959,
      aliases: ['deut', 'dt'],
      theme:
          'Moses\' final sermons urging covenant loyalty before entering the land.',
    ),
    BookMeta(
      name: 'Joshua',
      chapters: 24,
      verses: 658,
      aliases: ['jos', 'js'],
      theme:
          'Israel conquers and settles the promised land through God\'s leadership.',
    ),
    BookMeta(
      name: 'Judges',
      chapters: 21,
      verses: 618,
      aliases: ['judg', 'jdg', 'jg'],
      theme:
          'Cycles of covenant unfaithfulness and God\'s rescue through judges.',
    ),
    BookMeta(
      name: 'Ruth',
      chapters: 4,
      verses: 85,
      aliases: ['ru'],
      theme: 'Loyal love and redemption culminating in David\'s family line.',
    ),
    BookMeta(
      name: '1 Samuel',
      chapters: 31,
      verses: 810,
      aliases: ['1 sam', '1sm', '1sa', 'i samuel', 'first samuel'],
      theme:
          'Transition from judges to monarchy through Samuel, Saul, and David.',
    ),
    BookMeta(
      name: '2 Samuel',
      chapters: 24,
      verses: 695,
      aliases: ['2 sam', '2sm', '2sa', 'ii samuel', 'second samuel'],
      theme:
          'David\'s reign displaying covenant grace and consequences for sin.',
    ),
    BookMeta(
      name: '1 Kings',
      chapters: 22,
      verses: 816,
      aliases: ['1 ki', '1kgs', 'i kings', 'first kings'],
      theme:
          'Kingdom united to divided, highlighting faithfulness versus idolatry.',
    ),
    BookMeta(
      name: '2 Kings',
      chapters: 25,
      verses: 719,
      aliases: ['2 ki', '2kgs', 'ii kings', 'second kings'],
      theme:
          'Decline of Israel and Judah leading to exile amid prophetic warnings.',
    ),
    BookMeta(
      name: '1 Chronicles',
      chapters: 29,
      verses: 942,
      aliases: ['1 chr', '1chron', 'i chronicles', 'first chronicles'],
      theme:
          'Genealogies and David\'s reign emphasizing temple worship and covenant hope.',
    ),
    BookMeta(
      name: '2 Chronicles',
      chapters: 36,
      verses: 822,
      aliases: ['2 chr', '2chron', 'ii chronicles', 'second chronicles'],
      theme:
          'History of Judah\'s kings with focus on faithfulness to God\'s temple.',
    ),
    BookMeta(
      name: 'Ezra',
      chapters: 10,
      verses: 280,
      aliases: ['ezr'],
      theme:
          'Return from exile and rebuilding of the temple under God\'s guidance.',
    ),
    BookMeta(
      name: 'Nehemiah',
      chapters: 13,
      verses: 406,
      aliases: ['neh'],
      theme:
          'Rebuilding Jerusalem\'s walls and renewing covenant faithfulness.',
    ),
    BookMeta(
      name: 'Esther',
      chapters: 10,
      verses: 167,
      aliases: ['est'],
      theme: 'God preserves His people through courageous faith in exile.',
    ),
    BookMeta(
      name: 'Job',
      chapters: 42,
      verses: 1070,
      aliases: ['job'],
      theme: 'Suffering, divine wisdom, and God\'s sovereignty in human pain.',
    ),
    BookMeta(
      name: 'Psalms',
      chapters: 150,
      verses: 2461,
      aliases: ['ps', 'psa', 'psm'],
      theme:
          'A collection of prayers and songs expressing the full range of faith.',
    ),
    BookMeta(
      name: 'Proverbs',
      chapters: 31,
      verses: 915,
      aliases: ['prov', 'prv', 'pr'],
      theme:
          'Wisdom sayings for living skillfully in covenant relationship with God.',
    ),
    BookMeta(
      name: 'Ecclesiastes',
      chapters: 12,
      verses: 222,
      aliases: ['eccl', 'ecc', 'qohelet'],
      theme: 'Life\'s meaning is found by fearing God amid life\'s enigmas.',
    ),
    BookMeta(
      name: 'Song of Solomon',
      chapters: 8,
      verses: 117,
      aliases: ['song of songs', 'songs', 'sos', 'canticles'],
      theme: 'Celebration of covenant love between bridegroom and bride.',
    ),
    BookMeta(
      name: 'Isaiah',
      chapters: 66,
      verses: 1292,
      aliases: ['isa'],
      theme:
          'Prophecies of judgment and comfort anchored in the coming Messiah.',
    ),
    BookMeta(
      name: 'Jeremiah',
      chapters: 52,
      verses: 1364,
      aliases: ['jer'],
      theme:
          'Warnings of judgment, calls to repentance, and promise of a new covenant.',
    ),
    BookMeta(
      name: 'Lamentations',
      chapters: 5,
      verses: 154,
      aliases: ['lam'],
      theme:
          'Poetic grief over Jerusalem paired with hope in God\'s steadfast love.',
    ),
    BookMeta(
      name: 'Ezekiel',
      chapters: 48,
      verses: 1273,
      aliases: ['ezek', 'ezk'],
      theme:
          'Visions of God\'s glory, judgment, and restoration for His people.',
    ),
    BookMeta(
      name: 'Daniel',
      chapters: 12,
      verses: 357,
      aliases: ['dan'],
      theme:
          'Faithful witness in exile and apocalyptic hope in God\'s kingdom.',
    ),
    BookMeta(
      name: 'Hosea',
      chapters: 14,
      verses: 197,
      aliases: ['hos'],
      theme:
          'God\'s faithful love illustrated through Hosea\'s marriage and prophecies.',
    ),
    BookMeta(
      name: 'Joel',
      chapters: 3,
      verses: 73,
      aliases: ['joel'],
      theme:
          'Day of the Lord imagery calling for repentance and promising restoration.',
    ),
    BookMeta(
      name: 'Amos',
      chapters: 9,
      verses: 146,
      aliases: ['amo'],
      theme: 'Justice for the oppressed and accountability for empty religion.',
    ),
    BookMeta(
      name: 'Obadiah',
      chapters: 1,
      verses: 21,
      aliases: ['obad', 'ob'],
      theme: 'Judgment on Edom and hope for Zion\'s deliverance.',
    ),
    BookMeta(
      name: 'Jonah',
      chapters: 4,
      verses: 48,
      aliases: ['jon'],
      theme:
          'God\'s compassion for the nations and challenge to hardened hearts.',
    ),
    BookMeta(
      name: 'Micah',
      chapters: 7,
      verses: 105,
      aliases: ['mic'],
      theme:
          'Judgment and hope culminating in the promise of a righteous ruler.',
    ),
    BookMeta(
      name: 'Nahum',
      chapters: 3,
      verses: 47,
      aliases: ['nah'],
      theme: 'God\'s justice against Nineveh and comfort for Judah.',
    ),
    BookMeta(
      name: 'Habakkuk',
      chapters: 3,
      verses: 56,
      aliases: ['hab'],
      theme: 'Dialogue with God about injustice and living by faith.',
    ),
    BookMeta(
      name: 'Zephaniah',
      chapters: 3,
      verses: 53,
      aliases: ['zeph'],
      theme:
          'Day of the Lord purifies the nations and restores humble worshippers.',
    ),
    BookMeta(
      name: 'Haggai',
      chapters: 2,
      verses: 38,
      aliases: ['hag'],
      theme: 'Renewed zeal to rebuild the temple and anticipate God\'s glory.',
    ),
    BookMeta(
      name: 'Zechariah',
      chapters: 14,
      verses: 211,
      aliases: ['zech', 'zec'],
      theme: 'Visions of restoration and the coming Messianic King.',
    ),
    BookMeta(
      name: 'Malachi',
      chapters: 4,
      verses: 55,
      aliases: ['mal'],
      theme:
          'Call to covenant faithfulness and promise of the coming messenger.',
    ),
    BookMeta(
      name: 'Matthew',
      chapters: 28,
      verses: 1071,
      aliases: ['matt', 'mt'],
      theme: 'Jesus fulfills Old Testament promises as Messiah and King.',
    ),
    BookMeta(
      name: 'Mark',
      chapters: 16,
      verses: 678,
      aliases: ['mk'],
      theme:
          'Fast-paced narrative revealing Jesus as the suffering Son of God.',
    ),
    BookMeta(
      name: 'Luke',
      chapters: 24,
      verses: 1151,
      aliases: ['lk'],
      theme:
          'Orderly account showing Jesus\' compassion and salvation for all people.',
    ),
    BookMeta(
      name: 'John',
      chapters: 21,
      verses: 879,
      aliases: ['jn', 'jo'],
      theme: 'Signs and teachings revealing Jesus as the incarnate Word.',
    ),
    BookMeta(
      name: 'Acts',
      chapters: 28,
      verses: 1007,
      aliases: ['act'],
      theme: 'Rise of the early church empowered by the Holy Spirit.',
    ),
    BookMeta(
      name: 'Romans',
      chapters: 16,
      verses: 433,
      aliases: ['rom', 'ro'],
      theme:
          'Gospel explanation of righteousness by faith and transformed living.',
    ),
    BookMeta(
      name: '1 Corinthians',
      chapters: 16,
      verses: 437,
      aliases: ['1 cor', '1co', 'i corinthians', 'first corinthians'],
      theme:
          'Pastoral correction guiding a divided church toward love and order.',
    ),
    BookMeta(
      name: '2 Corinthians',
      chapters: 13,
      verses: 257,
      aliases: ['2 cor', '2co', 'ii corinthians', 'second corinthians'],
      theme:
          'Paul defends his ministry and highlights strength through weakness.',
    ),
    BookMeta(
      name: 'Galatians',
      chapters: 6,
      verses: 149,
      aliases: ['gal', 'ga'],
      theme: 'Freedom in Christ apart from the law and life in the Spirit.',
    ),
    BookMeta(
      name: 'Ephesians',
      chapters: 6,
      verses: 155,
      aliases: ['eph', 'ep'],
      theme: 'Church unity in Christ and Spirit-empowered living.',
    ),
    BookMeta(
      name: 'Philippians',
      chapters: 4,
      verses: 104,
      aliases: ['phil', 'php'],
      theme:
          'Joyful partnership in the gospel and imitation of Christ\'s humility.',
    ),
    BookMeta(
      name: 'Colossians',
      chapters: 4,
      verses: 95,
      aliases: ['col', 'co'],
      theme: 'Supremacy of Christ and the new life shaped by Him.',
    ),
    BookMeta(
      name: '1 Thessalonians',
      chapters: 5,
      verses: 89,
      aliases: ['1 thes', '1th', 'i thessalonians', 'first thessalonians'],
      theme: 'Encouragement in persecution and hope in Christ\'s return.',
    ),
    BookMeta(
      name: '2 Thessalonians',
      chapters: 3,
      verses: 47,
      aliases: ['2 thes', '2th', 'ii thessalonians', 'second thessalonians'],
      theme: 'Clarifying end-times hope and steadfast living.',
    ),
    BookMeta(
      name: '1 Timothy',
      chapters: 6,
      verses: 113,
      aliases: ['1 tim', '1ti', 'i timothy', 'first timothy'],
      theme: 'Pastoral instruction for healthy doctrine and church leadership.',
    ),
    BookMeta(
      name: '2 Timothy',
      chapters: 4,
      verses: 83,
      aliases: ['2 tim', '2ti', 'ii timothy', 'second timothy'],
      theme: 'Final charge to remain faithful and pass on the gospel.',
    ),
    BookMeta(
      name: 'Titus',
      chapters: 3,
      verses: 46,
      aliases: ['tit'],
      theme: 'Establishing godly leadership and good works rooted in grace.',
    ),
    BookMeta(
      name: 'Philemon',
      chapters: 1,
      verses: 25,
      aliases: ['philem', 'phm'],
      theme: 'Reconciliation in Christ expressed through radical forgiveness.',
    ),
    BookMeta(
      name: 'Hebrews',
      chapters: 13,
      verses: 303,
      aliases: ['heb'],
      theme: 'Jesus as superior High Priest fulfilling the old covenant.',
    ),
    BookMeta(
      name: 'James',
      chapters: 5,
      verses: 108,
      aliases: ['jas', 'jm'],
      theme: 'Authentic faith expressed through wise, compassionate action.',
    ),
    BookMeta(
      name: '1 Peter',
      chapters: 5,
      verses: 105,
      aliases: ['1 pet', '1pe', 'i peter', 'first peter'],
      theme: 'Hope-filled endurance for exiles anchored in Christ\'s victory.',
    ),
    BookMeta(
      name: '2 Peter',
      chapters: 3,
      verses: 61,
      aliases: ['2 pet', '2pe', 'ii peter', 'second peter'],
      theme: 'Growing in grace while resisting false teachers.',
    ),
    BookMeta(
      name: '1 John',
      chapters: 5,
      verses: 105,
      aliases: ['1 jn', '1jo', 'i john', 'first john'],
      theme: 'Assurance of eternal life through love, obedience, and truth.',
    ),
    BookMeta(
      name: '2 John',
      chapters: 1,
      verses: 13,
      aliases: ['2 jn', '2jo', 'ii john', 'second john'],
      theme: 'Walk in love and guard against deceptive teaching.',
    ),
    BookMeta(
      name: '3 John',
      chapters: 1,
      verses: 14,
      aliases: ['3 jn', '3jo', 'iii john', 'third john'],
      theme: 'Support faithful servants of the gospel with hospitality.',
    ),
    BookMeta(
      name: 'Jude',
      chapters: 1,
      verses: 25,
      aliases: ['jud'],
      theme: 'Contend for the faith and rest in God\'s keeping power.',
    ),
    BookMeta(
      name: 'Revelation',
      chapters: 22,
      verses: 404,
      aliases: ['rev', 're'],
      theme:
          'Apocalyptic vision of Christ\'s victory and the renewed creation.',
    ),
  ];
  static final Map<String, BookMeta> _lookup = {
    for (final meta in _bookMetadata)
      for (final alias in <String>{meta.name, ...meta.aliases})
        alias.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''): meta,
  };

  static BookMeta? findByName(String? name) {
    if (name == null || name.isEmpty) return null;
    final normalized = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return _lookup[normalized];
  }

  static BookMeta? findByBook(dynamic book) {
    if (book == null) return null;
    final name = (book['name'] ?? '').toString();
    final longName = (book['nameLong'] ?? '').toString();
    final abbreviation = (book['abbreviation'] ?? '').toString();
    final id = (book['id'] ?? '').toString();

    return findByName(name) ??
        findByName(longName) ??
        findByName(abbreviation) ??
        findByName(id);
  }
}

class BibleController extends GetxController {
  BibleController();

  static const Set<String> _kenyanLanguageIds = {
    'eng',
    'en',
    'swa',
    'sw',
    'kik',
    'kam',
    'luo',
    'guz',
    'luy',
    'lug',
    'mas',
    'mer',
    'nyn',
    'pck',
  };

  var books = <dynamic>[].obs;
  var filteredBooks = <dynamic>[].obs;
  var versions = <dynamic>[].obs;
  var languages = <LanguageOption>[].obs;
  var selectedVersionId = 'de4e12af7f28f599-01'.obs; // Default to KJV
  var selectedLanguage = 'eng'.obs; // Default to English
  var searchQuery = ''.obs;
  var parsedReference = Rxn<BookReference>();
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  final String apiKey =
      '4254c26b3773cd5f5ac8567a0868f944'; // Replace with your actual API key

  @override
  void onInit() {
    super.onInit();
    fetchBibleVersions();
  }

  Future<void> fetchBibleVersions() async {
    final url = Uri.parse('https://api.scripture.api.bible/v1/bibles');

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.get(
        url,
        headers: {'api-key': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        versions.assignAll(data['data'] ?? []);
        _buildLanguageList();
        _syncSelectedVersionWithLanguage();
        await fetchBibleBooks();
      } else {
        throw Exception('Failed to load Bible versions');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load Bible versions. Please try again.';
      isLoading.value = false;
    }
  }

  Future<void> fetchBibleBooks() async {
    final url = Uri.parse(
        'https://api.scripture.api.bible/v1/bibles/${selectedVersionId.value}/books');

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.get(
        url,
        headers: {'api-key': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        books.assignAll(data['data'] ?? []);
        _applyFilters();
        isLoading.value = false;
      } else {
        throw Exception('Failed to load Bible books');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load Bible books. Please try again.';
      isLoading.value = false;
    }
  }

  void changeLanguage(String languageId) {
    if (selectedLanguage.value == languageId) return;

    selectedLanguage.value = languageId;
    _syncSelectedVersionWithLanguage();
    resetSearch();
    fetchBibleBooks();
  }

  void changeVersion(String versionId) {
    if (selectedVersionId.value == versionId) return;

    selectedVersionId.value = versionId;
    fetchBibleBooks();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query.trim();
    _applyFilters();
  }

  void resetSearch() {
    searchQuery.value = '';
    parsedReference.value = null;
    _applyFilters();
  }

  Future<List<dynamic>> fetchChaptersForBook(String bookId) async {
    final url = Uri.parse(
        'https://api.scripture.api.bible/v1/bibles/${selectedVersionId.value}/books/$bookId/chapters');

    final response = await http.get(
      url,
      headers: {'api-key': apiKey},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load chapters');
    }
  }

  Future<void> openReference(dynamic book, BookReference reference) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final chapters = await fetchChaptersForBook(book['id']);

      dynamic targetChapter;
      for (final chapter in chapters) {
        final chapterNumber = int.tryParse(chapter['number'].toString());
        if (chapterNumber == reference.chapter) {
          targetChapter = chapter;
          break;
        }
      }

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (targetChapter != null) {
        Get.to(
          () => ChapterContentScreen(
            chapter: targetChapter,
            versionId: selectedVersionId.value,
          ),
        );
      } else {
        Get.snackbar('Reference not found',
            'Could not locate chapter ${reference.chapter}.');
        Get.to(
          () => ChaptersScreen(
            book: book,
            versionId: selectedVersionId.value,
          ),
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.snackbar('Reference not available',
          'Unable to open the requested passage right now.');
      Get.to(
        () => ChaptersScreen(
          book: book,
          versionId: selectedVersionId.value,
        ),
      );
    }
  }

  List<dynamic> versionsForSelectedLanguage() {
    return versionsForLanguage(selectedLanguage.value);
  }

  List<dynamic> versionsForLanguage(String languageId) {
    return versions
        .where((version) => version['language']?['id'] == languageId)
        .toList();
  }

  dynamic get selectedVersionDetails {
    return versions.firstWhere(
      (version) => version['id'] == selectedVersionId.value,
      orElse: () => null,
    );
  }

  LanguageOption? get selectedLanguageDetails {
    return languages.firstWhere(
      (language) => language.id == selectedLanguage.value,
      orElse: () => const LanguageOption(id: '', name: ''),
    );
  }

  BookMeta? bookMeta(dynamic book) {
    return BookMetadataRepository.findByBook(book);
  }

  void _applyFilters() {
    final rawQuery = searchQuery.value;
    final reference = _parseReference(rawQuery);
    parsedReference.value = reference;

    final normalized = rawQuery.toLowerCase();
    final textPortion = normalized
        .replaceAll(RegExp(r'[0-9:]+'), ' ')
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .join(' ')
        .trim();

    List<dynamic> results = books.toList();

    if (textPortion.isNotEmpty) {
      results = results.where((book) {
        final name = (book['name'] ?? '').toString().toLowerCase();
        final longName = (book['nameLong'] ?? '').toString().toLowerCase();
        final abbreviation =
            (book['abbreviation'] ?? '').toString().toLowerCase();
        final meta = BookMetadataRepository.findByBook(book);
        final controller = Get.find<BibleController>();
        final aliasTarget = textPortion.replaceAll(' ', '');
        final aliasMatch = meta != null &&
            meta.aliases.any(
              (alias) =>
                  alias.toLowerCase().replaceAll(' ', '').contains(aliasTarget),
            );

        return name.contains(textPortion) ||
            longName.contains(textPortion) ||
            abbreviation.contains(textPortion) ||
            aliasMatch;
      }).toList();
    }

    if (reference != null) {
      results = results.where((book) {
        final meta = BookMetadataRepository.findByBook(book);
        return meta?.name.toLowerCase() == reference.bookName.toLowerCase();
      }).toList();
    }

    filteredBooks.assignAll(results);
  }

  BookReference? _parseReference(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return null;

    final regex = RegExp(
      r'^([1-3]?\s*[a-zA-Z]+(?:\s+[a-zA-Z]+)*)\s+(\d+)(?:[:\s]+(\d+))?$',
    );
    final match = regex.firstMatch(trimmed);
    if (match == null) return null;

    final bookPart = match.group(1);
    final chapter = int.tryParse(match.group(2) ?? '');
    final verse = int.tryParse(match.group(3) ?? '');

    if (bookPart == null || chapter == null) return null;

    final meta = BookMetadataRepository.findByName(bookPart);
    if (meta == null) return null;

    return BookReference(
      bookName: meta.name,
      chapter: chapter,
      verse: verse,
    );
  }

  void _buildLanguageList() {
    final Map<String, LanguageOption> uniqueLanguages = {};

    for (final version in versions) {
      final language = version['language'];
      if (language == null) continue;

      final languageId = (language['id'] ?? '').toString();
      if (languageId.isEmpty) continue;

      final normalizedId = languageId.toLowerCase();
      if (!_kenyanLanguageIds.contains(normalizedId)) {
        continue;
      }

      final languageName = (language['name'] ?? '').toString().isNotEmpty
          ? language['name']
          : languageId.toUpperCase();

      uniqueLanguages[normalizedId] = LanguageOption(
        id: normalizedId,
        name: languageName,
      );
    }

    final sortedLanguages = uniqueLanguages.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    if (sortedLanguages.isEmpty) {
      sortedLanguages.add(const LanguageOption(id: 'eng', name: 'English'));
    }

    languages.assignAll(sortedLanguages);

    if (languages.isNotEmpty &&
        !languages.any((language) => language.id == selectedLanguage.value)) {
      selectedLanguage.value = languages.first.id;
    }
  }

  void _syncSelectedVersionWithLanguage() {
    final availableVersions = versionsForLanguage(selectedLanguage.value);

    if (availableVersions.isEmpty) {
      if (versions.isNotEmpty) {
        selectedVersionId.value = versions.first['id'];
      }
      return;
    }

    final hasSelectedVersion = availableVersions
        .any((version) => version['id'] == selectedVersionId.value);

    if (!hasSelectedVersion) {
      selectedVersionId.value = availableVersions.first['id'];
    }
  }
}

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  late final BibleController controller;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<BibleController>()
        ? Get.find<BibleController>()
        : Get.put(BibleController());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Holy Bible'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.12),
              theme.colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return _ErrorState(
                message: controller.errorMessage.value,
                onRetry: controller.fetchBibleVersions,
              );
            }

            return _buildContent(theme);
          }),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(theme),
          const SizedBox(height: 16),
          _buildFilters(theme),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchBibleBooks(),
              child: Obx(() {
                if (controller.filteredBooks.isEmpty) {
                  return _EmptyState(
                    searchActive: controller.searchQuery.value.isNotEmpty,
                  );
                }

                final reference = controller.parsedReference.value;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 720
                        ? 3
                        : constraints.maxWidth > 480
                            ? 2
                            : 1;

                    final hasReference = reference != null;
                    final childAspectRatio = crossAxisCount == 1
                        ? (hasReference ? 2.4 : 3.0)
                        : crossAxisCount == 2
                            ? (hasReference ? 1.3 : 1.4)
                            : 1.2;
                    return GridView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: controller.filteredBooks.length,
                      itemBuilder: (context, index) {
                        final book = controller.filteredBooks[index];
                        final meta = controller.bookMeta(book);
                        return _BookCard(
                          book: book,
                          meta: meta,
                          reference: reference,
                          onTap: () {
                            final currentReference =
                                controller.parsedReference.value;
                            if (currentReference != null &&
                                meta != null &&
                                currentReference.bookName == meta.name) {
                              controller.openReference(book, currentReference);
                            } else {
                              Get.to(
                                () => ChaptersScreen(
                                  book: book,
                                  versionId: controller.selectedVersionId.value,
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    final selectedVersion = controller.selectedVersionDetails;
    final selectedLanguage = controller.selectedLanguageDetails;

    final versionName = (selectedVersion?['name'] ?? 'Bible').toString();
    final languageName = (selectedLanguage?.name ?? '').isNotEmpty
        ? selectedLanguage?.name
        : controller.selectedLanguage.value.toUpperCase();
    final bookCount = controller.filteredBooks.length;

    final reference = controller.parsedReference.value;
    final referenceText = reference == null
        ? null
        : '${reference.bookName} ${reference.chapter}${reference.verse != null ? ':${reference.verse}' : ''}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'God\'s Word for Today',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      versionName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer
                            .withOpacity(0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.language_outlined,
                label: languageName?.toString() ?? 'Language',
                backgroundColor: theme.colorScheme.surface.withOpacity(0.4),
                foregroundColor: theme.colorScheme.onPrimaryContainer,
              ),
              _InfoChip(
                icon: Icons.auto_stories_outlined,
                label: '$bookCount books',
                backgroundColor: theme.colorScheme.surface.withOpacity(0.4),
                foregroundColor: theme.colorScheme.onPrimaryContainer,
              ),
              if (referenceText != null)
                _InfoChip(
                  icon: Icons.search,
                  label: referenceText,
                  backgroundColor: theme.colorScheme.surface.withOpacity(0.4),
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find what you need',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: searchController,
            onChanged: controller.setSearchQuery,
            decoration: InputDecoration(
              labelText:
                  'Search books, chapters, or verses (e.g. Malachi 1 24)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(() {
                return controller.searchQuery.value.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear search',
                        onPressed: () {
                          searchController.clear();
                          controller.resetSearch();
                        },
                      );
              }),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: Obx(() {
              if (controller.languages.isEmpty) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Languages loading…',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.languages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final language = controller.languages[index];
                  final isSelected =
                      language.id == controller.selectedLanguage.value;

                  return ChoiceChip(
                    label: Text(language.name),
                    selected: isSelected,
                    onSelected: (_) => controller.changeLanguage(language.id),
                    showCheckmark: false,
                    labelStyle: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                    selectedColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.4),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final versions = controller.versionsForSelectedLanguage();

            return DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: versions.any((version) =>
                      version['id'] == controller.selectedVersionId.value)
                  ? controller.selectedVersionId.value
                  : (versions.isNotEmpty ? versions.first['id'] : null),
              onChanged: (newValue) {
                if (newValue != null) {
                  controller.changeVersion(newValue);
                }
              },
              items: versions
                  .map<DropdownMenuItem<String>>(
                    (version) => DropdownMenuItem<String>(
                      value: version['id'],
                      child: Text(version['name'] ?? 'Unknown version'),
                    ),
                  )
                  .toList(),
              decoration: InputDecoration(
                labelText: 'Bible version',
                prefixIcon: const Icon(Icons.translate_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.book,
    required this.onTap,
    this.meta,
    this.reference,
  });

  final dynamic book;
  final VoidCallback onTap;
  final BookMeta? meta;
  final BookReference? reference;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final abbreviation = (book['abbreviation'] ?? '').toString();

    final matchesReference = reference != null &&
        meta != null &&
        reference!.bookName.toLowerCase() == meta!.name.toLowerCase();

    final referenceLabel = reference == null
        ? null
        : '${reference!.bookName} ${reference!.chapter}${reference!.verse != null ? ':${reference!.verse}' : ''}';

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.08),
                theme.colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.book_outlined,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (book['name'] ?? 'Untitled').toString(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (abbreviation.isNotEmpty)
                          Text(
                            abbreviation,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              letterSpacing: 1.1,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              if (matchesReference && referenceLabel != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.push_pin_outlined,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        referenceLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (meta != null) ...[
                Text(
                  'Chapters: ${meta!.chapters} • Verses: ${meta!.verses}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    meta!.theme,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied,
                size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.searchActive});

  final bool searchActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<BibleController>();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                searchActive
                    ? Icons.search_off_rounded
                    : Icons.menu_book_outlined,
                size: 60,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(height: 16),
              Text(
                searchActive
                    ? 'No books match your search'
                    : 'Books will appear here',
                style: theme.textTheme.titleMedium,
              ),
              if (searchActive) ...[
                const SizedBox(height: 8),
                Text(
                  'Try a different title or abbreviation.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ChaptersScreen extends StatelessWidget {
  const ChaptersScreen(
      {super.key, required this.book, required this.versionId});

  final dynamic book;
  final String versionId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = BookMetadataRepository.findByBook(book);
    final controller = Get.find<BibleController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(book['name']),
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Column(
        children: [
          if (meta != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    meta.theme,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chapters: ${meta.chapters} | Verses: ${meta.verses}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder(
              future: controller.fetchChaptersForBook(book['id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final chapters = snapshot.data as List<dynamic>;
                  final reference = controller.parsedReference.value;
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: chapters.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final chapter = chapters[index];
                      final chapterNumber =
                          int.tryParse(chapter['number'].toString());
                      final isReferenceChapter = reference != null &&
                          reference.bookName == meta?.name &&
                          reference.chapter == chapterNumber;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              theme.colorScheme.primary.withOpacity(0.12),
                          child: Text(
                            chapter['number'].toString(),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        title: Text('Chapter ${chapter['number']}'),
                        subtitle: isReferenceChapter && reference.verse != null
                            ? Text(
                                'Contains verse ${reference.verse}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
                        trailing: const Icon(Icons.arrow_forward_ios_rounded,
                            size: 16),
                        onTap: () => Get.to(
                          () => ChapterContentScreen(
                            chapter: chapter,
                            versionId: versionId,
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChapterContentScreen extends StatefulWidget {
  const ChapterContentScreen(
      {super.key, required this.chapter, required this.versionId});

  final dynamic chapter;
  final String versionId;

  @override
  State<ChapterContentScreen> createState() => _ChapterContentScreenState();
}

class _ChapterContentScreenState extends State<ChapterContentScreen> {
  List<Map<String, dynamic>> verses = [];
  bool isLoading = true;
  String errorMessage = '';
  Map<int, double> verseScales = {};
  int? zoomedVerseIndex;

  @override
  void initState() {
    super.initState();
    fetchChapterContent();
  }

  Future<void> fetchChapterContent() async {
    final apiKey =
        '4254c26b3773cd5f5ac8567a0868f944'; // Replace with your actual API key
    final url = Uri.parse(
        'https://api.scripture.api.bible/v1/bibles/${widget.versionId}/chapters/${widget.chapter['id']}?content-type=text');

    try {
      final response = await http.get(
        url,
        headers: {'api-key': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] != null && data['data']['content'] != null) {
          final content = data['data']['content'];
          final verseLines = content.toString().split('\n');
          verses = verseLines
              .map((line) {
                final parts = line.split(' ');
                if (parts.isEmpty) return null;

                final verseNumber = parts.first;
                final verseText =
                    parts.length > 1 ? parts.sublist(1).join(' ') : '';

                if (verseText.trim().isEmpty) return null;

                return {
                  'number': verseNumber,
                  'text': verseText,
                };
              })
              .whereType<Map<String, dynamic>>()
              .toList();

          setState(() {
            isLoading = false;
          });
        } else {
          throw Exception('No content found in the response');
        }
      } else {
        throw Exception(
            'Failed to load chapter content. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load chapter content. Error: $e';
      });
    }
  }

  void _handleDoubleTap(int index) {
    setState(() {
      if (zoomedVerseIndex == index) {
        zoomedVerseIndex = null;
        verseScales[index] = 1.0;
      } else {
        zoomedVerseIndex = index;
        verseScales[index] = 1.5;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final reference = Get.find<BibleController>().parsedReference.value;
    final highlightedVerse = reference?.verse;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter ${widget.chapter['number']}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      errorMessage,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: verses.length,
                  itemBuilder: (context, index) {
                    final verse = verses[index];
                    final verseNumber = verse['number'];
                    final isReferenceVerse = highlightedVerse != null &&
                        highlightedVerse.toString() == verseNumber;
                    final isZoomed = zoomedVerseIndex == index;
                    final scale = verseScales[index] ?? 1.0;

                    return GestureDetector(
                      onDoubleTap: () => _handleDoubleTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.all(16),
                        margin: EdgeInsets.symmetric(
                          vertical: isZoomed ? 14 : 6,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isReferenceVerse
                              ? theme.colorScheme.primaryContainer
                                  .withOpacity(0.8)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: isZoomed ? 16 : 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Transform.scale(
                          scale: scale,
                          alignment: Alignment.topLeft,
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(height: 1.4),
                              children: [
                                TextSpan(
                                  text: '$verseNumber ',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isReferenceVerse
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.primary,
                                  ),
                                ),
                                TextSpan(
                                  text: verse['text'],
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: isReferenceVerse
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
