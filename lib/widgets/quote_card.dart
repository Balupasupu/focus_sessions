import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/quote_provider.dart';

// The daily quote on the Home Screen, with a refresh button.
class QuoteCard extends StatelessWidget {
  const QuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuoteProvider>();
    final quote = provider.quote;

    // Before the first fetch starts there is nothing to show. The app
    // starts the fetch right away, so users do not see this state.
    if (!provider.isLoading && quote == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: scheme.primaryContainer,
                child: Icon(
                  Icons.format_quote_rounded,
                  size: 20,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Daily Quote',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              // Disabled while a request is running.
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'New quote',
                onPressed: provider.isLoading
                    ? null
                    : () => context.read<QuoteProvider>().fetchQuote(),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 12),
            child: provider.isLoading || quote == null
                ? const _LoadingRow()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quote.text,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '— ${quote.author}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: scheme.primary,
                        ),
                      ),
                      if (provider.isFallback) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Offline quote',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        const SizedBox(width: 12),
        Text(
          'Loading quote…',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
