import 'dart:js' as js;

import 'package:apple_required_reasons_api_generator/required_apis.dart';
import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog(this.reason, {super.key});

  final RequiredReasonApi reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      content: SingleChildScrollView(
        child: SelectionArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.link),
                    onPressed: () => js.context.callMethod(
                      'open',
                      [reason.url],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      reason.key,
                      style: theme.textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(reason.description),
              const SizedBox(height: 20),
              Text(
                'Relevant APIs:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              ...reason.relevantApis.map(Text.new),
            ],
          ),
        ),
      ),
    );
  }
}
