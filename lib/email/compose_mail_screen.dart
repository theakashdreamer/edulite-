import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'entity/mail_draft.dart';


class ComposeMailScreen extends StatefulWidget {
  const ComposeMailScreen({super.key});

  @override
  State<ComposeMailScreen> createState() => _ComposeMailScreenState();
}

class _ComposeMailScreenState extends State<ComposeMailScreen> {
  final _toController = TextEditingController();
  final _subjectController = TextEditingController();

  late QuillController _quillController;
  bool _isLoading = true;

  final String fromEmail = "akash.tsscommunity@gmail.com";

  @override
  void initState() {
    super.initState();
    _initDraft();
  }

  /// ✅ Proper async restore
  Future<void> _initDraft() async {
    final draft = await DraftRepository.loadDraft();

    if (draft != null) {
      final delta = Delta.fromJson(draft.delta);

      _quillController = QuillController(
        document: Document.fromDelta(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );

      _toController.text = draft.to;
      _subjectController.text = draft.subject;
    } else {
      _quillController = QuillController.basic();
    }

    _quillController.addListener(_autoSaveDraft);

    setState(() => _isLoading = false);
  }

  /// ✅ Autosave draft (Delta-first)
  void _autoSaveDraft() {
    final draft = MailDraft(
      from: fromEmail,
      to: _toController.text,
      subject: _subjectController.text,
      delta: _quillController.document.toDelta().toJson(),
      updatedAt: DateTime.now(),
    );

    DraftRepository.saveDraft(draft);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _onSend,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _row("From", fromEmail),
          _field("To", _toController),
          _field("Subject", _subjectController),
          const Divider(height: 1),

          /// ✅ Correct toolbar for Quill 11
          QuillSimpleToolbar(
            controller: _quillController,
            config:  QuillSimpleToolbarConfig(),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: QuillEditor.basic(
                controller: _quillController,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _field(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 16),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  /// ✅ Send + clear draft
  Future<void> _onSend() async {
    final draft = await DraftRepository.loadDraft();
    debugPrint("SEND MAIL → ${draft?.toMap()}");

    await DraftRepository.clearDraft();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _quillController.removeListener(_autoSaveDraft);
    _quillController.dispose();
    _toController.dispose();
    _subjectController.dispose();
    super.dispose();
  }
}
