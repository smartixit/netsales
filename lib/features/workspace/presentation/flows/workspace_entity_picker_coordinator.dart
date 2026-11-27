import 'package:flutter/material.dart';
import 'package:netsales/core/enums/app_workspace.dart';
import 'package:netsales/features/workspace/presentation/controllers/workspace_entity_picker_controller.dart';
import 'package:netsales/features/workspace/presentation/widgets/workspace_entity_picker_sheet.dart';

/// Owns the UI flow for opening the workspace entity picker.
class WorkspaceEntityPickerCoordinator {
  const WorkspaceEntityPickerCoordinator();

  void open(BuildContext context, AppWorkspace workspace) {
    WorkspaceEntityPickerController.to.prepareForWorkspace(workspace);
    WorkspaceEntityPickerSheet.show(context, currentWorkspace: workspace);
  }
}
