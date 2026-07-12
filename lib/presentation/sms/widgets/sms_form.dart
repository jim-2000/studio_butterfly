import 'package:flutter/material.dart';

import '../../../core/theme/app_dimens.dart';

/// Reusable SMS send form. Pure widget — no repository/provider access
/// here. The parent screen owns send state and passes [isSending]/
/// [errorMessage] in; submissions come back out through [onSubmit]. That
/// split is what makes this independently widget-testable (pump with
/// different prop values, no ProviderScope needed).
class SmsForm extends StatefulWidget {
  const SmsForm({
    super.key,
    required this.isSending,
    required this.onSubmit,
    this.errorMessage,
  });

  final bool isSending;
  final String? errorMessage;
  final Future<void> Function(String to, String body) onSubmit;

  @override
  State<SmsForm> createState() => _SmsFormState();
}

class _SmsFormState extends State<SmsForm> {
  static final RegExp _e164 = RegExp(r'^\+[1-9]\d{6,14}$');

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter a phone number';
    if (!_e164.hasMatch(trimmed)) return 'Use E.164 format, e.g. +4915112345678';
    return null;
  }

  String? _validateBody(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter a message';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await widget.onSubmit(_phoneController.text.trim(), _bodyController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            textField: true,
            label: 'Recipient phone number, E.164 format',
            child: TextFormField(
              controller: _phoneController,
              enabled: !widget.isSending,
              keyboardType: TextInputType.phone,
              autofillHints: const [AutofillHints.telephoneNumber],
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: '+4915112345678',
                prefixIcon: Icon(Icons.call_outlined),
              ),
              validator: _validatePhone,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Semantics(
            textField: true,
            label: 'Message body',
            child: TextFormField(
              controller: _bodyController,
              enabled: !widget.isSending,
              minLines: 3,
              maxLines: 5,
              maxLength: 480,
              decoration: const InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
              ),
              validator: _validateBody,
            ),
          ),
          if (widget.errorMessage case final message?) ...[
            const SizedBox(height: AppSpacing.xs),
            Semantics(
              liveRegion: true,
              child: Text(message, style: TextStyle(color: colorScheme.error)),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: AppSpacing.minTapTarget,
            child: FilledButton.icon(
              onPressed: widget.isSending ? null : _submit,
              icon: widget.isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(widget.isSending ? 'Sending…' : 'Send SMS'),
            ),
          ),
        ],
      ),
    );
  }
}
