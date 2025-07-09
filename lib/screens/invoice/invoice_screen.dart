import 'package:flutter/material.dart';
import 'package:kontor/routes/app_routes.dart';
import 'package:kontor/services/invoice_service.dart';
import 'package:kontor/utils/color_data.dart';
import 'package:kontor/utils/constant.dart';
import 'package:kontor/utils/widget_utils.dart';
import 'package:kontor/widgets/custom_checkbox.dart';
import 'package:kontor/widgets/custom_dialog.dart';
import 'package:kontor/widgets/custom_text.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<dynamic> paidInvoices = [];
  List<dynamic> unpaidInvoices = [];
  List<dynamic> invoiceStatistic = [];
  List<dynamic> selectedInvoiceIds = [];
  List<bool> checkedStates = [];

  int paidPage = 1;
  int unpaidPage = 1;
  int paidTotalPages = 1;
  int unpaidTotalPages = 1;
  int _previousTabIndex = 0;

  bool isLoading = false;
  bool isFechingStatistic = false;
  bool isFetchingMorePaid = false;
  bool isFetchingMoreUnpaid = false;
  bool isAllSelected = false;

  final ScrollController _paidScrollController = ScrollController();
  final ScrollController _unpaidScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _previousTabIndex &&
          !_tabController.indexIsChanging) {
        setState(() {
          isAllSelected = false;
          checkedStates = List.filled(unpaidInvoices.length, false);
          _previousTabIndex = _tabController.index;
        });
      }
    });

    _fetchInvoiceStatistic();
    _fetchInvoices(true, 1);
    _fetchInvoices(false, 1);
    _addScrollListeners();
  }

  void _addScrollListeners() {
    _paidScrollController.addListener(() {
      if (_paidScrollController.position.pixels >=
              _paidScrollController.position.maxScrollExtent - 100 &&
          paidPage < paidTotalPages &&
          !isFetchingMorePaid) {
        _fetchInvoices(true, paidPage + 1);
      }
    });

    _unpaidScrollController.addListener(() {
      if (_unpaidScrollController.position.pixels >=
              _unpaidScrollController.position.maxScrollExtent - 100 &&
          unpaidPage < unpaidTotalPages &&
          !isFetchingMoreUnpaid) {
        _fetchInvoices(false, unpaidPage + 1);
      }
    });
  }

  Future<void> _fetchInvoiceStatistic() async {
    try {
      setState(() => isFechingStatistic = true);
      final response = await InvoiceService.getInvoiceStatistic();
      if (response['status']) {
        setState(() {
          invoiceStatistic = response["data"];
        });
      }
    } catch (e) {
      print("Error fetching invoices: $e");
    } finally {
      setState(() => isFechingStatistic = false);
    }
  }

  Future<void> _fetchInvoices(bool paid, int page,
      {bool refresh = false}) async {
    if (refresh || page == 1) {
      setState(() => isLoading = true);
    } else {
      setState(() {
        if (paid) {
          isFetchingMorePaid = true;
        } else {
          isFetchingMoreUnpaid = true;
        }
      });
    }

    try {
      final response =
          await InvoiceService.getInvoiceList(paid ? 'paid' : 'unpaid', page);
      if (response['status']) {
        setState(() {
          final data = response['data'];
          if (paid) {
            if (refresh) paidInvoices.clear();
            paidInvoices.addAll(data);
            paidTotalPages = response['num_pages'];
            paidPage = page;
          } else {
            if (refresh) unpaidInvoices.clear();
            unpaidInvoices.addAll(data);
            unpaidTotalPages = response['num_pages'];
            unpaidPage = page;
            checkedStates = List.filled(unpaidInvoices.length, false);
          }
        });
      }
    } catch (e) {
      print("Error fetching invoices: $e");
    } finally {
      setState(() {
        isLoading = false;
        if (paid) {
          isFetchingMorePaid = false;
        } else {
          isFetchingMoreUnpaid = false;
        }
      });
    }
  }

  bool get unpaidTabSelected => _tabController.index == 1;

  List<int> get selectedInvoiceIndexes => checkedStates
      .asMap()
      .entries
      .where((e) => e.value)
      .map((e) => e.key)
      .toList();

  void _handleSelectedInvoice() {
    for (int i = 0; i < checkedStates.length; i++) {
      if (checkedStates[i]) {
        final invoiceId = unpaidInvoices[i]['id'];
        selectedInvoiceIds.add(invoiceId);
      }
    }
    showDialog(
      context: context,
      builder: (_) => EbarimtDialog(
        invoiceIds: selectedInvoiceIds,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _toggleSelectAll() {
    setState(() {
      isAllSelected = !isAllSelected;
      checkedStates = List.filled(checkedStates.length, isAllSelected);
    });
  }

  bool get hasSelection => checkedStates.any((v) => v);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: _tabController.index == 1 && hasSelection
            ? Padding(
                key: const ValueKey('fab-row'),
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height:
                          48, // match the extended FAB height (default is 48)
                      width: 48, // optional, to keep it square
                      child: FloatingActionButton(
                        heroTag: 'selectAll',
                        onPressed: _toggleSelectAll,
                        backgroundColor: primaryColor,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          isAllSelected ? Icons.close : Icons.done_all,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton.extended(
                      heroTag: 'pay',
                      onPressed: _handleSelectedInvoice,
                      backgroundColor: secondaryColor,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      icon: const Icon(Icons.payments_outlined),
                      // icon: getAssetImage('valid.png',
                      //     width: 27, height: 27, color: Colors.white),
                      label: CustomText(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        text: 'Төлөх (${checkedStates.where((e) => e).length})',
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink(
                key: ValueKey('fab-empty'),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                      child: _buildStatCard(
                          "Төлсөн",
                          isFechingStatistic
                              ? 0
                              : invoiceStatistic[0]["total_amount"],
                          true)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildStatCard(
                          "Төлөөгүй",
                          isFechingStatistic
                              ? 0
                              : invoiceStatistic[1]["total_amount"],
                          false)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: primaryColor,
                  tabs: [Tab(text: "Төлсөн "), Tab(text: "Төлөөгүй")],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildInvoiceList(true),
            _buildInvoiceList(false),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, double amount, bool paid) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: paid ? primaryColor : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            color: paid ? Colors.white70 : Colors.grey.shade600,
            fontSize: 14,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: Constant.formatAmount(amount),
            color: paid ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceList(bool paid) {
    final invoices = paid ? paidInvoices : unpaidInvoices;
    final controller = paid ? _paidScrollController : _unpaidScrollController;
    final isFetchingMore = paid ? isFetchingMorePaid : isFetchingMoreUnpaid;

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: () => _fetchInvoices(paid, 1, refresh: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: controller,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 132),
                child: Column(
                  children: [
                    if (isLoading)
                      SizedBox(
                        height: constraints.maxHeight - 132,
                        child: Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        ),
                      )
                    else if (invoices.isEmpty)
                      SizedBox(
                        height: constraints.maxHeight - 132,
                        child: const Center(
                          child: CustomText(
                            text: "Жагсаалт хоосон байна",
                            fontSize: 14,
                            color: Colors.grey,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else
                      for (int i = 0; i < invoices.length; i++)
                        _buildInvoiceCard(invoices[i], i, paid),
                    if (isFetchingMore)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(color: primaryColor),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInvoiceCard(Map invoice, int index, bool paid) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.invoiceDetail,
          arguments: {'paid': paid, 'invoiceId': invoice["id"].toString()}),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              paid ? Icons.check_circle : Icons.pending_actions_outlined,
              color: paid ? successColor : secondaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: "Нэхэмжлэл #${index + 1}",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                      text: "${invoice['year']}-${invoice['month']} сар",
                      fontSize: 13,
                      color: Colors.grey.shade600),
                ],
              ),
            ),
            CustomText(
              text: Constant.formatAmount(
                  paid ? invoice['amount_total'] : invoice['amount_residual']),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            if (!paid)
              CustomCheckbox(
                shrink: true,
                value: checkedStates[index],
                onChanged: (val) => setState(() => checkedStates[index] = val!),
              ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.transparent,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
