#Include <COM>

CONST := CONST ?? {}

CONST.TreeScope_None := 0,
CONST.TreeScope_Element := 0x1,
CONST.TreeScope_Children := 0x2,
CONST.TreeScope_Descendants := 0x4,
CONST.TreeScope_Parent := 0x8,
CONST.TreeScope_Ancestors := 0x10,
CONST.TreeScope_Subtree := ((CONST.TreeScope_Element | CONST.TreeScope_Children) | CONST.TreeScope_Descendants)

CONST.PropertyConditionFlags_None := 0,
CONST.PropertyConditionFlags_IgnoreCase := 0x1,
CONST.PropertyConditionFlags_MatchSubstring := 0x2

CONST.AutomationElementMode_None := 0,
CONST.AutomationElementMode_Full := (CONST.AutomationElementMode_None + 1)

CONST.TreeTraversalOptions_Default := 0,
CONST.TreeTraversalOptions_PostOrder := 0x1,
CONST.TreeTraversalOptions_LastToFirstOrder := 0x2

CONST.ConnectionRecoveryBehaviorOptions_Disabled := 0,
CONST.ConnectionRecoveryBehaviorOptions_Enabled := 0x1

CONST.CoalesceEventsOptions_Disabled := 0,
CONST.CoalesceEventsOptions_Enabled := 0x1

CONST.TextUnit_Character := 0,
CONST.TextUnit_Format := 1,
CONST.TextUnit_Word := 2,
CONST.TextUnit_Line := 3,
CONST.TextUnit_Paragraph := 4,
CONST.TextUnit_Page := 5,
CONST.TextUnit_Document := 6

CONST.UIA_InvokePatternId := 10000,
CONST.UIA_SelectionPatternId := 10001,
CONST.UIA_ValuePatternId := 10002,
CONST.UIA_RangeValuePatternId := 10003,
CONST.UIA_ScrollPatternId := 10004,
CONST.UIA_ExpandCollapsePatternId := 10005,
CONST.UIA_GridPatternId := 10006,
CONST.UIA_GridItemPatternId := 10007,
CONST.UIA_MultipleViewPatternId := 10008,
CONST.UIA_WindowPatternId := 10009,
CONST.UIA_SelectionItemPatternId := 10010,
CONST.UIA_DockPatternId := 10011,
CONST.UIA_TablePatternId := 10012,
CONST.UIA_TableItemPatternId := 10013,
CONST.UIA_TextPatternId := 10014,
CONST.UIA_TogglePatternId := 10015,
CONST.UIA_TransformPatternId := 10016,
CONST.UIA_ScrollItemPatternId := 10017,
CONST.UIA_LegacyIAccessiblePatternId := 10018,
CONST.UIA_ItemContainerPatternId := 10019,
CONST.UIA_VirtualizedItemPatternId := 10020,
CONST.UIA_SynchronizedInputPatternId := 10021,
CONST.UIA_ObjectModelPatternId := 10022,
CONST.UIA_AnnotationPatternId := 10023,
CONST.UIA_TextPattern2Id := 10024,
CONST.UIA_StylesPatternId := 10025,
CONST.UIA_SpreadsheetPatternId := 10026,
CONST.UIA_SpreadsheetItemPatternId := 10027,
CONST.UIA_TransformPattern2Id := 10028,
CONST.UIA_TextChildPatternId := 10029,
CONST.UIA_DragPatternId := 10030,
CONST.UIA_DropTargetPatternId := 10031,
CONST.UIA_TextEditPatternId := 10032,
CONST.UIA_CustomNavigationPatternId := 10033,
CONST.UIA_SelectionPattern2Id := 10034

CONST.UIA_ToolTipOpenedEventId := 20000,
CONST.UIA_ToolTipClosedEventId := 20001,
CONST.UIA_StructureChangedEventId := 20002,
CONST.UIA_MenuOpenedEventId := 20003,
CONST.UIA_AutomationPropertyChangedEventId := 20004,
CONST.UIA_AutomationFocusChangedEventId := 20005,
CONST.UIA_AsyncContentLoadedEventId := 20006,
CONST.UIA_MenuClosedEventId := 20007,
CONST.UIA_LayoutInvalidatedEventId := 20008,
CONST.UIA_Invoke_InvokedEventId := 20009,
CONST.UIA_SelectionItem_ElementAddedToSelectionEventId := 20010,
CONST.UIA_SelectionItem_ElementRemovedFromSelectionEventId := 20011,
CONST.UIA_SelectionItem_ElementSelectedEventId := 20012,
CONST.UIA_Selection_InvalidatedEventId := 20013,
CONST.UIA_Text_TextSelectionChangedEventId := 20014,
CONST.UIA_Text_TextChangedEventId := 20015,
CONST.UIA_Window_WindowOpenedEventId := 20016,
CONST.UIA_Window_WindowClosedEventId := 20017,
CONST.UIA_MenuModeStartEventId := 20018,
CONST.UIA_MenuModeEndEventId := 20019,
CONST.UIA_InputReachedTargetEventId := 20020,
CONST.UIA_InputReachedOtherElementEventId := 20021,
CONST.UIA_InputDiscardedEventId := 20022,
CONST.UIA_SystemAlertEventId := 20023,
CONST.UIA_LiveRegionChangedEventId := 20024,
CONST.UIA_HostedFragmentRootsInvalidatedEventId := 20025,
CONST.UIA_Drag_DragStartEventId := 20026,
CONST.UIA_Drag_DragCancelEventId := 20027,
CONST.UIA_Drag_DragCompleteEventId := 20028,
CONST.UIA_DropTarget_DragEnterEventId := 20029,
CONST.UIA_DropTarget_DragLeaveEventId := 20030,
CONST.UIA_DropTarget_DroppedEventId := 20031,
CONST.UIA_TextEdit_TextChangedEventId := 20032,
CONST.UIA_TextEdit_ConversionTargetChangedEventId := 20033,
CONST.UIA_ChangesEventId := 20034,
CONST.UIA_NotificationEventId := 20035,
CONST.UIA_ActiveTextPositionChangedEventId := 20036

CONST.UIA_RuntimeIdPropertyId := 30000,
CONST.UIA_BoundingRectanglePropertyId := 30001,
CONST.UIA_ProcessIdPropertyId := 30002,
CONST.UIA_ControlTypePropertyId := 30003,
CONST.UIA_LocalizedControlTypePropertyId := 30004,
CONST.UIA_NamePropertyId := 30005,
CONST.UIA_AcceleratorKeyPropertyId := 30006,
CONST.UIA_AccessKeyPropertyId := 30007,
CONST.UIA_HasKeyboardFocusPropertyId := 30008,
CONST.UIA_IsKeyboardFocusablePropertyId := 30009,
CONST.UIA_IsEnabledPropertyId := 30010,
CONST.UIA_AutomationIdPropertyId := 30011,
CONST.UIA_ClassNamePropertyId := 30012,
CONST.UIA_HelpTextPropertyId := 30013,
CONST.UIA_ClickablePointPropertyId := 30014,
CONST.UIA_CulturePropertyId := 30015,
CONST.UIA_IsControlElementPropertyId := 30016,
CONST.UIA_IsContentElementPropertyId := 30017,
CONST.UIA_LabeledByPropertyId := 30018,
CONST.UIA_IsPasswordPropertyId := 30019,
CONST.UIA_NativeWindowHandlePropertyId := 30020,
CONST.UIA_ItemTypePropertyId := 30021,
CONST.UIA_IsOffscreenPropertyId := 30022,
CONST.UIA_OrientationPropertyId := 30023,
CONST.UIA_FrameworkIdPropertyId := 30024,
CONST.UIA_IsRequiredForFormPropertyId := 30025,
CONST.UIA_ItemStatusPropertyId := 30026,
CONST.UIA_IsDockPatternAvailablePropertyId := 30027,
CONST.UIA_IsExpandCollapsePatternAvailablePropertyId := 30028,
CONST.UIA_IsGridItemPatternAvailablePropertyId := 30029,
CONST.UIA_IsGridPatternAvailablePropertyId := 30030,
CONST.UIA_IsInvokePatternAvailablePropertyId := 30031,
CONST.UIA_IsMultipleViewPatternAvailablePropertyId := 30032,
CONST.UIA_IsRangeValuePatternAvailablePropertyId := 30033,
CONST.UIA_IsScrollPatternAvailablePropertyId := 30034,
CONST.UIA_IsScrollItemPatternAvailablePropertyId := 30035,
CONST.UIA_IsSelectionItemPatternAvailablePropertyId := 30036,
CONST.UIA_IsSelectionPatternAvailablePropertyId := 30037,
CONST.UIA_IsTablePatternAvailablePropertyId := 30038,
CONST.UIA_IsTableItemPatternAvailablePropertyId := 30039,
CONST.UIA_IsTextPatternAvailablePropertyId := 30040,
CONST.UIA_IsTogglePatternAvailablePropertyId := 30041,
CONST.UIA_IsTransformPatternAvailablePropertyId := 30042,
CONST.UIA_IsValuePatternAvailablePropertyId := 30043,
CONST.UIA_IsWindowPatternAvailablePropertyId := 30044,
CONST.UIA_ValueValuePropertyId := 30045,
CONST.UIA_ValueIsReadOnlyPropertyId := 30046,
CONST.UIA_RangeValueValuePropertyId := 30047,
CONST.UIA_RangeValueIsReadOnlyPropertyId := 30048,
CONST.UIA_RangeValueMinimumPropertyId := 30049,
CONST.UIA_RangeValueMaximumPropertyId := 30050,
CONST.UIA_RangeValueLargeChangePropertyId := 30051,
CONST.UIA_RangeValueSmallChangePropertyId := 30052,
CONST.UIA_ScrollHorizontalScrollPercentPropertyId := 30053,
CONST.UIA_ScrollHorizontalViewSizePropertyId := 30054,
CONST.UIA_ScrollVerticalScrollPercentPropertyId := 30055,
CONST.UIA_ScrollVerticalViewSizePropertyId := 30056,
CONST.UIA_ScrollHorizontallyScrollablePropertyId := 30057,
CONST.UIA_ScrollVerticallyScrollablePropertyId := 30058,
CONST.UIA_SelectionSelectionPropertyId := 30059,
CONST.UIA_SelectionCanSelectMultiplePropertyId := 30060,
CONST.UIA_SelectionIsSelectionRequiredPropertyId := 30061,
CONST.UIA_GridRowCountPropertyId := 30062,
CONST.UIA_GridColumnCountPropertyId := 30063,
CONST.UIA_GridItemRowPropertyId := 30064,
CONST.UIA_GridItemColumnPropertyId := 30065,
CONST.UIA_GridItemRowSpanPropertyId := 30066,
CONST.UIA_GridItemColumnSpanPropertyId := 30067,
CONST.UIA_GridItemContainingGridPropertyId := 30068,
CONST.UIA_DockDockPositionPropertyId := 30069,
CONST.UIA_ExpandCollapseExpandCollapseStatePropertyId := 30070,
CONST.UIA_MultipleViewCurrentViewPropertyId := 30071,
CONST.UIA_MultipleViewSupportedViewsPropertyId := 30072,
CONST.UIA_WindowCanMaximizePropertyId := 30073,
CONST.UIA_WindowCanMinimizePropertyId := 30074,
CONST.UIA_WindowWindowVisualStatePropertyId := 30075,
CONST.UIA_WindowWindowInteractionStatePropertyId := 30076,
CONST.UIA_WindowIsModalPropertyId := 30077,
CONST.UIA_WindowIsTopmostPropertyId := 30078,
CONST.UIA_SelectionItemIsSelectedPropertyId := 30079,
CONST.UIA_SelectionItemSelectionContainerPropertyId := 30080,
CONST.UIA_TableRowHeadersPropertyId := 30081,
CONST.UIA_TableColumnHeadersPropertyId := 30082,
CONST.UIA_TableRowOrColumnMajorPropertyId := 30083,
CONST.UIA_TableItemRowHeaderItemsPropertyId := 30084,
CONST.UIA_TableItemColumnHeaderItemsPropertyId := 30085,
CONST.UIA_ToggleToggleStatePropertyId := 30086,
CONST.UIA_TransformCanMovePropertyId := 30087,
CONST.UIA_TransformCanResizePropertyId := 30088,
CONST.UIA_TransformCanRotatePropertyId := 30089,
CONST.UIA_IsLegacyIAccessiblePatternAvailablePropertyId := 30090,
CONST.UIA_LegacyIAccessibleChildIdPropertyId := 30091,
CONST.UIA_LegacyIAccessibleNamePropertyId := 30092,
CONST.UIA_LegacyIAccessibleValuePropertyId := 30093,
CONST.UIA_LegacyIAccessibleDescriptionPropertyId := 30094,
CONST.UIA_LegacyIAccessibleRolePropertyId := 30095,
CONST.UIA_LegacyIAccessibleStatePropertyId := 30096,
CONST.UIA_LegacyIAccessibleHelpPropertyId := 30097,
CONST.UIA_LegacyIAccessibleKeyboardShortcutPropertyId := 30098,
CONST.UIA_LegacyIAccessibleSelectionPropertyId := 30099,
CONST.UIA_LegacyIAccessibleDefaultActionPropertyId := 30100,
CONST.UIA_AriaRolePropertyId := 30101,
CONST.UIA_AriaPropertiesPropertyId := 30102,
CONST.UIA_IsDataValidForFormPropertyId := 30103,
CONST.UIA_ControllerForPropertyId := 30104,
CONST.UIA_DescribedByPropertyId := 30105,
CONST.UIA_FlowsToPropertyId := 30106,
CONST.UIA_ProviderDescriptionPropertyId := 30107,
CONST.UIA_IsItemContainerPatternAvailablePropertyId := 30108,
CONST.UIA_IsVirtualizedItemPatternAvailablePropertyId := 30109,
CONST.UIA_IsSynchronizedInputPatternAvailablePropertyId := 30110,
CONST.UIA_OptimizeForVisualContentPropertyId := 30111,
CONST.UIA_IsObjectModelPatternAvailablePropertyId := 30112,
CONST.UIA_AnnotationAnnotationTypeIdPropertyId := 30113,
CONST.UIA_AnnotationAnnotationTypeNamePropertyId := 30114,
CONST.UIA_AnnotationAuthorPropertyId := 30115,
CONST.UIA_AnnotationDateTimePropertyId := 30116,
CONST.UIA_AnnotationTargetPropertyId := 30117,
CONST.UIA_IsAnnotationPatternAvailablePropertyId := 30118,
CONST.UIA_IsTextPattern2AvailablePropertyId := 30119,
CONST.UIA_StylesStyleIdPropertyId := 30120,
CONST.UIA_StylesStyleNamePropertyId := 30121,
CONST.UIA_StylesFillColorPropertyId := 30122,
CONST.UIA_StylesFillPatternStylePropertyId := 30123,
CONST.UIA_StylesShapePropertyId := 30124,
CONST.UIA_StylesFillPatternColorPropertyId := 30125,
CONST.UIA_StylesExtendedPropertiesPropertyId := 30126,
CONST.UIA_IsStylesPatternAvailablePropertyId := 30127,
CONST.UIA_IsSpreadsheetPatternAvailablePropertyId := 30128,
CONST.UIA_SpreadsheetItemFormulaPropertyId := 30129,
CONST.UIA_SpreadsheetItemAnnotationObjectsPropertyId := 30130,
CONST.UIA_SpreadsheetItemAnnotationTypesPropertyId := 30131,
CONST.UIA_IsSpreadsheetItemPatternAvailablePropertyId := 30132,
CONST.UIA_Transform2CanZoomPropertyId := 30133,
CONST.UIA_IsTransformPattern2AvailablePropertyId := 30134,
CONST.UIA_LiveSettingPropertyId := 30135,
CONST.UIA_IsTextChildPatternAvailablePropertyId := 30136,
CONST.UIA_IsDragPatternAvailablePropertyId := 30137,
CONST.UIA_DragIsGrabbedPropertyId := 30138,
CONST.UIA_DragDropEffectPropertyId := 30139,
CONST.UIA_DragDropEffectsPropertyId := 30140,
CONST.UIA_IsDropTargetPatternAvailablePropertyId := 30141,
CONST.UIA_DropTargetDropTargetEffectPropertyId := 30142,
CONST.UIA_DropTargetDropTargetEffectsPropertyId := 30143,
CONST.UIA_DragGrabbedItemsPropertyId := 30144,
CONST.UIA_Transform2ZoomLevelPropertyId := 30145,
CONST.UIA_Transform2ZoomMinimumPropertyId := 30146,
CONST.UIA_Transform2ZoomMaximumPropertyId := 30147,
CONST.UIA_FlowsFromPropertyId := 30148,
CONST.UIA_IsTextEditPatternAvailablePropertyId := 30149,
CONST.UIA_IsPeripheralPropertyId := 30150,
CONST.UIA_IsCustomNavigationPatternAvailablePropertyId := 30151,
CONST.UIA_PositionInSetPropertyId := 30152,
CONST.UIA_SizeOfSetPropertyId := 30153,
CONST.UIA_LevelPropertyId := 30154,
CONST.UIA_AnnotationTypesPropertyId := 30155,
CONST.UIA_AnnotationObjectsPropertyId := 30156,
CONST.UIA_LandmarkTypePropertyId := 30157,
CONST.UIA_LocalizedLandmarkTypePropertyId := 30158,
CONST.UIA_FullDescriptionPropertyId := 30159,
CONST.UIA_FillColorPropertyId := 30160,
CONST.UIA_OutlineColorPropertyId := 30161,
CONST.UIA_FillTypePropertyId := 30162,
CONST.UIA_VisualEffectsPropertyId := 30163,
CONST.UIA_OutlineThicknessPropertyId := 30164,
CONST.UIA_CenterPointPropertyId := 30165,
CONST.UIA_RotationPropertyId := 30166,
CONST.UIA_SizePropertyId := 30167,
CONST.UIA_IsSelectionPattern2AvailablePropertyId := 30168,
CONST.UIA_Selection2FirstSelectedItemPropertyId := 30169,
CONST.UIA_Selection2LastSelectedItemPropertyId := 30170,
CONST.UIA_Selection2CurrentSelectedItemPropertyId := 30171,
CONST.UIA_Selection2ItemCountPropertyId := 30172,
CONST.UIA_HeadingLevelPropertyId := 30173,
CONST.UIA_IsDialogPropertyId := 30174

CONST.UIA_AnimationStyleAttributeId             := 40000,
CONST.UIA_BackgroundColorAttributeId            := 40001,
CONST.UIA_BulletStyleAttributeId                := 40002,
CONST.UIA_CapStyleAttributeId                   := 40003,
CONST.UIA_CultureAttributeId                    := 40004,
CONST.UIA_FontNameAttributeId                   := 40005,
CONST.UIA_FontSizeAttributeId                   := 40006,
CONST.UIA_FontWeightAttributeId                 := 40007,
CONST.UIA_ForegroundColorAttributeId            := 40008,
CONST.UIA_HorizontalTextAlignmentAttributeId    := 40009,
CONST.UIA_IndentationFirstLineAttributeId       := 40010,
CONST.UIA_IndentationLeadingAttributeId         := 40011,
CONST.UIA_IndentationTrailingAttributeId        := 40012,
CONST.UIA_IsHiddenAttributeId                   := 40013,
CONST.UIA_IsItalicAttributeId                   := 40014,
CONST.UIA_IsReadOnlyAttributeId                 := 40015,
CONST.UIA_IsSubscriptAttributeId                := 40016,
CONST.UIA_IsSuperscriptAttributeId              := 40017,
CONST.UIA_MarginBottomAttributeId               := 40018,
CONST.UIA_MarginLeadingAttributeId              := 40019,
CONST.UIA_MarginTopAttributeId                  := 40020,
CONST.UIA_MarginTrailingAttributeId             := 40021,
CONST.UIA_OutlineStylesAttributeId              := 40022,
CONST.UIA_OverlineColorAttributeId              := 40023,
CONST.UIA_OverlineStyleAttributeId              := 40024,
CONST.UIA_StrikethroughColorAttributeId         := 40025,
CONST.UIA_StrikethroughStyleAttributeId         := 40026,
CONST.UIA_TabsAttributeId                       := 40027,
CONST.UIA_TextFlowDirectionsAttributeId         := 40028,
CONST.UIA_UnderlineColorAttributeId             := 40029,
CONST.UIA_UnderlineStyleAttributeId             := 40030,
CONST.UIA_AnnotationTypesAttributeId            := 40031,
CONST.UIA_AnnotationObjectsAttributeId          := 40032,
CONST.UIA_StyleNameAttributeId                  := 40033,
CONST.UIA_StyleIdAttributeId                    := 40034,
CONST.UIA_LinkAttributeId                       := 40035,
CONST.UIA_IsActiveAttributeId                   := 40036,
CONST.UIA_SelectionActiveEndAttributeId         := 40037,
CONST.UIA_CaretPositionAttributeId              := 40038,
CONST.UIA_CaretBidiModeAttributeId              := 40039,
CONST.UIA_LineSpacingAttributeId                := 40040,
CONST.UIA_BeforeParagraphSpacingAttributeId     := 40041,
CONST.UIA_AfterParagraphSpacingAttributeId      := 40042,
CONST.UIA_SayAsInterpretAsAttributeId           := 40043

CONST.UIA_ButtonControlTypeId := 50000,
CONST.UIA_CalendarControlTypeId := 50001,
CONST.UIA_CheckBoxControlTypeId := 50002,
CONST.UIA_ComboBoxControlTypeId := 50003,
CONST.UIA_EditControlTypeId := 50004,
CONST.UIA_HyperlinkControlTypeId := 50005,
CONST.UIA_ImageControlTypeId := 50006,
CONST.UIA_ListItemControlTypeId := 50007,
CONST.UIA_ListControlTypeId := 50008,
CONST.UIA_MenuControlTypeId := 50009,
CONST.UIA_MenuBarControlTypeId := 50010,
CONST.UIA_MenuItemControlTypeId := 50011,
CONST.UIA_ProgressBarControlTypeId := 50012,
CONST.UIA_RadioButtonControlTypeId := 50013,
CONST.UIA_ScrollBarControlTypeId := 50014,
CONST.UIA_SliderControlTypeId := 50015,
CONST.UIA_SpinnerControlTypeId := 50016,
CONST.UIA_StatusBarControlTypeId := 50017,
CONST.UIA_TabControlTypeId := 50018,
CONST.UIA_TabItemControlTypeId := 50019,
CONST.UIA_TextControlTypeId := 50020,
CONST.UIA_ToolBarControlTypeId := 50021,
CONST.UIA_ToolTipControlTypeId := 50022,
CONST.UIA_TreeControlTypeId := 50023,
CONST.UIA_TreeItemControlTypeId := 50024,
CONST.UIA_CustomControlTypeId := 50025,
CONST.UIA_GroupControlTypeId := 50026,
CONST.UIA_ThumbControlTypeId := 50027,
CONST.UIA_DataGridControlTypeId := 50028,
CONST.UIA_DataItemControlTypeId := 50029,
CONST.UIA_DocumentControlTypeId := 50030,
CONST.UIA_SplitButtonControlTypeId := 50031,
CONST.UIA_WindowControlTypeId := 50032,
CONST.UIA_PaneControlTypeId := 50033,
CONST.UIA_HeaderControlTypeId := 50034,
CONST.UIA_HeaderItemControlTypeId := 50035,
CONST.UIA_TableControlTypeId := 50036,
CONST.UIA_TitleBarControlTypeId := 50037,
CONST.UIA_SeparatorControlTypeId := 50038,
CONST.UIA_SemanticZoomControlTypeId := 50039,
CONST.UIA_AppBarControlTypeId := 50040

UIA_GetElementFromWindow(hwnd) => IUIAutomation.ElementFromHandle(hwnd)
UIA_GetElementFromPoint(x, y) => IUIAutomation.ElementFromPoint(x | y << 32)
UIA_GetElementUnderMouse() => IUIAutomation.ElementFromPoint((DllCall("GetCursorPos", "int64*", &pt := 0), pt))
UIA_GetElementFocused() => IUIAutomation.GetFocusedElement()
UIA_SetElementValue(el, value) => el.GetCurrentPattern(CONST.UIA_ValuePatternId).SetValue(value)
UIA_InvokeElement(el) => el.GetCurrentPattern(CONST.UIA_InvokePatternId).Invoke()

class IUIAutomation {
    static Ptr := ComObjValue(this._ := ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{30CBE57D-D9D0-452A-AB13-7AC5AC4825EE}"))
    static CompareElements(el1, el2) => (ComCall(3, this, "ptr", el1, "ptr", el2, "int*", &areSame := 0), areSame)
    static CompareRuntimeIds(runtimeId1, runtimeId2) => (ComCall(4, this, "ptr", runtimeId1, "ptr", runtimeId2, "int*", &areSame := 0), areSame)
    static GetRootElement() => (ComCall(5, this, "ptr*", &root := 0), IUIAutomationElement(root))
    static ElementFromHandle(hwnd) => (ComCall(6, this, "ptr", hwnd, "ptr*", &element := 0), IUIAutomationElement(element))
    static ElementFromPoint(pt) => (ComCall(7, this, "int64", pt, "ptr*", &element := 0), IUIAutomationElement(element))
    static GetFocusedElement() => (ComCall(8, this, "ptr*", &element := 0), IUIAutomationElement(element))
    ; GetRootElementBuildCach
    ; ElementFromHandleBuildCach
    ; ElementFromPointBuildCach
    ; GetFocusedElementBuildCach
    static CreateTreeWalker(pCondition) => (ComCall(13, this, "ptr", pCondition, "ptr*", &walker := 0), IUIAutomationTreeWalker(walker))
    static ControlViewWalker() => (ComCall(14, this, "ptr*", &walker := 0), IUIAutomationTreeWalker(walker))
    static ContentViewWalker() => (ComCall(15, this, "ptr*", &walker := 0), IUIAutomationTreeWalker(walker))
    static RawViewWalker() => (ComCall(16, this, "ptr*", &walker := 0), IUIAutomationTreeWalker(walker))
    ; RawViewCondition
    ; ControlViewCondition
    ; ContentViewCondition
    ; CreateCacheRequest
    ; CreateTrueCondition
    ; CreateFalseCondition
    static CreatePropertyCondition(propertyId, value) => (ComCall(23, this, "int", propertyId, "ptr", CreateVariant(__UIAGetPropertyVarType(propertyId), value), "ptr*", &newCondition := 0), IUIAutomationPropertyCondition(newCondition))
    static CreatePropertyConditionEx(propertyId, value, flags) => (ComCall(24, this, "int", propertyId, "ptr", CreateVariant(__UIAGetPropertyVarType(propertyId), value), "int", flags, "ptr*", &newCondition := 0), IUIAutomationPropertyCondition(newCondition))
    static CreateAndCondition(condition1, condition2) => (ComCall(25, this, "ptr", condition1, "ptr", condition2, "ptr*", &newCondition := 0), IUIAutomationAndCondition(newCondition))
    ; CreateAndConditionFromArray
    ; CreateAndConditionFromNativeArray
    ; CreateOrCondition
    ; CreateOrConditionFromArray
    ; CreateOrConditionFromNativeArray
    ; CreateNotCondition
    static AddAutomationEventHandler(eventId, element, scope, cacheRequest, handler) => ComCall(32, this, "int", eventId, "ptr", element, "int", scope, "ptr", cacheRequest, "ptr", handler)
    static RemoveAutomationEventHandler(eventId, element, handler) => ComCall(33, this, "int", eventId, "ptr", element, "ptr", handler)
    ; AddPropertyChangedEventHandlerNativeArray
    ; AddPropertyChangedEventHandler
    ; RemovePropertyChangedEventHandler
    ; AddStructureChangedEventHandler
    ; RemoveStructureChangedEventHandler
    static AddFocusChangedEventHandler(cacheRequest, handler) => ComCall(39, this, "ptr", cacheRequest, "ptr", handler)
    static RemoveFocusChangedEventHandler(handler) => ComCall(40, this, "ptr", handler)
    static RemoveAllEventHandlers() => ComCall(41, this)
    static AutoSetFocus => (ComCall(58, this, "int*", &autoSetFocus := 0), autoSetFocus)
}

class IUIAutomationElement extends IUnknown {
    SetFocus() => ComCall(3, this)
    GetRuntimeId() => (ComCall(4, this, "ptr*", &runtimeId := 0), ComValue(0x2003, runtimeId))
    FindFirst(condition, scope := 4) => (ComCall(5, this, "int", scope, "ptr", condition, "ptr*", &found := 0), IUIAutomationElement(found))
    FindAll(condition, scope := 4) => (ComCall(6, this, "int", scope, "ptr", condition, "ptr*", &found := 0), IUIAutomationElementArray(found))
    ; FindFirstBuildCache
    ; FindAllBuildCache
    ; BuildUpdatedCache
    GetCurrentPropertyValue(propertyId) => (ComCall(10, this, "int", propertyId, "ptr", val := CreateVariant()), VariantValue(val))
    ; GetCurrentPropertyValueEx
    ; GetCachedPropertyValue
    ; GetCachedPropertyValueEx
    ; GetCurrentPatternAs
    ; GetCachedPatternAs
    GetCurrentPattern(patternId) => (ComCall(16, this, "int", patternId, "ptr*", &patternObject := 0), __UIAGetPatternClass(patternId)(patternObject))
    ; GetCachedPattern
    ; GetCachedParent
    ; GetCachedChildren
    ; CurrentProcessId
    ; CurrentControlType
    ; CurrentLocalizedControlType
    CurrentName => (ComCall(23, this, "ptr*", &retVal := 0), BStrToString(retVal))
    CurrentAcceleratorKey => (ComCall(24, this, "ptr*", &retVal := 0), BStrToString(retVal))
    ; CurrentAccessKey
    ; CurrentHasKeyboardFocus
    ; CurrentIsKeyboardFocusable
    ; CurrentIsEnabled
    CurrentAutomationId => (ComCall(29, this, "ptr*", &retVal := 0), BStrToString(retVal))
    ; CurrentClassName
    ; CurrentHelpText
    ; CurrentCulture
    ; CurrentIsControlElement
    ; CurrentIsContentElement
    ; CurrentIsPassword
    ; CurrentNativeWindowHandle
    ; CurrentItemType
    ; CurrentIsOffscreen
    ; CurrentOrientation
    ; CurrentFrameworkId
    ; CurrentIsRequiredForForm
    ; CurrentItemStatus
    CurrentBoundingRectangle => (ComCall(43, this, "ptr", retVal := Buffer(16)), { Left: NumGet(retVal, "int"), Top: NumGet(retVal, 4, "int"), Right: NumGet(retVal, 8, "int"), Bottom: NumGet(retVal, 12, "int") })
    ; CurrentLabeledBy
    ; CurrentAriaRole
    ; CurrentAriaProperties
    ; CurrentIsDataValidForForm
    ; CurrentControllerFor
    ; CurrentDescribedBy
    ; CurrentFlowsTo
    ; CurrentProviderDescription
    ; CachedProcessId
    ; CachedControlType
    ; CachedLocalizedControlType
    ; CachedName
    ; CachedAcceleratorKey
    ; CachedAccessKey
    ; CachedHasKeyboardFocus
    ; CachedIsKeyboardFocusable
    ; CachedIsEnabled
    ; CachedAutomationId
    ; CachedClassName
    ; CachedHelpText
    ; CachedCulture
    ; CachedIsControlElement
    ; CachedIsContentElement
    ; CachedIsPassword
    ; CachedNativeWindowHandle
    ; CachedItemType
    ; CachedIsOffscreen
    ; CachedOrientation
    ; CachedFrameworkId
    ; CachedIsRequiredForForm
    ; CachedItemStatus
    ; CachedBoundingRectangle
    ; CachedLabeledBy
    ; CachedAriaRole
    ; CachedAriaProperties
    ; CachedIsDataValidForForm
    ; CachedControllerFor
    ; CachedDescribedBy
    ; CachedFlowsTo
    ; CachedProviderDescription
    GetClickablePoint(&x, &y) {
        ComCall(84, this, "int64*", &clickable := 0, "int*", &gotClickable := 0)
        if gotClickable {
            x := clickable & 0xffffffff
            y := clickable >> 32
        }
        return gotClickable
    }
    ; CurrentOptimizeForVisualContent
    ; CachedOptimizeForVisualContent
    ; CurrentLiveSetting
    ; CachedLiveSetting
    ; CurrentFlowsFrom
    ; CachedFlowsFrom
    ; ShowContextMenu
    ; CurrentIsPeripheral
    ; CachedIsPeripheral
    ; CurrentPositionInSet
    ; CurrentSizeOfSet
    ; CurrentLevel
    ; CurrentAnnotationTypes
    ; CurrentAnnotationObjects
    ; CachedPositionInSet
    ; CachedSizeOfSet
    ; CachedLevel
    ; CachedAnnotationTypes
    ; CachedAnnotationObjects
    ; CurrentLandmarkType
    ; CurrentLocalizedLandmarkType
    ; CachedLandmarkType
    ; CachedLocalizedLandmarkType
    ; CurrentFullDescription
    ; CachedFullDescription
    FindFirstWithOptions(condition, traversalOptions, root, scope) => (ComCall(110, this, "int", scope, "ptr", condition, "int", traversalOptions, "ptr", root, "ptr*", &found := 0), IUIAutomationElement(found))
    ; FindAllWithOptions
    ; FindFirstWithOptionsBuildCache
    ; FindAllWithOptionsBuildCache
    ; GetCurrentMetadataValue
    ; CurrentHeadingLevel
    ; CachedHeadingLevel
    ; CurrentIsDialog
    ; CachedIsDialog
}

class IUIAutomationElementArray extends IUnknown {
    __Item[index] => this.GetElement(index - 1)
    __Enum(numberOfVars) {
        i := 0
        len := this.Length
        return fn
        fn(&element) {
            if i++ == len
                return false
            element := this.GetElement(i - 1)
            return true
        }
    }
    Length => (ComCall(3, this, "int*", &length := 0), length)
    GetElement(index) => (ComCall(4, this, "int", index, "ptr*", &element := 0), IUIAutomationElement(element))
}

class IUIAutomationTreeWalker extends IUnknown {
    GetParentElement(element) => (ComCall(3, this, "ptr", element, "ptr*", &parent := 0), IUIAutomationElement(parent))
    GetFirstChildElement(element) => (ComCall(4, this, "ptr", element, "ptr*", &first := 0), IUIAutomationElement(first))
    GetLastChildElement(element) => (ComCall(5, this, "ptr", element, "ptr*", &last := 0), IUIAutomationElement(last))
    GetNextSiblingElement(element) => (ComCall(6, this, "ptr", element, "ptr*", &next := 0), IUIAutomationElement(next))
    GetPreviousSiblingElement(element) => (ComCall(7, this, "ptr", element, "ptr*", &previous := 0), IUIAutomationElement(previous))
    NormalizeElement(element) => (ComCall(8, this, "ptr", element, "ptr*", &normalized := 0), IUIAutomationElement(normalized))
    GetParentElementBuildCache(element, cacheRequest) => (ComCall(9, this, "ptr", element, "ptr", cacheRequest, "ptr*", &parent := 0), IUIAutomationElement(parent))
    GetFirstChildElementBuildCache(element, cacheRequest) => (ComCall(10, this, "ptr", element, "ptr", cacheRequest, "ptr*", &first := 0), IUIAutomationElement(first))
    GetLastChildElementBuildCache(element, cacheRequest) => (ComCall(11, this, "ptr", element, "ptr", cacheRequest, "ptr*", &last := 0), IUIAutomationElement(last))
    GetNextSiblingElementBuildCache(element, cacheRequest) => (ComCall(12, this, "ptr", element, "ptr", cacheRequest, "ptr*", &next := 0), IUIAutomationElement(next))
    GetPreviousSiblingElementBuildCache(element, cacheRequest) => (ComCall(13, this, "ptr", element, "ptr", cacheRequest, "ptr*", &previous := 0), IUIAutomationElement(previous))
    NormalizeElementBuildCache(element, cacheRequest) => (ComCall(14, this, "ptr", element, "ptr", cacheRequest, "ptr*", &normalized := 0), IUIAutomationElement(normalized))
    Condition() => (ComCall(15, this, "ptr*", &condition := 0), IUIAutomationCondition(condition))
}

class IUIAutomationPropertyCondition extends IUIAutomationCondition {
    PropertyId => (ComCall(3, this, "int*", &propertyId := 0), propertyId)
    PropertyValue => (ComCall(4, this, "ptr", propertyValue := CreateVariant()), VariantValue(propertyValue))
    PropertyConditionFlags => (ComCall(5, this, "int*", &flags := 0), flags)
}

class IUIAutomationCondition extends IUnknown {
}

class IUIAutomationAndCondition extends IUIAutomationCondition {
    ChildCount => (ComCall(3, this, "int*", &childCount := 0), childCount)
    ; GetChildrenAsNativeArray
    GetChildren() => (ComCall(5, this, "ptr*", &childArray := 0), ComValue(0x200d, childArray))
}

class IUIAutomationInvokePattern extends IUnknown {
    Invoke() => ComCall(3, this)
}

class IUIAutomationSelectionPattern extends IUnknown {
    GetCurrentSelection() => (ComCall(3, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))
    CurrentCanSelectMultiple => (ComCall(4, this, "int*", &retVal := 0), retVal)
    CurrentIsSelectionRequired => (ComCall(5, this, "int*", &retVal := 0), retVal)
    GetCachedSelection() => (ComCall(6, this, "ptr*", &retVal := 0), IUIAutomationElementArray(retVal))
    CachedCanSelectMultiple => (ComCall(7, this, "int*", &retVal := 0), retVal)
    CachedIsSelectionRequired => (ComCall(8, this, "int*", &retVal := 0), retVal)
}

class IUIAutomationValuePattern extends IUnknown {
    SetValue(val) => ComCall(3, this, "wstr", val)
    CurrentValue => (ComCall(4, this, "ptr*", &retVal := 0), BStrToString(retVal))
    CurrentIsReadOnly => (ComCall(5, this, "int*", &retVal := 0), retVal)
    CachedValue => (ComCall(6, this, "ptr*", &retVal := 0), BStrToString(retVal))
    CachedIsReadOnly => (ComCall(7, this, "int*", &retVal := 0), retVal)
}

class IUIAutomationRangeValuePattern extends IUnknown {
    SetValue(val) => ComCall(3, this, "double", val)
    CurrentValue => (ComCall(4, this, "double*", &retVal := 0), retVal)
    CurrentIsReadOnly => (ComCall(5, this, "int*", &retVal := 0), retVal)
    CurrentMaximum => (ComCall(6, this, "double*", &retVal := 0), retVal)
    CurrentMinimum => (ComCall(7, this, "double*", &retVal := 0), retVal)
    CurrentLargeChange => (ComCall(8, this, "double*", &retVal := 0), retVal)
    CurrentSmallChange => (ComCall(9, this, "double*", &retVal := 0), retVal)
    CachedValue => (ComCall(10, this, "double*", &retVal := 0), retVal)
    CachedIsReadOnly => (ComCall(11, this, "int*", &retVal := 0), retVal)
    CachedMaximum => (ComCall(12, this, "double*", &retVal := 0), retVal)
    CachedMinimum => (ComCall(13, this, "double*", &retVal := 0), retVal)
    CachedLargeChange => (ComCall(14, this, "double*", &retVal := 0), retVal)
    CachedSmallChange => (ComCall(15, this, "double*", &retVal := 0), retVal)
}

class IUIAutomationScrollPattern extends IUnknown {
    Scroll(horizontalAmount, verticalAmount) => ComCall(3, this, "int", horizontalAmount, "int", verticalAmount)
    SetScrollPercent(horizontalPercent, verticalPercent) => ComCall(4, this, "double", horizontalPercent, "double", verticalPercent)
    CurrentHorizontalScrollPercent => (ComCall(5, this, "double*", &retVal := 0), retVal)
    CurrentVerticalScrollPercent => (ComCall(6, this, "double*", &retVal := 0), retVal)
    CurrentHorizontalViewSize => (ComCall(7, this, "double*", &retVal := 0), retVal)
    CurrentVerticalViewSize => (ComCall(8, this, "double*", &retVal := 0), retVal)
    CurrentHorizontallyScrollable => (ComCall(9, this, "int*", &retVal := 0), retVal)
    CurrentVerticallyScrollable => (ComCall(10, this, "int*", &retVal := 0), retVal)
    CachedHorizontalScrollPercent => (ComCall(11, this, "double*", &retVal := 0), retVal)
    CachedVerticalScrollPercent => (ComCall(12, this, "double*", &retVal := 0), retVal)
    CachedHorizontalViewSize => (ComCall(13, this, "double*", &retVal := 0), retVal)
    CachedVerticalViewSize => (ComCall(14, this, "double*", &retVal := 0), retVal)
    CachedHorizontallyScrollable => (ComCall(15, this, "int*", &retVal := 0), retVal)
    CachedVerticallyScrollable => (ComCall(16, this, "int*", &retVal := 0), retVal)
}

class IUIAutomationExpandCollapsePattern extends IUnknown {
}

class IUIAutomationGridPattern extends IUnknown {
    GetItem(row, column) => (ComCall(3, this, "int", row, "int", column, "ptr*", &element := 0), IUIAutomationGridItemPattern(element))
    CurrentRowCount => (ComCall(4, this, "int*", &retVal := 0), retVal)
    CurrentColumnCount => (ComCall(5, this, "int*", &retVal := 0), retVal)
    CachedRowCount => (ComCall(6, this, "int*", &retVal := 0), retVal)
    CachedColumnCount => (ComCall(7, this, "int*", &retVal := 0), retVal)
}

class IUIAutomationGridItemPattern extends IUnknown {
    CurrentContainingGrid => (ComCall(3, this, "ptr*", &retVal := 0), IUIAutomationElement(retVal))
    CurrentRow => (ComCall(4, this, "int*", &retVal := 0), retVal)
    CurrentColumn => (ComCall(5, this, "int*", &retVal := 0), retVal)
    CurrentRowSpan => (ComCall(6, this, "int*", &retVal := 0), retVal)
    CurrentColumnSpan => (ComCall(7, this, "int*", &retVal := 0), retVal)
    CachedContainingGrid => (ComCall(8, this, "ptr*", &retVal := 0), IUIAutomationElement(retVal))
    CachedRow => (ComCall(9, this, "int*", &retVal := 0), retVal)
    CachedColumn => (ComCall(10, this, "int*", &retVal := 0), retVal)
    CachedRowSpan => (ComCall(11, this, "int*", &retVal := 0), retVal)
    CachedColumnSpan => (ComCall(12, this, "int*", &retVal := 0), retVal)
}

class IUIAutomationMultipleViewPattern extends IUnknown {
    GetViewName(view) => (ComCall(3, this, "int", view, "ptr*", &name := 0), BStrToString(name))
    SetCurrentView(view) => ComCall(4, this, "int", view)
    CurrentCurrentView => (ComCall(5, this, "int*", &retVal := 0), retVal)
    GetCurrentSupportedViews() => (ComCall(6, this, "ptr*", &retVal := 0), ComValue(0x2003, retVal))
    CachedCurrentView => (ComCall(7, this, "int*", &retVal := 0), retVal)
    GetCachedSupportedViews() => (ComCall(8, this, "ptr*", &retVal := 0), ComValue(0x2003, retVal))
}

class IUIAutomationWindowPattern extends IUnknown {
}

class IUIAutomationSelectionItemPattern extends IUnknown {
    Select() => ComCall(3, this)
    AddToSelection() => ComCall(4, this)
    RemoveFromSelection() => ComCall(5, this)
    CurrentIsSelected => (ComCall(6, this, "int*", &retVal := 0), retVal)
    CurrentSelectionContainer => (ComCall(7, this, "ptr*", &retVal := 0), IUIAutomationElement(retVal))
    ; CachedIsSelected
    ; CachedSelectionContainer
}

class IUIAutomationDockPattern extends IUnknown {
}

class IUIAutomationTablePattern extends IUnknown {
}

class IUIAutomationTableItemPattern extends IUnknown {
}

class IUIAutomationTextPattern extends IUnknown {
    RangeFromPoint(pt) => (ComCall(3, this, "int64", pt, "ptr*", &range := 0), IUIAutomationTextRange(range))
    RangeFromChild(child) => (ComCall(4, this, "ptr", child, "ptr*", &range := 0), IUIAutomationTextRange(range))
    GetSelection() => (ComCall(5, this, "ptr*", &ranges := 0), IUIAutomationTextRangeArray(ranges))
    GetVisibleRanges() => (ComCall(6, this, "ptr*", &ranges := 0), IUIAutomationTextRangeArray(ranges))
    DocumentRange() => (ComCall(7, this, "ptr*", &range := 0), IUIAutomationTextRange(range))
    SupportedTextSelection => (ComCall(8, this, "int*", &supportedTextSelection := 0), supportedTextSelection)
}

class IUIAutomationTextRangeArray extends IUnknown {
    Length => (ComCall(3, this, "int*", &length := 0), length)
    GetElement(index) => (ComCall(4, this, "int", index, "ptr*", &element := 0), IUIAutomationTextRange(element))
}

class IUIAutomationTextRange extends IUnknown {
    ExpandToEnclosingUnit(textUnit) => ComCall(6, this, "int", textUnit)
    GetAttributeValue(attr) => (ComCall(9, this, "int", attr, "ptr", value := CreateVariant()), VariantValue(value))
    GetBoundingRectangles() => (ComCall(10, this, "ptr*", &boundingRects := 0), ComValue(0x2005, boundingRects))
    GetText(maxLength := -1) => (ComCall(12, this, "int", maxLength, "ptr*", &text := 0), BStrToString(text))
}

class IUIAutomationTogglePattern extends IUnknown {
}

class IUIAutomationTransformPattern extends IUnknown {
}

class IUIAutomationScrollItemPattern extends IUnknown {
}

class IUIAutomationLegacyIAccessiblePattern extends IUnknown {
    CurrentState => (ComCall(11, this, "uint*", &pdwState := 0), pdwState)
}

class IUIAutomationItemContainerPattern extends IUnknown {
    FindItemByProperty(pStartAfter, propertyId, value) => (ComCall(3, this, "ptr", pStartAfter, "int", propertyId, "ptr", CreateVariant(__UIAGetPropertyVarType(propertyId), value), "ptr*", &pFound := 0), IUIAutomationElement(pFound))
}

class IUIAutomationVirtualizedItemPattern extends IUnknown {
}

class IUIAutomationSynchronizedInputPattern extends IUnknown {
}

class IUIAutomationObjectModelPattern extends IUnknown {
}

class IUIAutomationAnnotationPattern extends IUnknown {
}

class IUIAutomationTextPattern2 extends IUnknown {
    GetCaretRange(&isActive) => (ComCall(10, this, "int*", &isActive := 0, "ptr*", &range := 0), IUIAutomationTextRange(range))
}

class IUIAutomationStylesPattern extends IUnknown {
}

class IUIAutomationSpreadsheetPattern extends IUnknown {
}

class IUIAutomationSpreadsheetItemPattern extends IUnknown {
}

class IUIAutomationTransformPattern2IdPattern extends IUnknown {
}

class IUIAutomationTextChildPattern extends IUnknown {
}

class IUIAutomationDragPattern extends IUnknown {
}

class IUIAutomationDropTargetPattern extends IUnknown {
}

class IUIAutomationTextEditPattern extends IUnknown {
}

class IUIAutomationCustomNavigationPattern extends IUnknown {
}


class IUIAutomationSelectionPattern2 extends IUIAutomationSelectionPattern {
    CurrentFirstSelectedItem => (ComCall(10, this, "ptr*", &retVal := 0), IUIAutomationElement(retVal))
    CurrentLastSelectedItem => (ComCall(11, this, "ptr*", &retVal := 0), IUIAutomationElement(retVal))
    CurrentCurrentSelectedItem => (ComCall(12, this, "ptr*", &retVal := 0), IUIAutomationElement(retVal))
    CurrentItemCount => (ComCall(13, this, "int*", &count := 0), count)
    CachedFirstSelectedItem => (ComCall(14, this, "ptr*", &retVal := 0), IUIAutomationElement(retVal))
    CachedLastSelectedItem => (ComCall(15, this, "ptr*", &retVal := 0), IUIAutomationElement(retVal))
    CachedCurrentSelectedItem => (ComCall(16, this, "ptr*", &retVal := 0), IUIAutomationElement(retVal))
    CachedItemCount => (ComCall(17, this, "int*", &count := 0), count)
}

class IUIAutomationEventHandler {
    __New(handleAutomationEvent) {
        static QueryInterface := CallbackCreate(this.QueryInterface)
        static AddRefOrRelease := CallbackCreate(this.AddRefOrRelease)
        this.HandleAutomationEvent := CallbackCreate(handleAutomationEvent)
        this.Vt := Buffer(5 * A_PtrSize)
        this.Ptr := this.Vt.Ptr
        NumPut("ptr", this.Ptr + A_PtrSize, "ptr", QueryInterface, "ptr", AddRefOrRelease, "ptr", AddRefOrRelease, "ptr", this.HandleAutomationEvent, this.Vt)
    }
    __Delete() => CallbackFree(this.HandleAutomationEvent)
    QueryInterface(riid, ppvObject) {
        h := NumGet(riid, "int64"), l := NumGet(riid, 8, "int64")
        if (h == 0 && l == 0x46000000000000c0) || (h == 0x4E22F12E146C3C17 && l == 0x699CB7B994F8278C) {
            NumPut("ptr", this, ppvObject)
            return 0
        }
        return 0x80004002
    }
    AddRefOrRelease() => 0
}

class IUIAutomationFocusChangedEventHandler {
    __New(handleFocusChangedEvent) {
        static QueryInterface := CallbackCreate(this.QueryInterface)
        static AddRefOrRelease := CallbackCreate(this.AddRefOrRelease)
        this.HandleFocusChangedEvent := CallbackCreate(HandleFocusChangedEvent)
        this.Vt := Buffer(5 * A_PtrSize)
        this.Ptr := this.Vt.Ptr
        NumPut("ptr", this.Ptr + A_PtrSize, "ptr", QueryInterface, "ptr", AddRefOrRelease, "ptr", AddRefOrRelease, "ptr", this.HandleFocusChangedEvent, this.Vt)
    }
    __Delete() => CallbackFree(this.HandleFocusChangedEvent)
    QueryInterface(riid, ppvObject) {
        h := NumGet(riid, "int64"), l := NumGet(riid, 8, "int64")
        if (h == 0 && l == 0x46000000000000C0) || (h == 0X42905C69C270F6B5 && l == 0x689416977F7A4597) {
            NumPut("ptr", this, ppvObject)
            return 0
        }
        return 0x80004002
    }
    AddRefOrRelease() => 0
}

__UIAGetPropertyVarType(propertyId) {
    static m := [CONST.VT_I4 | CONST.VT_ARRAY, CONST.VT_R8 | CONST.VT_ARRAY, CONST.VT_I4, CONST.VT_I4, CONST.VT_BSTR, CONST.VT_BSTR, CONST.VT_BSTR, CONST.VT_BSTR, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BSTR, CONST.VT_BSTR, CONST.VT_BSTR, CONST.VT_R8 | CONST.VT_ARRAY, CONST.VT_I4, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_UNKNOWN, CONST.VT_BOOL, CONST.VT_I4, CONST.VT_BSTR, CONST.VT_BOOL, CONST.VT_I4, CONST.VT_BSTR, CONST.VT_BOOL, CONST.VT_BSTR, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BSTR, CONST.VT_BOOL, CONST.VT_R8, CONST.VT_BOOL, CONST.VT_R8, CONST.VT_R8, CONST.VT_R8, CONST.VT_R8, CONST.VT_R8, CONST.VT_R8, CONST.VT_R8, CONST.VT_R8, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_UNKNOWN | CONST.VT_ARRAY, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_I4, CONST.VT_I4, CONST.VT_I4, CONST.VT_I4, CONST.VT_I4, CONST.VT_I4, CONST.VT_UNKNOWN, CONST.VT_I4, CONST.VT_I4, CONST.VT_I4, CONST.VT_I4 | CONST.VT_ARRAY, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_I4, CONST.VT_I4, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_UNKNOWN, CONST.VT_UNKNOWN | CONST.VT_ARRAY, CONST.VT_UNKNOWN | CONST.VT_ARRAY, CONST.VT_I4, CONST.VT_UNKNOWN | CONST.VT_ARRAY, CONST.VT_UNKNOWN | CONST.VT_ARRAY, CONST.VT_I4, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_I4, CONST.VT_BSTR, CONST.VT_BSTR, CONST.VT_BSTR, CONST.VT_I4, CONST.VT_I4, CONST.VT_BSTR, CONST.VT_BSTR, CONST.VT_UNKNOWN | CONST.VT_ARRAY, CONST.VT_BSTR, CONST.VT_BSTR, CONST.VT_BSTR, CONST.VT_BOOL, CONST.VT_UNKNOWN, CONST.VT_UNKNOWN, CONST.VT_UNKNOWN, CONST.VT_BSTR, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_I4, CONST.VT_BSTR, CONST.VT_BSTR, CONST.VT_BSTR, CONST.VT_UNKNOWN, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_I4, CONST.VT_BSTR, CONST.VT_I4, CONST.VT_BSTR, CONST.VT_BSTR, CONST.VT_I4, CONST.VT_BSTR, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BSTR, CONST.VT_UNKNOWN | CONST.VT_ARRAY, CONST.VT_I4 | CONST.VT_ARRAY, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_I4, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BSTR, CONST.VT_BSTR | CONST.VT_ARRAY, CONST.VT_BOOL, CONST.VT_BSTR, CONST.VT_BSTR | CONST.VT_ARRAY, CONST.VT_UNKNOWN | CONST.VT_ARRAY, CONST.VT_R8, CONST.VT_R8, CONST.VT_R8, CONST.VT_UNKNOWN, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_BOOL, CONST.VT_I4, CONST.VT_I4, CONST.VT_I4, CONST.VT_I4 | CONST.VT_ARRAY, CONST.VT_I4 | CONST.VT_ARRAY, CONST.VT_I4, CONST.VT_BSTR, CONST.VT_BSTR, CONST.VT_I4, CONST.VT_I4 | CONST.VT_ARRAY, CONST.VT_I4, CONST.VT_I4, CONST.VT_R8 | CONST.VT_ARRAY, CONST.VT_R8 | CONST.VT_ARRAY, CONST.VT_R8, CONST.VT_R8 | CONST.VT_ARRAY, CONST.VT_BOOL, CONST.VT_UNKNOWN, CONST.VT_UNKNOWN, CONST.VT_UNKNOWN, CONST.VT_I4, CONST.VT_I4, CONST.VT_BOOL]
    return m[propertyId - 29999]
}

__UIAGetPatternClass(patternId) {
    static m := [IUIAutomationInvokePattern, IUIAutomationSelectionPattern, IUIAutomationValuePattern, IUIAutomationRangeValuePattern, IUIAutomationScrollPattern, IUIAutomationExpandCollapsePattern, IUIAutomationGridPattern, IUIAutomationGridItemPattern, IUIAutomationMultipleViewPattern, IUIAutomationWindowPattern, IUIAutomationSelectionItemPattern, IUIAutomationDockPattern, IUIAutomationTablePattern, IUIAutomationTableItemPattern, IUIAutomationTextPattern, IUIAutomationTogglePattern, IUIAutomationTransformPattern, IUIAutomationScrollItemPattern, IUIAutomationLegacyIAccessiblePattern, IUIAutomationItemContainerPattern, IUIAutomationVirtualizedItemPattern, IUIAutomationSynchronizedInputPattern, IUIAutomationObjectModelPattern, IUIAutomationAnnotationPattern, IUIAutomationTextPattern2, IUIAutomationStylesPattern, IUIAutomationSpreadsheetPattern, IUIAutomationSpreadsheetItemPattern, IUIAutomationTransformPattern2IdPattern, IUIAutomationTextChildPattern, IUIAutomationDragPattern, IUIAutomationDropTargetPattern, IUIAutomationTextEditPattern, IUIAutomationCustomNavigationPattern, IUIAutomationSelectionPattern2]
    return m[patternId - 9999]
}