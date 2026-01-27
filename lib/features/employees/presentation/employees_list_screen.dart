import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/app_theme/app_theme.dart';
import '../data/provider/employee_provider.dart';
import '../../dashboard/presentation/widgets/fade_slide_item.dart';

class EmployeesListScreen extends ConsumerStatefulWidget {
  const EmployeesListScreen({super.key});

  @override
  ConsumerState<EmployeesListScreen> createState() => _EmployeesListScreenState();
}

class _EmployeesListScreenState extends ConsumerState<EmployeesListScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employeesProvider.notifier).loadEmployees();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _controller.reset();
    _controller.forward();
    await ref.read(employeesProvider.notifier).loadEmployees();
  }

  @override
  Widget build(BuildContext context) {
    final employeesState = ref.watch(employeesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Team Members"),
        centerTitle: true,
      ),
      body: employeesState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.PrimaryColor),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Error: ${e.toString()}"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refresh,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
        data: (response) {
          final employees = response?.data.data ?? [];
          if (employees.isEmpty) {
            return const Center(child: Text("No team members found"));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppTheme.PrimaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final employee = employees[index];
                final delay = (index * 0.05).clamp(0.0, 0.5);

                return FadeSlideItem(
                  animation: _controller,
                  intervalStart: delay,
                  child: GestureDetector(
                    onTap: () => context.pushNamed(
                      'employee_dashboard',
                      extra: employee,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.PrimaryColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppTheme.PrimaryColor.withValues(alpha: 0.1),
                            child: Text(
                              employee.name.isNotEmpty ? employee.name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: AppTheme.PrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        employee.name,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.PrimaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        employee.employeeCode,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: AppTheme.PrimaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.work_outline,
                                      size: 14,
                                      color: AppTheme.PrimaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        employee.designation,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.storefront_outlined,
                                      size: 14,
                                      color: AppTheme.PrimaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        employee.store,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
        },
      ),
    );
  }
}
