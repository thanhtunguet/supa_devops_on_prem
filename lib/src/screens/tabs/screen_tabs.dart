part of tabs;

class _TabsScreen extends StatelessWidget {
  const _TabsScreen(this.ctrl, this.parameters);

  final _TabsController ctrl;
  final _TabsParameters parameters;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => ctrl.popTab(didPop: didPop),
      child: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: AppPage.empty(
          init: ctrl.init,
          builder: (_) => CupertinoTabScaffold(
            controller: ctrl.tabController,
            tabBar: CupertinoTabBar(
              backgroundColor: context.themeExtension.background,
              activeColor: context.themeExtension.onBackground,
              inactiveColor: context.colorScheme.onSecondary.withOpacity(.4),
              key: ctrl.tabKey,
              onTap: ctrl.goToTab,
              border: Border(
                top: BorderSide(
                  color: context.colorScheme.secondaryContainer,
                ),
              ),
              height: parameters.tabBarHeight,
              items: ctrl.navPages
                  .map(
                    (p) => BottomNavigationBarItem(
                      icon: ValueListenableBuilder<bool>(
                        valueListenable: ctrl.tabState[p.pageName]!,
                        builder: (_, isActive, __) => Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Icon(
                            p.icon,
                            size: parameters.tabIconHeight,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            tabBuilder: (_, i) => CupertinoTabView(
              navigatorKey: ctrl.navPages[i].key,
              navigatorObservers: [
                SentryNavigatorObserver(
                  routeNameExtractor: (settings) =>
                      ctrl.getRouteSettingsName(settings, i),
                ),
              ],
              onGenerateRoute: (route) => MaterialPageRoute(
                builder: (_) => route.name == '/'
                    ? AppRouter.routes[ctrl.navPages[i].pageName]!(_)
                    : AppRouter.routes[route.name!]!(_),
                settings: route,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
