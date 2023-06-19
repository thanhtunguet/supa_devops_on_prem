part of work_item_detail;

class _WorkItemDetailScreen extends StatelessWidget {
  const _WorkItemDetailScreen(this.ctrl, this.parameters);

  final _WorkItemDetailController ctrl;
  final _WorkItemDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AppPage<WorkItemWithUpdates?>(
          init: ctrl.init,
          dispose: ctrl.dispose,
          title: 'Work Item #${ctrl.args.id}',
          notifier: ctrl.itemDetail,
          actions: [
            PopupMenuButton<void>(
              key: ValueKey('Popup menu work item detail'),
              itemBuilder: (_) => [
                PopupMenuItem<void>(
                  onTap: ctrl.shareWorkItem,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Share',
                        style: context.textTheme.titleSmall,
                      ),
                      Icon(DevOpsIcons.share),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<void>(
                  onTap: ctrl.editWorkItem,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit',
                        style: context.textTheme.titleSmall,
                      ),
                      Icon(DevOpsIcons.edit),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<void>(
                  onTap: ctrl.deleteWorkItem,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delete',
                        style: context.textTheme.titleSmall,
                      ),
                      Icon(DevOpsIcons.failed),
                    ],
                  ),
                ),
              ],
              elevation: 0,
              tooltip: 'Work item actions',
              offset: const Offset(0, 40),
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              child: Icon(DevOpsIcons.dots_horizontal),
            ),
            const SizedBox(
              width: 8,
            ),
          ],
          builder: (detWithUpdates) {
            final detail = detWithUpdates!.item;
            final wType = ctrl.apiService.workItemTypes[detail.fields.systemTeamProject]
                ?.firstWhereOrNull((t) => t.name == detail.fields.systemWorkItemType);
            final state = ctrl
                .apiService.workItemStates[detail.fields.systemTeamProject]?[detail.fields.systemWorkItemType]
                ?.firstWhereOrNull((t) => t.name == detail.fields.systemState);

            return DefaultTextStyle(
              style: context.textTheme.titleSmall!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      WorkItemTypeIcon(type: wType),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(detail.fields.systemWorkItemType),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(detail.id.toString()),
                      const Spacer(),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        detail.fields.systemState,
                        style: context.textTheme.titleSmall!.copyWith(
                          color: state == null ? null : Color(int.parse(state.color, radix: 16)).withOpacity(1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (detail.fields.systemCreatedBy != null)
                    Row(
                      children: [
                        Text(
                          'Created by: ',
                          style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                        ),
                        Text(detail.fields.systemCreatedBy!.displayName!),
                        if (ctrl.apiService.organization.isNotEmpty) ...[
                          const SizedBox(
                            width: 10,
                          ),
                          MemberAvatar(
                            userDescriptor: detail.fields.systemCreatedBy!.descriptor!,
                            radius: 30,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                        const Spacer(),
                        Text(detail.fields.systemCreatedDate!.minutesAgo),
                      ],
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  ProjectChip(
                    onTap: ctrl.goToProject,
                    projectName: detail.fields.systemTeamProject,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Title:',
                    style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                  ),
                  Text(detail.fields.systemTitle),
                  if (detail.fields.systemDescription != null) ...[
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Description:',
                      style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                    ),
                    _HtmlWidget(
                      data: detail.fields.systemDescription!,
                      style: context.textTheme.titleSmall,
                    ),
                  ],
                  if (detail.fields.reproSteps != null) ...[
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Repro Steps:',
                      style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                    ),
                    _HtmlWidget(
                      data: detail.fields.reproSteps!,
                      style: context.textTheme.titleSmall,
                    ),
                  ],
                  const Divider(
                    height: 40,
                  ),
                  if (detail.fields.systemAssignedTo != null)
                    Row(
                      children: [
                        TextTitleDescription(
                          title: 'Assigned to: ',
                          description: detail.fields.systemAssignedTo!.displayName!,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        MemberAvatar(
                          userDescriptor: detail.fields.systemAssignedTo!.descriptor!,
                          radius: 30,
                        ),
                      ],
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextTitleDescription(
                    title: 'Created at: ',
                    description: detail.fields.systemCreatedDate!.toSimpleDate(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextTitleDescription(
                    title: 'Change date: ',
                    description: detail.fields.systemChangedDate.toSimpleDate(),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SectionHeader.noMargin(text: 'History'),
                          Row(
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 20,
                                constraints: BoxConstraints(maxWidth: 20),
                                onPressed: ctrl.toggleShowUpdatesReversed,
                                icon: Icon(Icons.swap_vert),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 20,
                                constraints: BoxConstraints(maxWidth: 20),
                                onPressed: ctrl.addComment,
                                icon: Icon(DevOpsIcons.plus),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      VisibilityDetector(
                        key: ctrl.historyKey,
                        onVisibilityChanged: ctrl.onHistoryVisibilityChanged,
                        child: ValueListenableBuilder(
                          valueListenable: ctrl.showUpdatesReversed,
                          builder: (_, showUpdatesReversed, __) {
                            final updates = showUpdatesReversed ? ctrl.updates.reversed.toList() : ctrl.updates;
                            return _History(
                              updates: updates,
                              ctrl: ctrl,
                            );
                          },
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: ctrl.showCommentField,
                        builder: (_, value, __) => SizedBox(
                          height: value ? 100 : 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        _AddCommentField(
          isVisible: ctrl.showCommentField,
          onTap: ctrl.addComment,
        ),
      ],
    );
  }
}
