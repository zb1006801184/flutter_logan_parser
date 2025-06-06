import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/logan_log_item.dart';
import '../models/app_state.dart';
import '../providers/logan_provider.dart';
import '../widgets/common_widgets.dart';
import '../widgets/log_item_widget.dart';
import '../theme/app_theme.dart';

/// Logan 日志解析页面
class LogDecodePage extends ConsumerStatefulWidget {
  const LogDecodePage({super.key});

  @override
  ConsumerState<LogDecodePage> createState() => _LogDecodePageState();
}

class _LogDecodePageState extends ConsumerState<LogDecodePage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = '';

  /// 保持页面活跃状态
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final keyword = _searchController.text;
    ref
        .read(appStateProvider.notifier)
        .searchAndFilter(ref, keyword, _selectedFilter);
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    final keyword = _searchController.text;
    ref.read(appStateProvider.notifier).searchAndFilter(ref, keyword, filter);
  }

  @override
  Widget build(BuildContext context) {
    // 调用父类build方法以保持页面活跃
    super.build(context);
    
    final appState = ref.watch(appStateProvider);
    final filteredLogData = ref.watch(filteredLogDataProvider);
    final selectedLogItem = ref.watch(selectedLogItemProvider);

    return Scaffold(
      body: Column(
        children: [
          // 搜索和筛选栏
          if (appState is LogDecodeSuccessState ||
              appState is LogSearchEmptyState)
            _buildSearchAndFilterBar(),

          // 主要内容区域
          Expanded(
            child: _buildMainContent(
              appState,
              filteredLogData,
              selectedLogItem,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingAddButton(
        onPressed: () {
          ref.read(appStateProvider.notifier).pickAndParseLogFile(ref, context);
        },
      ),
    );
  }

  /// 构建搜索和筛选栏
  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        children: [
          // 搜索框
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '请输入需要搜索的内容',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // 筛选下拉框
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<String>(
              value: _selectedFilter.isEmpty ? null : _selectedFilter,
              hint: const Text('全部日志'),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              items:
                  FilterOption.options.map((option) {
                    return DropdownMenuItem<String>(
                      value: option.key,
                      child: Text(option.displayName),
                    );
                  }).toList(),
              onChanged: (value) {
                _onFilterChanged(value ?? '');
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建主要内容
  Widget _buildMainContent(
    AppUIState appState,
    List<LoganLogItem> filteredLogData,
    LoganLogItem? selectedLogItem,
  ) {
    switch (appState) {
      case LogDecodeLoadingState _:
        return const LoadingWidget(message: '正在解析日志文件...');

      case LogDecodeFailState _:
        final failState = appState;
        return ErrorStateWidget(
          message: failState.errorMessage,
          actionText: '重新选择文件',
          onActionPressed: () {
            ref
                .read(appStateProvider.notifier)
                .pickAndParseLogFile(ref, context);
          },
        );

      case LogDecodeSuccessState _:
      case LogSearchEmptyState _:
        if (filteredLogData.isEmpty) {
          final isEmpty = appState is LogSearchEmptyState;
          return EmptyStateWidget(
            message: isEmpty ? '未找到匹配的日志' : '请选择Logan日志文件开始解析',
            icon: isEmpty ? Icons.search_off : Icons.file_upload_outlined,
            actionText: isEmpty ? '清空搜索' : '选择文件',
            onActionPressed: () {
              if (isEmpty) {
                _searchController.clear();
                _onFilterChanged('');
              } else {
                ref
                    .read(appStateProvider.notifier)
                    .pickAndParseLogFile(ref, context);
              }
            },
          );
        }

        return Row(
          children: [
            // 日志列表
            Expanded(
              flex: 3,
              child: _buildLogList(filteredLogData, selectedLogItem),
            ),

            // 日志详情
            Expanded(flex: 2, child: _buildLogDetail(selectedLogItem)),
          ],
        );

      default:
        return const EmptyStateWidget(
          message: '请选择Logan日志文件开始解析',
          icon: Icons.file_upload_outlined,
        );
    }
  }

  /// 构建日志列表
  Widget _buildLogList(List<LoganLogItem> logData, LoganLogItem? selectedItem) {
    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: AppTheme.borderColor)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.xs),
        itemCount: logData.length,
        itemBuilder: (context, index) {
          final logItem = logData[index];
          final isSelected = selectedItem == logItem;

          return LogItemWidget(
            logItem: logItem,
            isSelected: isSelected,
            onTap: () {
              ref.read(appStateProvider.notifier).selectLogItem(ref, logItem);
            },
          );
        },
      ),
    );
  }

  /// 构建日志详情
  Widget _buildLogDetail(LoganLogItem? selectedItem) {
    if (selectedItem == null) {
      return const EmptyStateWidget(
        message: '请选择一条日志查看详情',
        icon: Icons.article_outlined,
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Text(
              '日志详情',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 日志时间
            _buildDetailItem(
              '日志时间',
              selectedItem.logTime ?? '未知',
              Icons.access_time,
            ),

            // 日志类型
            _buildDetailItem(
              '日志类型',
              selectedItem.logTypeDescription,
              Icons.category_outlined,
            ),

            // 线程名称
            _buildDetailItem(
              '线程名称',
              selectedItem.threadName ?? '未知',
              Icons.account_tree_outlined,
            ),

            // 线程ID
            _buildDetailItem('线程ID', selectedItem.threadId ?? '未知', Icons.tag),

            // 是否主线程
            _buildDetailItem(
              '是否主线程',
              selectedItem.isMainThread == 'true' ? '是' : '否',
              Icons.timeline,
            ),

            // 日志内容
            _buildDetailItem(
              '日志内容',
              selectedItem.content ?? '无内容',
              Icons.description_outlined,
              isContent: true,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建详情项
  Widget _buildDetailItem(
    String title,
    String content,
    IconData icon, {
    bool isContent = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primaryColor),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: Theme.of(context).textTheme.logDetailTitle),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Text(
              content,
              style:
                  isContent
                      ? Theme.of(context).textTheme.logDetailContent.copyWith(
                        fontFamily: 'monospace',
                      )
                      : Theme.of(context).textTheme.logDetailContent,
            ),
          ),
        ],
      ),
    );
  }
}
