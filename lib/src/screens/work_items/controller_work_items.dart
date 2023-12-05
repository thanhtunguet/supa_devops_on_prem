part of work_items;

class _WorkItemsController with FilterMixin {
  factory _WorkItemsController({
    required AzureApiService apiService,
    required StorageService storageService,
    Project? project,
  }) {
    // handle page already in memory with a different project filter
    if (_instances[project.hashCode] != null) {
      return _instances[project.hashCode]!;
    }

    if (instance != null && project?.id != instance!.project?.id) {
      instance = _WorkItemsController._(apiService, storageService, project);
    }

    instance ??= _WorkItemsController._(apiService, storageService, project);
    return _instances.putIfAbsent(project.hashCode, () => instance!);
  }

  _WorkItemsController._(this.apiService, this.storageService, this.project) {
    projectFilter = project ?? projectAll;
  }

  static _WorkItemsController? instance;
  static final Map<int, _WorkItemsController> _instances = {};

  final AzureApiService apiService;
  final StorageService storageService;
  final Project? project;

  final workItems = ValueNotifier<ApiResponse<List<WorkItem>?>?>(null);
  List<WorkItem> allWorkItems = [];

  late Set<WorkItemState> statesFilter = {};
  WorkItemType typeFilter = WorkItemType.all;
  AreaOrIteration? areaFilter;
  AreaOrIteration? iterationFilter;

  /// Used to show only active iterations in iteration filter
  final showActiveIterations = ValueNotifier<bool>(false);

  late List<WorkItemType> allWorkItemTypes = [typeFilter];
  late List<WorkItemState> allWorkItemStates = statesFilter.toList();

  final isSearching = ValueNotifier<bool>(false);
  String? _currentSearchQuery;

  bool get isDefaultStateFilter => statesFilter.isEmpty;

  void dispose() {
    instance = null;
    _instances.remove(project.hashCode);
  }

  Future<void> init() async {
    allWorkItemTypes = [typeFilter];
    allWorkItemStates = statesFilter.toList();

    final types = await apiService.getWorkItemTypes();
    if (!types.isError) {
      allWorkItemTypes.addAll(types.data!.values.expand((ts) => ts).toSet());

      final allStatesToAdd = <WorkItemState>{};

      for (final entry in apiService.workItemStates.values) {
        final states = entry.values.expand((v) => v);
        allStatesToAdd.addAll(states);
      }

      final sortedStates = allStatesToAdd.sorted((a, b) => a.name.compareTo(b.name));

      allWorkItemStates.addAll(sortedStates);
    }

    await _getData();
  }

  Future<void> goToWorkItemDetail(WorkItem item) async {
    await AppRouter.goToWorkItemDetail(project: item.fields.systemTeamProject, id: item.id);
    await _getData();
  }

  void filterByProject(Project proj) {
    if (proj.id == projectFilter.id) return;

    workItems.value = null;
    projectFilter = proj.name == projectAll.name ? projectAll : proj;

    final projectAreas = apiService.workItemAreas[projectFilter.name!];
    if (projectAreas != null && projectAreas.isNotEmpty) {
      _resetAreaFilterIfNecessary(projectAreas);
    }

    final projectIterations = apiService.workItemIterations[projectFilter.name!];
    if (projectIterations != null && projectIterations.isNotEmpty) {
      _resetIterationFilterIfNecessary(projectIterations);
    }

    _getData();
  }

  /// Resets [areaFilter] if selected [projectFilter] doesn't contain this area
  void _resetAreaFilterIfNecessary(List<AreaOrIteration> projectAreas) {
    final flattenedAreas = _flattenList(projectAreas);

    if (areaFilter != null && !flattenedAreas.contains(areaFilter)) {
      areaFilter = null;
    }
  }

  /// Resets [iterationFilter] if selected [projectFilter] doesn't contain this iteration
  void _resetIterationFilterIfNecessary(List<AreaOrIteration> projectIterations) {
    final flattenedIterations = _flattenList(projectIterations);

    if (iterationFilter != null && !flattenedIterations.contains(iterationFilter)) {
      iterationFilter = null;
    }
  }

  List<AreaOrIteration> _flattenList(List<AreaOrIteration> areasOrIterations) {
    var area = areasOrIterations.first;
    final flattened = <AreaOrIteration>[];

    while (area.hasChildren) {
      flattened.addAll([area, ...area.children!]);
      area = area.children!.first;
    }

    return flattened;
  }

  void filterByStates(Set<WorkItemState> states) {
    if (states == statesFilter) return;

    workItems.value = null;
    statesFilter = states;
    _getData();
  }

  void filterByType(WorkItemType type) {
    if (type.name == typeFilter.name) return;

    workItems.value = null;
    typeFilter = type;
    _getData();
  }

  void filterByUser(GraphUser user) {
    if (user == userFilter) return;

    workItems.value = null;
    userFilter = user;
    _getData();
  }

  void filterByArea(AreaOrIteration? area) {
    if (areaFilter != null && area?.id == areaFilter!.id) return;

    workItems.value = null;
    areaFilter = area;
    _getData();
  }

  void filterByIteration(AreaOrIteration? iteration) {
    if (iterationFilter != null && iteration?.id == iterationFilter!.id) return;

    workItems.value = null;
    iterationFilter = iteration;
    _getData();
  }

  Future<void> _getData() async {
    var assignedTo = userFilter == userAll ? null : userFilter;
    if (userFilter.displayName == 'Unassigned') {
      assignedTo = GraphUser(mailAddress: '');
    }

    final res = await apiService.getWorkItems(
      project: projectFilter == projectAll ? null : projectFilter,
      type: typeFilter == WorkItemType.all ? null : typeFilter,
      states: isDefaultStateFilter ? null : statesFilter,
      assignedTo: assignedTo,
      area: areaFilter,
      iteration: iterationFilter,
    );

    allWorkItems = res.data ?? [];
    workItems.value = res;

    if (_currentSearchQuery != null) {
      _searchWorkItem(_currentSearchQuery!);
    }
  }

  void resetFilters() {
    workItems.value = null;
    statesFilter.clear();
    typeFilter = WorkItemType.all;
    projectFilter = projectAll;
    userFilter = userAll;
    areaFilter = null;
    iterationFilter = null;
    _currentSearchQuery = null;
    resetSearch();

    init();
  }

  Future<void> createWorkItem() async {
    await AppRouter.goToCreateOrEditWorkItem(
      args: (
        project: projectFilter != projectAll ? projectFilter.name : null,
        id: null,
        area: areaFilter?.path,
        iteration: iterationFilter?.path,
      ),
    );
    await init();
  }

  List<GraphUser> getAssignees() {
    final users = getSortedUsers(apiService);
    final unassigned = GraphUser(displayName: 'Unassigned', mailAddress: 'unassigned');
    return users..insert(1, unassigned);
  }

  /// If user has selected a project show only areas of the selected project,
  /// and don't show areas that are identical to the project (projects with default area only)
  Iterable<AreaOrIteration> getAreasToShow() {
    final hasProjectFilter = projectFilter != projectAll;
    final areas = apiService.workItemAreas;
    final projectAreas = hasProjectFilter ? areas[projectFilter.name!] : null;

    final areasToShow = (projectAreas != null ? [projectAreas] : areas.values)
        .where((p) => p.length > 1 || (p.first.children?.isNotEmpty ?? false))
        .expand((a) => a);

    return areasToShow;
  }

  // If user has selected a project show only iterations of the selected project,
  // otherwise if user has selected an area show only iterations of the project which the area belongs to,
  // otherwise show all iterations
  Iterable<AreaOrIteration> getIterationsToShow() {
    final iterations = apiService.workItemIterations;

    final hasProjectFilter = projectFilter != projectAll;
    final projectIterations = hasProjectFilter ? iterations[projectFilter.name!] : null;

    final hasAreaFilter = areaFilter != null;
    final areaProjectIterations = hasAreaFilter ? iterations[areaFilter?.projectName] : null;

    final iterationsToShow = projectIterations ?? areaProjectIterations ?? iterations.values.expand((a) => a);

    return iterationsToShow;
  }

  void toggleShowActiveIterations() {
    showActiveIterations.value = !showActiveIterations.value;
  }

  void showSearchField() {
    isSearching.value = true;
  }

  /// Search currently filtered work items by id or title.
  void _searchWorkItem(String query) {
    _currentSearchQuery = query.trim().toLowerCase();

    final matchedItems = allWorkItems
        .where(
          (i) =>
              i.id.toString().contains(_currentSearchQuery!) ||
              i.fields.systemTitle.toLowerCase().contains(_currentSearchQuery!),
        )
        .toList();

    workItems.value = workItems.value?.copyWith(data: matchedItems);
  }

  void resetSearch() {
    _searchWorkItem('');
    _hideSearchField();
  }

  void _hideSearchField() {
    isSearching.value = false;
  }

  List<GraphUser> searchAssignee(String query) {
    final loweredQuery = query.toLowerCase().trim();
    final users = getAssignees();
    return users.where((u) => u.displayName != null && u.displayName!.toLowerCase().contains(loweredQuery)).toList();
  }
}
