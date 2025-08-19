import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:manage_transaction_app/core/constants/app_extensions.dart';
import 'package:manage_transaction_app/core/utils/functions.dart';
import 'package:manage_transaction_app/features/transactions/domain/entities/transaction_entity.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:manage_transaction_app/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:manage_transaction_app/features/transactions/presentation/widgets/transaction_detail_modal.dart';
import 'package:manage_transaction_app/features/design_system/inpust.dart';
import 'package:manage_transaction_app/features/transactions/presentation/widgets/transaction_modal_form.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _searchQuery = '';
  bool _isGridView = false;
  StatusTransaction? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionBloc>().add(TransactionsWatchRequested());
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    context.read<TransactionBloc>().add(TransactionsStopWatching());
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (context.isDesktop) {
          return _buildDesktopView(state);
        } else if (context.isTablet) {
          return _buildTabletView(state);
        } else {
          return _buildMobileView(state);
        }
      },
    );
  }

  Widget _buildDesktopView(TransactionState state) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildDesktopHeader(),
            _buildSubHeader(state),
            _buildFiltersBar(),
            Expanded(child: _buildDesktopContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletView(TransactionState state) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildTabletHeader(),
            _buildSubHeader(state),
            _buildFiltersBar(),
            Expanded(child: _buildTabletContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileView(TransactionState state) {
    return Scaffold(
      floatingActionButton: _buildFloatingActionButton(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMobileHeader(),
            const SizedBox(height: 8),
            _buildTextTotalTransactions(state),
            _buildFiltersBar(),
            Expanded(child: _buildMobileContent(state)),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primary,
            context.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildHeaderIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHeaderTitles(titleSize: 28, subtitleSize: 16),
                ),
                _buildViewToggleButton(),
                const SizedBox(width: 16),
                SizedBox(
                  width: 350,
                  child: _buildSearchBar(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primary,
            context.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildHeaderIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHeaderTitles(titleSize: 26, subtitleSize: 15),
                ),
                _buildViewToggleButton(),
              ],
            ),
            const SizedBox(height: 20),
            _buildSearchBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.primary,
            context.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildHeaderIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHeaderTitles(titleSize: 24, subtitleSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSearchBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.onPrimary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        HugeIcons.strokeRoundedExchange03,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildHeaderTitles({required double titleSize, required double subtitleSize}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestión de Transacciones',
          style: context.titleLarge.copyWith(
            color: context.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Administra y controla las transacciones del sistema',
          style: context.bodyMedium.copyWith(
            color: context.onPrimary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildViewToggleButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          _isGridView = !_isGridView;
        });
      },
      icon: Icon(
        _isGridView 
            ? HugeIcons.strokeRoundedMenu02 
            : HugeIcons.strokeRoundedGrid,
        color: Colors.white,
      ),
      tooltip: _isGridView ? 'Vista de Lista' : 'Vista de Rejilla',
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: context.onPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.onPrimary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        style: context.bodyMedium.copyWith(
          color: context.onPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar transacciones...',
          hintStyle: context.bodyMedium.copyWith(
            color: context.onPrimary.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            HugeIcons.strokeRoundedSearch01,
            color: context.onPrimary.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersBar() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.isDesktop ? 24 : 16,
        vertical: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusFilter(null, 'Todos'),
                  const SizedBox(width: 8),
                  _buildStatusFilter(StatusTransaction.pending, 'Pendientes'),
                  const SizedBox(width: 8),
                  _buildStatusFilter(StatusTransaction.approved, 'Aprobadas'),
                  const SizedBox(width: 8),
                  _buildStatusFilter(StatusTransaction.rejected, 'Rechazadas'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(StatusTransaction? status, String label) {
    final isSelected = _selectedStatusFilter == status;
    final color = _getStatusColor(status);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatusFilter = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: context.bodySmall.copyWith(
            color: isSelected ? Colors.white : color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSubHeader(TransactionState state) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.isDesktop ? 24 : 16,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTextTotalTransactions(state),
          _buildButtonCreateTransaction(),
        ],
      ),
    );
  }

  Widget _buildTextTotalTransactions(TransactionState state) {
    if (state is TransactionsLoaded) {
      final filteredTransactions = _getFilteredTransactions(state.transactions);
      return Text(
        'Total de transacciones: ${filteredTransactions.length}',
        style: context.titleMedium.copyWith(
          fontWeight: FontWeight.w700,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildButtonCreateTransaction() {
    return SizedBox(
      width: context.isMobile ? 120 : 240,
      child: CustomButton(
        label: 'Crear transacción',
        leading: Icon(HugeIcons.strokeRoundedAdd01, color: context.onPrimary),
        margin: const EdgeInsets.only(top: 16, right: 16),
        onTap: () => ModalHelper.showTransactionFormModal(context),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => ModalHelper.showTransactionFormModal(context),
      tooltip: 'Crear transacción',
      child: const Icon(HugeIcons.strokeRoundedAdd01),
    );
  }

  Widget _buildDesktopContent(TransactionState state) {
    if (state is TransactionLoading) return _buildLoadingState();
    if (state is TransactionError) return _buildErrorState(state.message);

    if (state is TransactionsLoaded) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: _isGridView 
            ? _buildTransactionsGrid(state.transactions, crossAxisCount: 3, childAspectRatio: 1.2)
            : _buildTransactionsList(state.transactions, itemPadding: 8),
      );
    }

    return _buildDefaultState();
  }

  Widget _buildTabletContent(TransactionState state) {
    if (state is TransactionLoading) return _buildLoadingState();
    if (state is TransactionError) return _buildErrorState(state.message);

    if (state is TransactionsLoaded) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: _isGridView 
            ? _buildTransactionsGrid(state.transactions, crossAxisCount: 2, childAspectRatio: 1.1)
            : _buildTransactionsList(state.transactions, itemPadding: 6),
      );
    }

    return _buildDefaultState();
  }

  Widget _buildMobileContent(TransactionState state) {
    if (state is TransactionLoading) return _buildLoadingState();
    if (state is TransactionError) return _buildErrorState(state.message);

    if (state is TransactionsLoaded) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: _buildTransactionsList(state.transactions, itemPadding: 4),
      );
    }

    return _buildDefaultState();
  }

  Widget _buildTransactionsGrid(List<dynamic> transactions, {required int crossAxisCount, required double childAspectRatio}) {
    final filteredTransactions = _getFilteredTransactions(transactions);

    if (filteredTransactions.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(filteredTransactions[index], isCompact: true);
      },
    );
  }

  Widget _buildTransactionsList(List<dynamic> transactions, {required double itemPadding}) {
    final filteredTransactions = _getFilteredTransactions(transactions);

    if (filteredTransactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(filteredTransactions[index], isCompact: false);
      },
    );
  }

  Widget _buildTransactionCard(TransactionEntity transaction, {required bool isCompact}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(
        horizontal: context.isDesktop ? 8 : 4,
        vertical: 6,
      ),
      child: Card(
        elevation: 2,
        shadowColor: context.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showTransactionDetails(transaction),
          child: Container(
            padding: EdgeInsets.all(isCompact ? 12 : 16),
            child: isCompact 
                ? _buildCompactTransactionContent(transaction) 
                : _buildFullTransactionContent(transaction),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactTransactionContent(TransactionEntity transaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                transaction.title,
                style: context.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildStatusChip(transaction.status),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          transaction.concept,
          style: context.bodySmall.copyWith(
            color: context.secondary.withValues(alpha: 0.7),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${transaction.amount.toStringAsFixed(2)}',
              style: context.titleMedium.copyWith(
                color: context.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              Utils.formatDate(transaction.createdAt),
              style: context.bodySmall.copyWith(
                color: context.secondary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFullTransactionContent(TransactionEntity transaction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: context.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.concept,
                    style: context.bodyMedium.copyWith(
                      color: context.secondary.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildStatusChip(transaction.status),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedArrowRight02,
                        size: 16,
                        color: context.primary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${transaction.origin} → ${transaction.destination}',
                        style: context.bodySmall.copyWith(
                          color: context.secondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedCalendar03,
                        size: 16,
                        color: context.primary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Utils.formatDate(transaction.createdAt),
                        style: context.bodySmall.copyWith(
                          color: context.secondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '\$${transaction.amount.toStringAsFixed(2)}',
              style: context.titleLarge.copyWith(
                color: context.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(StatusTransaction status) {
    final color = _getStatusColor(status);
    final text = _getStatusText(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: context.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.surface.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              HugeIcons.strokeRoundedSearchRemove,
              size: 48,
              color: context.secondary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron transacciones',
            style: context.titleMedium.copyWith(
              color: context.secondary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty && _selectedStatusFilter == null
                ? 'No hay transacciones registradas en el sistema'
                : 'Intenta con otros filtros de búsqueda',
            style: context.bodySmall.copyWith(
              color: context.secondary.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: context.primary.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(context.primary),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Cargando transacciones...',
            style: context.titleMedium.copyWith(
              color: context.secondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(context.isDesktop ? 32 : 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.error.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                HugeIcons.strokeRoundedAlert02,
                size: 32,
                color: context.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar transacciones',
              style: context.titleMedium.copyWith(
                color: context.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: context.bodySmall.copyWith(
                color: context.secondary.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TransactionBloc>().add(GetTransactionsRequested());
              },
              icon: const Icon(HugeIcons.strokeRoundedRefresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.surface.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              HugeIcons.strokeRoundedExchange03,
              size: 48,
              color: context.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Módulo de Transacciones',
            style: context.titleMedium.copyWith(
              color: context.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sistema en desarrollo',
            style: context.bodySmall.copyWith(
              color: context.secondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  List<TransactionEntity> _getFilteredTransactions(List<dynamic> transactions) {
    return transactions.where((transaction) {
      final matchesSearch = transaction.title.toLowerCase().contains(_searchQuery) ||
                           transaction.concept.toLowerCase().contains(_searchQuery) ||
                           transaction.origin.toLowerCase().contains(_searchQuery) ||
                           transaction.destination.toLowerCase().contains(_searchQuery);
      
      final matchesStatus = _selectedStatusFilter == null || 
                           transaction.status == _selectedStatusFilter;
      
      return matchesSearch && matchesStatus;
    }).cast<TransactionEntity>().toList();
  }

  Color _getStatusColor(StatusTransaction? status) {
    return switch (status) {
      StatusTransaction.pending => const Color(0xFFF59E0B),
      StatusTransaction.approved => const Color(0xFF10B981),
      StatusTransaction.rejected => const Color(0xFFEF4444),
      null => context.primary,
    };
  }

  String _getStatusText(StatusTransaction status) {
    return switch (status) {
      StatusTransaction.pending => 'Pendiente',
      StatusTransaction.approved => 'Aprobada',
      StatusTransaction.rejected => 'Rechazada',
    };
  }

  void _showTransactionDetails(TransactionEntity transaction) {
    ModalHelper.showTransactionDetailModal(context, transaction);
  }
}

class ModalHelper {
  static Future<void> showTransactionFormModal(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext dialogContext) {
        return BlocProvider<TransactionBloc>.value(
          value: context.read<TransactionBloc>(),
          child: const TransactionFormModal(),
        );
      },
    );
  }

  static Future<void> showTransactionDetailModal(BuildContext context, TransactionEntity transaction) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (BuildContext dialogContext) {
        return BlocProvider<TransactionBloc>.value(
          value: context.read<TransactionBloc>(),
          child: TransactionDetailModal(transaction: transaction),
        );
      },
    );
  }
}