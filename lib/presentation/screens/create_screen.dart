import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../domain/models/category.dart';
import '../../domain/models/listing.dart';
import '../../domain/services/local_ai_service.dart';
import '../../repository/listing_repository.dart';
import '../theme/blinkit_theme.dart';

class CreateScreen extends StatefulWidget {
  final ListingRepository repository;
  final LocalAiService aiService;

  const CreateScreen({
    super.key,
    required this.repository,
    required this.aiService,
  });

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _rawAiInputController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'food';
  ListingType _selectedType = ListingType.offer;
  String _selectedArea = AppConfig.allowedSubLocalities.first;
  ContactPreference _selectedContact = ContactPreference.whatsapp;

  bool _isAiSuggesting = false;
  bool _aiGenerated = false;

  Map<String, String> _validationErrors = {};

  @override
  void dispose() {
    _rawAiInputController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _runAiSuggest() async {
    final rawText = _rawAiInputController.text.trim().isNotEmpty
        ? _rawAiInputController.text.trim()
        : _titleController.text.trim();

    if (rawText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a short title or phrase first for AI suggestion')),
      );
      return;
    }

    setState(() => _isAiSuggesting = true);

    try {
      final suggestion = await widget.aiService.suggestListingDetails(rawText);
      setState(() {
        if (_titleController.text.isEmpty) {
          _titleController.text = suggestion.title;
        }
        if (suggestion.categoryId.isNotEmpty && suggestion.categoryId != 'other') {
          _selectedCategory = suggestion.categoryId;
        }
        _descriptionController.text = suggestion.description;
        _aiGenerated = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✨ AI suggestion applied! You can review and edit it below.'),
            backgroundColor: BlinkitTheme.blinkitGreen,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAiSuggesting = false);
    }
  }

  Future<void> _submitForm() async {
    setState(() => _validationErrors.clear());

    final draft = Listing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      categoryId: _selectedCategory,
      type: _selectedType,
      description: _descriptionController.text.trim(),
      area: _selectedArea,
      contactPreference: _selectedContact,
      aiGenerated: _aiGenerated,
    );

    // Step 1: Input Validation
    final valResult = draft.validate();
    if (!valResult.isValid) {
      setState(() => _validationErrors = valResult.errors);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix ${valResult.errors.length} form error(s) below'),
          backgroundColor: BlinkitTheme.zomatoRed,
        ),
      );
      return;
    }

    // Step 2: AI Safety Helper Check
    final safetyResult = await widget.aiService.checkListingSafety(draft);
    if (safetyResult.isRisky && mounted) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.security, color: BlinkitTheme.zomatoRed),
              SizedBox(width: 8),
              Text('Privacy Warning'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(safetyResult.warningMessage ?? 'Sensitive data detected in draft:'),
              const SizedBox(height: 8),
              ...safetyResult.detectedIssues.map((issue) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $issue', style: const TextStyle(color: BlinkitTheme.zomatoRed, fontWeight: FontWeight.bold)),
                  )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Edit Draft'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: BlinkitTheme.zomatoRed),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Acknowledge & Post', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    // Step 3: Save to Repository
    try {
      await widget.repository.save(draft);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing posted successfully to Bandra West!'),
            backgroundColor: BlinkitTheme.blinkitGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save listing: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '➕ Create Listing',
          style: TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w800,
            fontSize: textScaler.scale(18),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Helper Section Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BlinkitTheme.blinkitYellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: BlinkitTheme.blinkitYellow),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('✨', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 6),
                        Text(
                          'AI Description Helper',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: Color(0xFF0C831F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _rawAiInputController,
                      decoration: const InputDecoration(
                        hintText: 'Type a quick phrase (e.g. "homemade mango pickle, spicy")',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BlinkitTheme.blinkitYellow,
                        foregroundColor: const Color(0xFF0C831F),
                        minimumSize: const Size(48, 48),
                      ),
                      onPressed: _isAiSuggesting ? null : _runAiSuggest,
                      icon: _isAiSuggesting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0C831F)),
                            )
                          : const Icon(Icons.auto_awesome, size: 18),
                      label: Text(
                        _isAiSuggesting ? 'Generating...' : 'Auto-Suggest Description',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Title Field
              _buildSectionLabel('Listing Title *'),
              Semantics(
                label: 'Listing title text field',
                textField: true,
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Home-cooked Maharashtrian Tiffin Packs',
                    border: const OutlineInputBorder(),
                    errorText: _validationErrors['title'],
                  ),
                ),
              ),
              _buildInlineError('title'),

              const SizedBox(height: 16),

              // Category Dropdown
              _buildSectionLabel('Category *'),
              Semantics(
                label: 'Select category dropdown',
                button: true,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: ListingCategory.all.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Text('${cat.icon} ${cat.name}'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
              _buildInlineError('category'),

              const SizedBox(height: 16),

              // Type Selector (Offer vs Request)
              _buildSectionLabel('Listing Type'),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<ListingType>(
                      title: const Text('📤 Offer', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      value: ListingType.offer,
                      groupValue: _selectedType,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedType = val);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<ListingType>(
                      title: const Text('📥 Request', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      value: ListingType.request,
                      groupValue: _selectedType,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedType = val);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Description Field
              _buildSectionLabel('Description *'),
              Semantics(
                label: 'Description text field',
                textField: true,
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Describe details, condition, availability...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              _buildInlineError('description'),

              const SizedBox(height: 16),

              // Coarse Area Selector Dropdown (Never exact address!)
              _buildSectionLabel('Neighborhood Sub-Locality * (Privacy Protected)'),
              Semantics(
                label: 'Select neighborhood coarse sub-locality dropdown',
                button: true,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedArea,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    helperText: 'Select general zone — exact street addresses are prohibited for privacy.',
                  ),
                  items: AppConfig.allowedSubLocalities.map((area) {
                    return DropdownMenuItem(
                      value: area,
                      child: Text('📍 $area'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedArea = val);
                  },
                ),
              ),
              _buildInlineError('area'),

              const SizedBox(height: 16),

              // Contact Preference Dropdown
              _buildSectionLabel('Contact Preference'),
              DropdownButtonFormField<ContactPreference>(
                initialValue: _selectedContact,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: ContactPreference.whatsapp, child: Text('📱 Chat on WhatsApp')),
                  DropdownMenuItem(value: ContactPreference.call, child: Text('📞 Direct Call')),
                  DropdownMenuItem(value: ContactPreference.inAppNote, child: Text('💬 In-App Note')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedContact = val);
                },
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BlinkitTheme.blinkitGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _submitForm,
                  icon: const Icon(Icons.check_circle, size: 22),
                  label: Text(
                    'Post to Bandra West',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontWeight: FontWeight.w900,
                      fontSize: textScaler.scale(16),
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

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Sora',
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
    );
  }

  // Visible inline error message with Icon + text (Not color-only!)
  Widget _buildInlineError(String field) {
    final msg = _validationErrors[field];
    if (msg == null || msg.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: BlinkitTheme.zomatoRed),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(
                color: BlinkitTheme.zomatoRed,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
