import 'package:flutter/material.dart';

import '../models/client.dart';
import '../models/milestone.dart';
import '../models/payment.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  List<Client> get clients => [
        Client(
          name: 'Studio Puncto',
          project: 'Brand identity refresh',
          status: 'В производстве',
          budget: 4800,
          deadline: DateTime(2024, 11, 14),
        ),
        Client(
          name: 'Lunar Cafe',
          project: 'Меню и упаковка',
          status: 'Концепт',
          budget: 2100,
          deadline: DateTime(2024, 10, 30),
        ),
        Client(
          name: 'Nova Interiors',
          project: 'Digital презентация',
          status: 'Финализация',
          budget: 3200,
          deadline: DateTime(2024, 11, 22),
        ),
      ];

  List<Milestone> get milestones => [
        Milestone(
          title: 'Утверждение moodboard',
          client: 'Studio Puncto',
          dueDate: DateTime(2024, 10, 18),
          progress: 0.72,
        ),
        Milestone(
          title: 'Прототип лендинга',
          client: 'Nova Interiors',
          dueDate: DateTime(2024, 10, 24),
          progress: 0.48,
        ),
      ];

  List<Payment> get payments => [
        Payment(
          client: 'Lunar Cafe',
          amount: 900,
          date: DateTime(2024, 10, 12),
          stage: 'Аванс',
        ),
        Payment(
          client: 'Studio Puncto',
          amount: 1400,
          date: DateTime(2024, 10, 8),
          stage: 'Спринт 1',
        ),
        Payment(
          client: 'Nova Interiors',
          amount: 700,
          date: DateTime(2024, 10, 5),
          stage: 'Исследование',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Доброе утро, Аня',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Держим фокус на ключевых этапах проектов',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.25,
            children: const [
              StatCard(
                title: 'Активные проекты',
                value: '6',
                subtitle: '+2 за месяц',
                icon: Icons.auto_graph,
                color: Color(0xFF4F46E5),
              ),
              StatCard(
                title: 'Бюджет в работе',
                value: '€18 400',
                subtitle: '75% собрано',
                icon: Icons.account_balance_wallet_outlined,
                color: Color(0xFF10B981),
              ),
              StatCard(
                title: 'Дедлайны недели',
                value: '3',
                subtitle: '2 в риске',
                icon: Icons.timer_outlined,
                color: Color(0xFFF59E0B),
              ),
              StatCard(
                title: 'Платежи ожидаются',
                value: '€4 200',
                subtitle: 'След. 5 дней',
                icon: Icons.payments_outlined,
                color: Color(0xFFEC4899),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const SectionHeader(title: 'Этапы и дедлайны', actionLabel: 'Смотреть все'),
          const SizedBox(height: 12),
          ...milestones.map(
            (milestone) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            milestone.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        Text(
                          _formatDate(milestone.dueDate),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      milestone.client,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: LinearProgressIndicator(
                        value: milestone.progress,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Платежи', actionLabel: 'Экспорт'),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ...payments.map(
                  (payment) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(
                        Icons.payments,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(payment.client),
                    subtitle: Text('${payment.stage} • ${_formatDate(payment.date)}'),
                    trailing: Text(
                      '€${payment.amount.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Всего за октябрь',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '€3 000',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'Клиенты', actionLabel: 'Добавить'),
          const SizedBox(height: 12),
          ...clients.map(
            (client) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                title: Text(client.name),
                subtitle: Text(client.project),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '€${client.budget.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      client.status,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Новый проект'),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
  }
}
