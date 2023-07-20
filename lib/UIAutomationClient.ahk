UIA_WaitChild(parent, condition, scope := 4, timeout := 0) {
    if timeout {
        t := A_TickCount
        found := parent.FindFirst(scope, condition)
        while !found && (A_TickCount - t) <= timeout {
            Sleep(1)
            found := parent.FindFirst(scope, condition)
        }
    }
    else {
        found := parent.FindFirst(scope, condition)
        while !found {
            Sleep(1)
            found := parent.FindFirst(scope, condition)
        }
    }
    return found
}

class Variant {
    Ptr => this.__Var.Ptr
    __New(type := 0, value := 0) {
        this.__Var := Buffer(24, 0)
        this.__Ref := ComValue(0x400C, this.__Var.Ptr)
        this.__Ref[] := ComValue(type, value)
    }
    __Item {
        get => this.__Ref[]
        set => this.__Ref[] := value
    }
    __Delete() => this.__Ref[] := 0
}

class BSTR {
    static FromString(str) => this(DllCall("OleAut32\SysAllocString", "str", str, "ptr"))
    __New(ptr := 0) => this.Ptr := ptr
    __Delete() => DllCall("OleAut32\SysFreeString", "ptr", this)
    ToString() => this.Ptr ? StrGet(this.Ptr) : ""
}

class NumNativeArray {
    __New(type, length, ptr?) {
        static bytesCount := {char: 1, uchar: 1, short: 2, ushort: 2, int: 4, uint: 4, int64: 8, uint64: 8, ptr: A_PtrSize, uptr: A_PtrSize, float: 4, double: 8}
        this.Type := type
        this.Length := length
        this.ElementSize := bytesCount.%type%
        this.Size := length * this.ElementSize
        if IsSet(ptr) {
            this.Ptr := ptr
        }
        else {
            this.Ptr := DllCall("Ole32\CoTaskMemAlloc", "uint", this.Size, "ptr")
        }
    }
    __Delete() => DllCall("Ole32\CoTaskMemFree", "ptr", this)
    __Item[i] {
        get => NumGet(this, i * this.ElementSize, this.Type)
        set => NumPut(this.Type, value, this, i * this.ElementSize)
    }
    __Enum(_) => (&v) => (A_Index <= this.Length ? (v := this[A_Index - 1], true) : false)
}

class ComObjNativeArray {
    __New(type, length, ptr?) {
        this.Type := type
        this.Length := length
        this.Size := length * A_PtrSize
        if IsSet(ptr) {
            this.Ptr := ptr
        }
        else {
            this.Ptr := DllCall("Ole32\CoTaskMemAlloc", "uint", this.Size, "ptr")
        }
    }
    __Delete() {
        loop this.Length {
            ObjRelease(NumGet(this, A_PtrSize * (A_Index - 1), "ptr"))
        }
        DllCall("Ole32\CoTaskMemFree", "ptr", this)
    }
    __Item[i] {
        get {
            if p := NumGet(this, i * A_PtrSize, "ptr") {
                ObjAddRef(p)
                if this.Type == ComValue {
                    return ComValue(0xD, p)
                }
                else {
                    return this.Type.Call(p)
                }
            }
        }
    }
    __Enum(_) => (&v) => (A_Index <= this.Length ? (v := this[A_Index - 1], true) : false)
}

class StructNativeArray extends NumNativeArray {
    __New(type, length, ptr?) {
        this.Type := type
        this.Length := length
        this.ElementSize := type.Prototype.Size
        this.Size := length * this.ElementSize
        if IsSet(ptr) {
            this.Ptr := ptr
        }
        else {
            this.Ptr := DllCall("Ole32\CoTaskMemAlloc", "uint", this.Size, "ptr")
        }
    }
    __Delete() => DllCall("Ole32\CoTaskMemFree", "ptr", this)
    __Item[i] {
        get {
            ele := this.Type.Call()
            DllCall("RtlCopyMemory", "ptr", ele, "ptr", this.Ptr + i * this.ElementSize, "uptr", this.ElementSize.Size)
            return ele
        }
    }
}

class RECT {
    Size => 16
    __New() {
        this.__Buffer := Buffer(this.Size)
        this.Ptr := this.__Buffer.Ptr
    }
    left {
        get => NumGet(this, 0, "int")
        set => NumPut("int", value, this, 0)
    }
    top {
        get => NumGet(this, 4, "int")
        set => NumPut("int", value, this, 4)
    }
    right {
        get => NumGet(this, 8, "int")
        set => NumPut("int", value, this, 8)
    }
    bottom {
        get => NumGet(this, 12, "int")
        set => NumPut("int", value, this, 12)
    }
}

class CUIAutomation {
    static Call() => IUIAutomation(ComObject("{E22AD333-B25F-460C-83D0-0581107395C9}", "{AAE072DA-29E3-413D-87A7-192DBF81ED10}"))
}

class IUnknownWrapperBase {
    Ptr => this.ComObj.Ptr
    __New(ptr) {
        if ptr is Integer {
            this.ComObj := ComValue(13, ptr)
        }
        else {
            this.ComObj := ptr
        }
    }
}

class IRawElementProviderSimple extends IUnknownWrapperBase {
    ProviderOptions {
        get {
            ComCall(3, this, "int*", &retVal := 0)
            return retVal
        }
    }
    GetPatternProvider(patternId) {
        ComCall(4, this, "int", patternId, "ptr*", retVal := 0)
        if retVal
            return ComValue(0xD, retVal)
    }
    GetPropertyValue(propertyId) {
        ComCall(5, this, "int", propertyId, "ptr", retVal := Variant())
        return retVal[]
    }
    HostRawElementProvider {
        get {
            ComCall(6, this, "ptr*", &retVal := 0)
            if retVal
                return IRawElementProviderSimple(retVal)
        }
    }
}

class IUIAutomation extends IUnknownWrapperBase {
    CompareElements(el1, el2) {
        ComCall(3, this, "ptr", el1, "ptr", el2, "int*", &retVal := 0)
        return retVal
    }
    CompareRuntimeIds(runtimeId1, runtimeId2) {
        ComCall(4, this, "ptr", runtimeId1, "ptr", runtimeId2, "int*", &retVal := 0)
        return retVal
    }
    GetRootElement() {
        ComCall(5, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    ElementFromHandle(hwnd) {
        ComCall(6, this, "ptr", hwnd, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    ElementFromPoint(pt) {
        if pt is Object
            pt := UIAUtils_ObjectToPoint(pt)
        ComCall(7, this, "int64", pt, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    GetFocusedElement() {
        ComCall(8, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    GetRootElementBuildCache(cacheRequest) {
        ComCall(9, this, "ptr", cacheRequest, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    ElementFromHandleBuildCache(hwnd, cacheRequest) {
        ComCall(10, this, "ptr", hwnd, "ptr", cacheRequest, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    ElementFromPointBuildCache(pt, cacheRequest) {
        if pt is Object
            pt := UIAUtils_ObjectToPoint(pt)
        ComCall(11, this, "int64", pt, "ptr", cacheRequest, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    GetFocusedElementBuildCache(cacheRequest) {
        ComCall(12, this, "ptr", cacheRequest, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    CreateTreeWalker(pCondition) {
        ComCall(13, this, "ptr", pCondition, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationTreeWalker(retVal)
    }
    ControlViewWalker {
        get {
            ComCall(14, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationTreeWalker(retVal)
        }
    }
    ContentViewWalker {
        get {
            ComCall(15, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationTreeWalker(retVal)
        }
    }
    RawViewWalker {
        get {
            ComCall(16, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationTreeWalker(retVal)
        }
    }
    RawViewCondition {
        get {
            ComCall(17, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationCondition(retVal)
        }
    }
    ControlViewCondition {
        get {
            ComCall(18, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationCondition(retVal)
        }
    }
    ContentViewCondition {
        get {
            ComCall(19, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationCondition(retVal)
        }
    }
    CreateCacheRequest() {
        ComCall(20, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationCacheRequest(retVal)
    }
    CreateTrueCondition() {
        ComCall(21, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationCondition(retVal)
    }
    CreateFalseCondition() {
        ComCall(22, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationCondition(retVal)
    }
    CreatePropertyCondition(propertyId, value) {
        value := Variant(UIAUtils_GetPropertyVariantType(propertyId), value)
        ComCall(23, this, "int", propertyId, "ptr", value, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationCondition(retVal)
    }
    CreatePropertyConditionEx(propertyId, value, flags) {
        value := Variant(UIAUtils_GetPropertyVariantType(propertyId), value)
        ComCall(24, this, "int", propertyId, "ptr", value, "int", flags, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationCondition(retVal)
    }
    CreateAndCondition(condition1, condition2) {
        ComCall(25, this, "ptr", condition1, "ptr", condition2, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationAndCondition(retVal)
    }
    CreateAndConditionFromArray(conditions) {
        if conditions is Array
            conditions := UIAUtils_IUnknownArrayToSafeArray(conditions)
        ComCall(26, this, "ptr", conditions, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationAndCondition(retVal)
    }
    CreateAndConditionFromNativeArray(conditions, conditionCount) {
        conditionCount := conditionCount ?? conditions.Length
        if conditions is Array
            conditions := UIAUtils_IUnknownArrayToNativeArray(conditions)
        ComCall(27, this, "ptr", conditions, "int", conditionCount, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationAndCondition(retVal)
    }
    CreateOrCondition(condition1, condition2) {
        ComCall(28, this, "ptr", condition1, "ptr", condition2, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationOrCondition(retVal)
    }
    CreateOrConditionFromArray(conditions) {
        if conditions is Array
            conditions := UIAUtils_IUnknownArrayToSafeArray(conditions)
        ComCall(29, this, "ptr", conditions, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationOrCondition(retVal)
    }
    CreateOrConditionFromNativeArray(conditions, conditionCount?) {
        conditionCount := conditionCount ?? conditions.Length
        if conditions is Array
            conditions := UIAUtils_IUnknownArrayToNativeArray(conditions)
        ComCall(30, this, "ptr", conditions, "int", conditionCount, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationOrCondition(retVal)
    }
    CreateNotCondition(condition) {
        ComCall(31, this, "ptr", condition, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationNotCondition(retVal)
    }
    AddAutomationEventHandler(eventId, element, scope, cacheRequest, handler) {
        ComCall(32, this, "int", eventId, "ptr", element, "int", scope, "ptr", cacheRequest, "ptr", handler)
    }
    RemoveAutomationEventHandler(eventId, element, handler) {
        ComCall(33, this, "int", eventId, "ptr", element, "ptr", handler)
    }
    AddPropertyChangedEventHandlerNativeArray(element, scope, cacheRequest, handler, propertyArray, propertyCount?) {
        propertyCount := propertyCount ?? propertyArray.Length
        if propertyArray is Array
            propertyArray := UIAUtils_ArrayToNativeArray("int", propertyArray)
        ComCall(34, this, "ptr", element, "int", scope, "ptr", cacheRequest, "ptr", handler, "ptr", propertyArray, "int", propertyCount)
    }
    AddPropertyChangedEventHandler(element, scope, cacheRequest, handler, propertyArray) {
        if propertyArray is Array
            propertyArray := UIAUtils_ArrayToSafeArray(3, propertyArray)
        ComCall(35, this, "ptr", element, "int", scope, "ptr", cacheRequest, "ptr", handler, "ptr", propertyArray)
    }
    RemovePropertyChangedEventHandler(element, handler) {
        ComCall(36, this, "ptr", element, "ptr", handler)
    }
    AddStructureChangedEventHandler(element, scope, cacheRequest, handler) {
        ComCall(37, this, "ptr", element, "int", scope, "ptr", cacheRequest, "ptr", handler)
    }
    RemoveStructureChangedEventHandler(element, handler) {
        ComCall(38, this, "ptr", element, "ptr", handler)
    }
    AddFocusChangedEventHandler(cacheRequest, handler) {
        ComCall(39, this, "ptr", cacheRequest, "ptr", handler)
    }
    RemoveFocusChangedEventHandler(handler) {
        ComCall(40, this, "ptr", handler)
    }
    RemoveAllEventHandlers() {
        ComCall(41, this)
    }
    IntNativeArrayToSafeArray(array, arrayCount) {
        ComCall(42, this, "ptr", array, "int", arrayCount, "ptr*", &retVal := 0)
        if retVal
            return ComValue(0x2003, retVal)
    }
    IntSafeArrayToNativeArray(intArray) {
        ComCall(43, this, "ptr", intArray, "ptr*", &array := 0, "int*", &retVal := 0)
        array := array ? NumNativeArray("int", retVal, array) : ""
        return array
    }
    RectToVariant(rc) {
        if !rc.HasOwnProp("Ptr")
            rc := UIAUtils_ObjectToRect(rc)
        ComCall(44, this, "ptr", rc, "ptr", retVal := Variant())
        return retVal
    }
    VariantToRect(var) {
        ComCall(45, this, "ptr", var, "ptr", retVal := RECT())
        return retVal
    }
    SafeArrayToRectNativeArray(rects, &rectArray) {
        ComCall(46, this, "ptr", rects, "ptr*", &rectArray := 0, "int*", &retVal := 0)
        rectArray := rectArray ? StructNativeArray(RECT, retVal, rectArray) : ""
        return retVal
    }
    CreateProxyFactoryEntry(factory) {
        ComCall(47, this, "ptr", factory, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationProxyFactoryEntry(retVal)
    }
    ProxyFactoryMapping {
        get {
            ComCall(48, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationProxyFactoryMapping(retVal)
        }
    }
    GetPropertyProgrammaticName(property) {
        ComCall(49, this, "int", property, "ptr*", retVal := BSTR())
        return retVal.ToString()
    }
    GetPatternProgrammaticName(pattern) {
        ComCall(50, this, "int", pattern, "ptr*", retVal := BSTR())
        return retVal.ToString()
    }
    PollForPotentialSupportedPatterns(pElement, &patternIds, &patternNames) {
        ComCall(51, this, "ptr", pElement, "ptr*", &patternIds := 0, "ptr*", &patternNames := 0)
        patternIds := patternIds ? UIAUtils_SafeArrayToArray(3, patternIds) : ""
        patternNames := patternNames ? UIAUtils_SafeArrayToArray(8, patternNames) : ""
    }
    PollForPotentialSupportedProperties(pElement, &propertyIds, &propertyNames) {
        ComCall(52, this, "ptr", pElement, "ptr*", &propertyIds := 0, "ptr*", &propertyNames := 0)
        propertyIds := propertyIds ? UIAUtils_SafeArrayToArray(3, propertyIds) : ""
        propertyNames := propertyNames ? UIAUtils_SafeArrayToArray(8, propertyNames) : ""
    }
    CheckNotSupported(value) {
        if value is Integer {
            value := Variant(3, value)
        }
        ComCall(53, this, "ptr", value, "int*", &retVal := 0)
        return retVal
    }
    ReservedNotSupportedValue {
        get {
            ComCall(54, this, "ptr*", &retVal := 0)
            if retVal
                return ComValue(0xD, retVal)
        }
    }
    ReservedMixedAttributeValue {
        get {
            ComCall(55, this, "ptr*", &retVal := 0)
            if retVal
                return ComValue(0xD, retVal)
        }
    }
    ElementFromIAccessible(accessible, childId) {
        ComCall(56, this, "ptr", accessible, "int", childId, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    ElementFromIAccessibleBuildCache(accessible, childId, cacheRequest) {
        ComCall(57, this, "ptr", accessible, "int", childId, "ptr", cacheRequest, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    AutoSetFocus {
        get {
            ComCall(58, this, "int*", &retVal := 0)
            return retVal
        }
        set => ComCall(59, this, "int", value)
    }
    ConnectionTimeout {
        get {
            ComCall(60, this, "uint*", &retVal := 0)
            return retVal
        }
        set => ComCall(61, this, "uint", value)
    }
    TransactionTimeout {
        get {
            ComCall(62, this, "uint*", &retVal := 0)
            return retVal
        }
        set => ComCall(63, this, "uint", value)
    }
    AddTextEditTextChangedEventHandler(element, scope, textEditChangeType, cacheRequest, handler) {
        ComCall(64, this, "ptr", element, "int", scope, "int", textEditChangeType, "ptr", cacheRequest, "ptr", handler)
    }
    RemoveTextEditTextChangedEventHandler(element, handler) {
        ComCall(65, this, "ptr", element, "ptr", handler)
    }
    AddChangesEventHandler(element, scope, changeTypes, changesCount, pCacheRequest, handler) {
        if changeTypes is Array
            changeTypes := UIAUtils_ArrayToNativeArray("int", changeTypes)
        ComCall(66, this, "ptr", element, "int", scope, "ptr", changeTypes, "int", changesCount, "ptr", pCacheRequest, "ptr", handler)
    }
    RemoveChangesEventHandler(element, handler) {
        ComCall(67, this, "ptr", element, "ptr", handler)
    }
    AddNotificationEventHandler(element, scope, cacheRequest, handler) {
        ComCall(68, this, "ptr", element, "int", scope, "ptr", cacheRequest, "ptr", handler)
    }
    RemoveNotificationEventHandler(element, handler) {
        ComCall(69, this, "ptr", element, "ptr", handler)
    }
    CreateEventHandlerGroup() {
        ComCall(70, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationEventHandlerGroup(retVal)
    }
    AddEventHandlerGroup(element, handlerGroup) {
        ComCall(71, this, "ptr", element, "ptr", handlerGroup)
    }
    RemoveEventHandlerGroup(element, handlerGroup) {
        ComCall(72, this, "ptr", element, "ptr", handlerGroup)
    }
    ConnectionRecoveryBehavior {
        get {
            ComCall(73, this, "int*", &retVal := 0)
            return retVal
        }
        set => ComCall(74, this, "int", value)
    }
    CoalesceEvents {
        get {
            ComCall(75, this, "int*", &retVal := 0)
            return retVal
        }
        set => ComCall(76, this, "int", value)
    }
    AddActiveTextPositionChangedEventHandler(element, scope, cacheRequest, handler) {
        ComCall(77, this, "ptr", element, "int", scope, "ptr", cacheRequest, "ptr", handler)
    }
    RemoveActiveTextPositionChangedEventHandler(element, handler) {
        ComCall(78, this, "ptr", element, "ptr", handler)
    }
}
class IUIAutomationAndCondition extends IUIAutomationCondition {
    ChildCount {
        get {
            ComCall(3, this, "int*", &retVal := 0)
            return retVal
        }
    }
    GetChildrenAsNativeArray() {
        ComCall(4, this, "ptr*", &childArray := 0, "int*", &childArrayCount := 0)
        childArray := childArray ? ComObjNativeArray(IUIAutomationCondition, childArrayCount, childArray) : ""
        return childArray
    }
    GetChildren() {
        ComCall(5, this, "ptr*", &retVal := 0)
        if retVal
            return UIAUtils_IUnknownSafeArrayToArray(retVal, IUIAutomationCondition)
    }
}
class IUIAutomationAnnotationPattern extends IUnknownWrapperBase {
    CurrentAnnotationTypeId {
        get {
            ComCall(3, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentAnnotationTypeName {
        get {
            ComCall(4, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentAuthor {
        get {
            ComCall(5, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentDateTime {
        get {
            ComCall(6, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentTarget {
        get {
            ComCall(7, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElement(retVal)
        }
    }
    CachedAnnotationTypeId {
        get {
            ComCall(8, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedAnnotationTypeName {
        get {
            ComCall(9, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedAuthor {
        get {
            ComCall(10, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedDateTime {
        get {
            ComCall(11, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedTarget {
        get {
            ComCall(12, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElement(retVal)
        }
    }
}
class IUIAutomationBoolCondition extends IUIAutomationCondition {
    BooleanValue {
        get {
            ComCall(3, this, "int*", &retVal := 0)
            return retVal
        }
    }
}
class IUIAutomationCacheRequest extends IUnknownWrapperBase {
    AddProperty(propertyId) {
        ComCall(3, this, "int", propertyId)
    }
    AddPattern(patternId) {
        ComCall(4, this, "int", patternId)
    }
    Clone() {
        ComCall(5, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationCacheRequest(retVal)
    }
    TreeScope {
        get {
            ComCall(6, this, "int*", &retVal := 0)
            return retVal
        }
        set => ComCall(7, this, "int", value)
    }
    TreeFilter {
        get {
            ComCall(8, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationCondition(retVal)
        }
        set => ComCall(9, this, "ptr", Value)
    }
    AutomationElementMode {
        get {
            ComCall(10, this, "int*", &retVal := 0)
            return retVal
        }
        set => ComCall(11, this, "int", value)
    }
}
class IUIAutomationCondition extends IUnknownWrapperBase {
}
class IUIAutomationCustomNavigationPattern extends IUnknownWrapperBase {
    Navigate(direction) {
        ComCall(3, this, "int", direction, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
}
class IUIAutomationDockPattern extends IUnknownWrapperBase {
    SetDockPosition(dockPos) {
        ComCall(3, this, "int", dockPos)
    }
    CurrentDockPosition {
        get {
            ComCall(4, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedDockPosition {
        get {
            ComCall(5, this, "int*", &retVal := 0)
            return retVal
        }
    }
}
class IUIAutomationDragPattern extends IUnknownWrapperBase {
    CurrentIsGrabbed {
        get {
            ComCall(3, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedIsGrabbed {
        get {
            ComCall(4, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentDropEffect {
        get {
            ComCall(5, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedDropEffect {
        get {
            ComCall(6, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentDropEffects {
        get {
            ComCall(7, this, "ptr*", &retVal := 0)
            if retVal
                return UIAUtils_SafeArrayToArray(8, retVal)
        }
    }
    CachedDropEffects {
        get {
            ComCall(8, this, "ptr*", &retVal := 0)
            if retVal
                return UIAUtils_SafeArrayToArray(8, retVal)
        }
    }
    GetCurrentGrabbedItems() {
        ComCall(9, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    GetCachedGrabbedItems() {
        ComCall(10, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
}
class IUIAutomationDropTargetPattern extends IUnknownWrapperBase {
    CurrentDropTargetEffect {
        get {
            ComCall(3, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedDropTargetEffect {
        get {
            ComCall(4, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentDropTargetEffects {
        get {
            ComCall(5, this, "ptr*", &retVal := 0)
            if retVal
                return UIAUtils_SafeArrayToArray(8, retVal)
        }
    }
    CachedDropTargetEffects {
        get {
            ComCall(6, this, "ptr*", &retVal := 0)
            if retVal
                return UIAUtils_SafeArrayToArray(8, retVal)
        }
    }
}
class IUIAutomationElement extends IUnknownWrapperBase {
    SetFocus() {
        ComCall(3, this)
    }
    GetRuntimeId() {
        ComCall(4, this, "ptr*", &retVal := 0)
        if retVal
            return UIAUtils_SafeArrayToArray(3, retVal)
    }
    FindFirst(scope, condition) {
        ComCall(5, this, "int", scope, "ptr", condition, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    FindAll(scope, condition) {
        ComCall(6, this, "int", scope, "ptr", condition, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    FindFirstBuildCache(scope, condition, cacheRequest) {
        ComCall(7, this, "int", scope, "ptr", condition, "ptr", cacheRequest, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    FindAllBuildCache(scope, condition, cacheRequest) {
        ComCall(8, this, "int", scope, "ptr", condition, "ptr", cacheRequest, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    BuildUpdatedCache(cacheRequest) {
        ComCall(9, this, "ptr", cacheRequest, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    GetCurrentPropertyValue(propertyId) {
        retVal := Variant()
        ComCall(10, this, "int", propertyId, "ptr", retVal)
        return retVal[]
    }
    GetCurrentPropertyValueEx(propertyId, ignoreDefaultValue) {
        retVal := Variant()
        ComCall(11, this, "int", propertyId, "int", ignoreDefaultValue, "ptr", retVal)
        return retVal[]
    }
    GetCachedPropertyValue(propertyId) {
        retVal := Variant()
        ComCall(12, this, "int", propertyId, "ptr", retVal)
        return retVal[]
    }
    GetCachedPropertyValueEx(propertyId, ignoreDefaultValue) {
        retVal := Variant()
        ComCall(13, this, "int", propertyId, "int", ignoreDefaultValue, "ptr", retVal)
        return retVal[]
    }
    GetCurrentPatternAs(patternId, riid) {
        ComCall(14, this, "int", patternId, "ptr", riid, "ptr*", &retVal := 0)
        if retVal
            return UIAUtils_GetPatternInterface(patternId)(retVal)
    }
    GetCachedPatternAs(patternId, riid) {
        ComCall(15, this, "int", patternId, "ptr", riid, "ptr*", &retVal := 0)
        if retVal
            return UIAUtils_GetPatternInterface(patternId)(retVal)
    }
    GetCurrentPattern(patternId) {
        ComCall(16, this, "int", patternId, "ptr*", &retVal := 0)
        if retVal
            return UIAUtils_GetPatternInterface(patternId)(retVal)
    }
    GetCachedPattern(patternId) {
        ComCall(17, this, "int", patternId, "ptr*", &retVal := 0)
        if retVal
            return UIAUtils_GetPatternInterface(patternId)(retVal)
    }
    GetCachedParent() {
        ComCall(18, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    GetCachedChildren() {
        ComCall(19, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    CurrentProcessId {
        get {
            ComCall(20, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentControlType {
        get {
            ComCall(21, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentLocalizedControlType {
        get {
            ComCall(22, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentName {
        get {
            ComCall(23, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentAcceleratorKey {
        get {
            ComCall(24, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentAccessKey {
        get {
            ComCall(25, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentHasKeyboardFocus {
        get {
            ComCall(26, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentIsKeyboardFocusable {
        get {
            ComCall(27, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentIsEnabled {
        get {
            ComCall(28, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentAutomationId {
        get {
            ComCall(29, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentClassName {
        get {
            ComCall(30, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentHelpText {
        get {
            ComCall(31, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentCulture {
        get {
            ComCall(32, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentIsControlElement {
        get {
            ComCall(33, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentIsContentElement {
        get {
            ComCall(34, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentIsPassword {
        get {
            ComCall(35, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentNativeWindowHandle {
        get {
            ComCall(36, this, "ptr*", &retVal := 0)
            return retVal
        }
    }
    CurrentItemType {
        get {
            ComCall(37, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentIsOffscreen {
        get {
            ComCall(38, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentOrientation {
        get {
            ComCall(39, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentFrameworkId {
        get {
            ComCall(40, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentIsRequiredForForm {
        get {
            ComCall(41, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentItemStatus {
        get {
            ComCall(42, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentBoundingRectangle {
        get {
            ComCall(43, this, "ptr", retVal := RECT())
            return retVal
        }
    }
    CurrentLabeledBy {
        get {
            ComCall(44, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElement(retVal)
        }
    }
    CurrentAriaRole {
        get {
            ComCall(45, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentAriaProperties {
        get {
            ComCall(46, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentIsDataValidForForm {
        get {
            ComCall(47, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentControllerFor {
        get {
            ComCall(48, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElementArray(retVal)
        }
    }
    CurrentDescribedBy {
        get {
            ComCall(49, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElementArray(retVal)
        }
    }
    CurrentFlowsTo {
        get {
            ComCall(50, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElementArray(retVal)
        }
    }
    CurrentProviderDescription {
        get {
            ComCall(51, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedProcessId {
        get {
            ComCall(52, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedControlType {
        get {
            ComCall(53, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedLocalizedControlType {
        get {
            ComCall(54, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedName {
        get {
            ComCall(55, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedAcceleratorKey {
        get {
            ComCall(56, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedAccessKey {
        get {
            ComCall(57, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedHasKeyboardFocus {
        get {
            ComCall(58, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedIsKeyboardFocusable {
        get {
            ComCall(59, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedIsEnabled {
        get {
            ComCall(60, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedAutomationId {
        get {
            ComCall(61, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedClassName {
        get {
            ComCall(62, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedHelpText {
        get {
            ComCall(63, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedCulture {
        get {
            ComCall(64, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedIsControlElement {
        get {
            ComCall(65, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedIsContentElement {
        get {
            ComCall(66, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedIsPassword {
        get {
            ComCall(67, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedNativeWindowHandle {
        get {
            ComCall(68, this, "ptr*", &retVal := 0)
            return retVal
        }
    }
    CachedItemType {
        get {
            ComCall(69, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedIsOffscreen {
        get {
            ComCall(70, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedOrientation {
        get {
            ComCall(71, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedFrameworkId {
        get {
            ComCall(72, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedIsRequiredForForm {
        get {
            ComCall(73, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedItemStatus {
        get {
            ComCall(74, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedBoundingRectangle {
        get {
            ComCall(75, this, "ptr", retVal := RECT())
            return retVal
        }
    }
    CachedLabeledBy {
        get {
            ComCall(76, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElement(retVal)
        }
    }
    CachedAriaRole {
        get {
            ComCall(77, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedAriaProperties {
        get {
            ComCall(78, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedIsDataValidForForm {
        get {
            ComCall(79, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedControllerFor {
        get {
            ComCall(80, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElementArray(retVal)
        }
    }
    CachedDescribedBy {
        get {
            ComCall(81, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElementArray(retVal)
        }
    }
    CachedFlowsTo {
        get {
            ComCall(82, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElementArray(retVal)
        }
    }
    CachedProviderDescription {
        get {
            ComCall(83, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    GetClickablePoint() {
        ComCall(84, this, "int64*", &clickable := 0, "int*", &retVal := 0)
        if retVal
            return UIAUtils_PointToObject(clickable)
    }
    CurrentOptimizeForVisualContent {
        get {
            ComCall(85, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedOptimizeForVisualContent {
        get {
            ComCall(86, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentLiveSetting {
        get {
            ComCall(87, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedLiveSetting {
        get {
            ComCall(88, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentFlowsFrom {
        get {
            ComCall(89, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElementArray(retVal)
        }
    }
    CachedFlowsFrom {
        get {
            ComCall(90, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElementArray(retVal)
        }
    }
    ShowContextMenu() {
        ComCall(91, this)
    }
    CurrentIsPeripheral {
        get {
            ComCall(92, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedIsPeripheral {
        get {
            ComCall(93, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentPositionInSet {
        get {
            ComCall(94, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentSizeOfSet {
        get {
            ComCall(95, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentLevel {
        get {
            ComCall(96, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentAnnotationTypes {
        get {
            ComCall(97, this, "ptr*", &retVal := 0)
            if retVal
                return UIAUtils_SafeArrayToArray(3, retVal)
        }
    }
    CurrentAnnotationObjects {
        get {
            ComCall(98, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElementArray(retVal)
        }
    }
    CachedPositionInSet {
        get {
            ComCall(99, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedSizeOfSet {
        get {
            ComCall(100, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedLevel {
        get {
            ComCall(101, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedAnnotationTypes {
        get {
            ComCall(102, this, "ptr*", &retVal := 0)
            if retVal
                return UIAUtils_SafeArrayToArray(3, retVal)
        }
    }
    CachedAnnotationObjects {
        get {
            ComCall(103, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElementArray(retVal)
        }
    }
    CurrentLandmarkType {
        get {
            ComCall(104, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentLocalizedLandmarkType {
        get {
            ComCall(105, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedLandmarkType {
        get {
            ComCall(106, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedLocalizedLandmarkType {
        get {
            ComCall(107, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentFullDescription {
        get {
            ComCall(108, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedFullDescription {
        get {
            ComCall(109, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    FindFirstWithOptions(scope, condition, traversalOptions, root) {
        ComCall(110, this, "int", scope, "ptr", condition, "int", traversalOptions, "ptr", root, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    FindAllWithOptions(scope, condition, traversalOptions, root) {
        ComCall(111, this, "int", scope, "ptr", condition, "int", traversalOptions, "ptr", root, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    FindFirstWithOptionsBuildCache(scope, condition, cacheRequest, traversalOptions, root) {
        ComCall(112, this, "int", scope, "ptr", condition, "ptr", cacheRequest, "int", traversalOptions, "ptr", root, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    FindAllWithOptionsBuildCache(scope, condition, cacheRequest, traversalOptions, root) {
        ComCall(113, this, "int", scope, "ptr", condition, "ptr", cacheRequest, "int", traversalOptions, "ptr", root, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    GetCurrentMetadataValue(targetId, metadataId) {
        ComCall(114, this, "int", targetId, "int", metadataId, "ptr", retVal := Variant())
        return retVal[]
    }
    CurrentHeadingLevel {
        get {
            ComCall(115, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedHeadingLevel {
        get {
            ComCall(116, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentIsDialog {
        get {
            ComCall(117, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedIsDialog {
        get {
            ComCall(118, this, "int*", &retVal := 0)
            return retVal
        }
    }
}
class IUIAutomationElementArray extends IUnknownWrapperBase {
    Length {
        get {
            ComCall(3, this, "int*", &retVal := 0)
            return retVal
        }
    }
    GetElement(index) {
        ComCall(4, this, "int", index, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
}
class IUIAutomationEventHandlerGroup extends IUnknownWrapperBase {
    AddActiveTextPositionChangedEventHandler(scope, cacheRequest, handler) {
        ComCall(3, this, "int", scope, "ptr", cacheRequest, "ptr", handler)
    }
    AddAutomationEventHandler(eventId, scope, cacheRequest, handler) {
        ComCall(4, this, "int", eventId, "int", scope, "ptr", cacheRequest, "ptr", handler)
    }
    AddChangesEventHandler(scope, changeTypes, changesCount, cacheRequest, handler) {
        if changeTypes is Array
            changeTypes := UIAUtils_ArrayToNativeArray("int", changeTypes)
        ComCall(5, this, "int", scope, "ptr", changeTypes, "int", changesCount, "ptr", cacheRequest, "ptr", handler)
    }
    AddNotificationEventHandler(scope, cacheRequest, handler) {
        ComCall(6, this, "int", scope, "ptr", cacheRequest, "ptr", handler)
    }
    AddPropertyChangedEventHandler(scope, cacheRequest, handler, propertyArray, propertyCount?) {
        propertyCount := propertyCount ?? propertyArray.Length
        if propertyArray is Array
            propertyArray := UIAUtils_ArrayToNativeArray("int", propertyArray)
        ComCall(7, this, "int", scope, "ptr", cacheRequest, "ptr", handler, "ptr", propertyArray, "int", propertyCount)
    }
    AddStructureChangedEventHandler(scope, cacheRequest, handler) {
        ComCall(8, this, "int", scope, "ptr", cacheRequest, "ptr", handler)
    }
    AddTextEditTextChangedEventHandler(scope, textEditChangeType, cacheRequest, handler) {
        ComCall(9, this, "int", scope, "int", textEditChangeType, "ptr", cacheRequest, "ptr", handler)
    }
}
class IUIAutomationExpandCollapsePattern extends IUnknownWrapperBase {
    Expand() {
        ComCall(3, this)
    }
    Collapse() {
        ComCall(4, this)
    }
    CurrentExpandCollapseState {
        get {
            ComCall(5, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedExpandCollapseState {
        get {
            ComCall(6, this, "int*", &retVal := 0)
            return retVal
        }
    }
}
class IUIAutomationGridItemPattern extends IUnknownWrapperBase {
    CurrentContainingGrid {
        get {
            ComCall(3, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElement(retVal)
        }
    }
    CurrentRow {
        get {
            ComCall(4, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentColumn {
        get {
            ComCall(5, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentRowSpan {
        get {
            ComCall(6, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentColumnSpan {
        get {
            ComCall(7, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedContainingGrid {
        get {
            ComCall(8, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElement(retVal)
        }
    }
    CachedRow {
        get {
            ComCall(9, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedColumn {
        get {
            ComCall(10, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedRowSpan {
        get {
            ComCall(11, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedColumnSpan {
        get {
            ComCall(12, this, "int*", &retVal := 0)
            return retVal
        }
    }
}
class IUIAutomationGridPattern extends IUnknownWrapperBase {
    GetItem(row, column) {
        ComCall(3, this, "int", row, "int", column, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    CurrentRowCount {
        get {
            ComCall(4, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentColumnCount {
        get {
            ComCall(5, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedRowCount {
        get {
            ComCall(6, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedColumnCount {
        get {
            ComCall(7, this, "int*", &retVal := 0)
            return retVal
        }
    }
}
class IUIAutomationInvokePattern extends IUnknownWrapperBase {
    Invoke() {
        ComCall(3, this)
    }
}
class IUIAutomationItemContainerPattern extends IUnknownWrapperBase {
    FindItemByProperty(pStartAfter, propertyId, value) {
        if !(value is Variant) {
            value := Variant(UIAUtils_GetPropertyVariantType(propertyId), value)
        }
        ComCall(3, this, "ptr", pStartAfter, "int", propertyId, "ptr", value, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
}
class IUIAutomationLegacyIAccessiblePattern extends IUnknownWrapperBase {
    Select() {
        ComCall(3, this)
    }
    DoDefaultAction() {
        ComCall(4, this)
    }
    SetValue(szValue) {
        ComCall(5, this, "str", szValue)
    }
    CurrentChildId {
        get {
            ComCall(6, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentName {
        get {
            ComCall(7, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentValue {
        get {
            ComCall(8, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentDescription {
        get {
            ComCall(9, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentRole {
        get {
            ComCall(10, this, "uint*", &retVal := 0)
            return retVal
        }
    }
    CurrentState {
        get {
            ComCall(11, this, "uint*", &retVal := 0)
            return retVal
        }
    }
    CurrentHelp {
        get {
            ComCall(12, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentKeyboardShortcut {
        get {
            ComCall(13, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    GetCurrentSelection() {
        ComCall(14, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    CurrentDefaultAction {
        get {
            ComCall(15, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedChildId {
        get {
            ComCall(16, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedName {
        get {
            ComCall(17, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedValue {
        get {
            ComCall(18, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedDescription {
        get {
            ComCall(19, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedRole {
        get {
            ComCall(20, this, "uint*", &retVal := 0)
            return retVal
        }
    }
    CachedState {
        get {
            ComCall(21, this, "uint*", &retVal := 0)
            return retVal
        }
    }
    CachedHelp {
        get {
            ComCall(22, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedKeyboardShortcut {
        get {
            ComCall(23, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    GetCachedSelection() {
        ComCall(24, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    CachedDefaultAction {
        get {
            ComCall(25, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    GetIAccessible() {
        ComCall(26, this, "ptr*", &retVal := 0)
        if retVal
            return ComObjFromPtr(retVal)
    }
}
class IUIAutomationMultipleViewPattern extends IUnknownWrapperBase {
    GetViewName(view) {
        ComCall(3, this, "int", view, "ptr*", retVal := BSTR())
        return retVal.ToString()
    }
    SetCurrentView(view) {
        ComCall(4, this, "int", view)
    }
    CurrentCurrentView {
        get {
            ComCall(5, this, "int*", &retVal := 0)
            return retVal
        }
    }
    GetCurrentSupportedViews() {
        ComCall(6, this, "ptr*", &retVal := 0)
        if retVal
            return UIAUtils_SafeArrayToArray(3, retVal)
    }
    CachedCurrentView {
        get {
            ComCall(7, this, "int*", &retVal := 0)
            return retVal
        }
    }
    GetCachedSupportedViews() {
        ComCall(8, this, "ptr*", &retVal := 0)
        if retVal
            return UIAUtils_SafeArrayToArray(3, retVal)
    }
}
class IUIAutomationNotCondition extends IUnknownWrapperBase {
    GetChild() {
        ComCall(3, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationCondition(retVal)
    }
}
class IUIAutomationObjectModelPattern extends IUnknownWrapperBase {
    GetUnderlyingObjectModel() {
        ComCall(3, this, "ptr*", &retVal := 0)
        if retVal
            return ComValue(0xD, retVal)
    }
}
class IUIAutomationOrCondition extends IUIAutomationCondition {
    ChildCount {
        get {
            ComCall(3, this, "int*", &retVal := 0)
            return retVal
        }
    }
    GetChildrenAsNativeArray() {
        ComCall(4, this, "ptr*", &childArray := 0, "int*", &childArrayCount := 0)
        childArray := childArray ? ComObjNativeArray(IUIAutomationCondition, childArrayCount, childArray) : ""
        return childArray
    }
    GetChildren() {
        ComCall(5, this, "ptr*", &retVal := 0)
        if retVal
            return UIAUtils_IUnknownSafeArrayToArray(retVal, IUIAutomationCondition)
    }
}
class IUIAutomationPropertyCondition extends IUIAutomationCondition {
    propertyId {
        get {
            ComCall(3, this, "int*", &retVal := 0)
            return retVal
        }
    }
    PropertyValue {
        get {
            ComCall(4, this, "ptr", retVal := Variant())
            return retVal[]
        }
    }
    PropertyConditionFlags {
        get {
            ComCall(5, this, "int*", &retVal := 0)
            return retVal
        }
    }
}
class IUIAutomationProxyFactory extends IUnknownWrapperBase {
    CreateProvider(hwnd, idObject, idChild) {
        ComCall(3, this, "ptr", hwnd, "int", idObject, "int", idChild, "ptr*", &retVal := 0)
        if retVal
            return IRawElementProviderSimple(retVal)
    }
    ProxyFactoryId {
        get {
            ComCall(4, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
}
class IUIAutomationProxyFactoryEntry extends IUnknownWrapperBase {
    ProxyFactory {
        get {
            ComCall(3, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationProxyFactory(retVal)
        }
    }
    ClassName {
        get {
            ComCall(4, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    ImageName {
        get {
            ComCall(5, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    AllowSubstringMatch {
        get {
            ComCall(6, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CanCheckBaseClass {
        get {
            ComCall(7, this, "int*", &retVal := 0)
            return retVal
        }
    }
    NeedsAdviseEvents {
        get {
            ComCall(8, this, "int*", &retVal := 0)
            return retVal
        }
    }
    SetWinEventsForAutomationEvent(eventId, propertyId, winEvents) {
        ComCall(9, this, "int", eventId, "int", propertyId, "ptr", winEvents)
    }
    GetWinEventsForAutomationEvent(eventId, propertyId) {
        ComCall(10, this, "int", eventId, "int", propertyId, "ptr*", &retVal := 0)
        if retVal
            return ComValue(0x17, retVal)
    }
}
class IUIAutomationProxyFactoryMapping extends IUnknownWrapperBase {
    count {
        get {
            ComCall(3, this, "uint*", &retVal := 0)
            return retVal
        }
    }
    GetTable() {
        ComCall(4, this, "ptr*", &retVal := 0)
        if retVal
            return UIAUtils_IUnknownSafeArrayToArray(retVal, IUIAutomationProxyFactoryEntry)
    }
    GetEntry(index) {
        ComCall(5, this, "uint", index, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationProxyFactoryEntry(retVal)
    }
    SetTable(factoryList) {
        ComCall(6, this, "ptr", factoryList)
    }
    InsertEntries(before, factoryList) {
        ComCall(7, this, "uint", before, "ptr", factoryList)
    }
    InsertEntry(before, factory) {
        ComCall(8, this, "uint", before, "ptr", factory)
    }
    RemoveEntry(index) {
        ComCall(9, this, "uint", index)
    }
    ClearTable() {
        ComCall(10, this)
    }
    RestoreDefaultTable() {
        ComCall(11, this)
    }
}
class IUIAutomationRangeValuePattern extends IUnknownWrapperBase {
    SetValue(val) {
        ComCall(3, this, "double", val)
    }
    CurrentValue {
        get {
            ComCall(4, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CurrentIsReadOnly {
        get {
            ComCall(5, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentMaximum {
        get {
            ComCall(6, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CurrentMinimum {
        get {
            ComCall(7, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CurrentLargeChange {
        get {
            ComCall(8, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CurrentSmallChange {
        get {
            ComCall(9, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CachedValue {
        get {
            ComCall(10, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CachedIsReadOnly {
        get {
            ComCall(11, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedMaximum {
        get {
            ComCall(12, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CachedMinimum {
        get {
            ComCall(13, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CachedLargeChange {
        get {
            ComCall(14, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CachedSmallChange {
        get {
            ComCall(15, this, "double*", &retVal := 0)
            return retVal
        }
    }
}
class IUIAutomationScrollItemPattern extends IUnknownWrapperBase {
    ScrollIntoView() {
        ComCall(3, this)
    }
}
class IUIAutomationScrollPattern extends IUnknownWrapperBase {
    Scroll(horizontalAmount, verticalAmount) {
        ComCall(3, this, "int", horizontalAmount, "int", verticalAmount)
    }
    SetScrollPercent(horizontalPercent, verticalPercent) {
        ComCall(4, this, "double", horizontalPercent, "double", verticalPercent)
    }
    CurrentHorizontalScrollPercent {
        get {
            ComCall(5, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CurrentVerticalScrollPercent {
        get {
            ComCall(6, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CurrentHorizontalViewSize {
        get {
            ComCall(7, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CurrentVerticalViewSize {
        get {
            ComCall(8, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CurrentHorizontallyScrollable {
        get {
            ComCall(9, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentVerticallyScrollable {
        get {
            ComCall(10, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedHorizontalScrollPercent {
        get {
            ComCall(11, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CachedVerticalScrollPercent {
        get {
            ComCall(12, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CachedHorizontalViewSize {
        get {
            ComCall(13, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CachedVerticalViewSize {
        get {
            ComCall(14, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CachedHorizontallyScrollable {
        get {
            ComCall(15, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedVerticallyScrollable {
        get {
            ComCall(16, this, "int*", &retVal := 0)
            return retVal
        }
    }
}
class IUIAutomationSelectionItemPattern extends IUnknownWrapperBase {
    Select() {
        ComCall(3, this)
    }
    AddToSelection() {
        ComCall(4, this)
    }
    RemoveFromSelection() {
        ComCall(5, this)
    }
    CurrentIsSelected {
        get {
            ComCall(6, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentSelectionContainer {
        get {
            ComCall(7, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElement(retVal)
        }
    }
    CachedIsSelected {
        get {
            ComCall(8, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedSelectionContainer {
        get {
            ComCall(9, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElement(retVal)
        }
    }
}
class IUIAutomationSelectionPattern extends IUnknownWrapperBase {
    GetCurrentSelection() {
        ComCall(3, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    CurrentCanSelectMultiple {
        get {
            ComCall(4, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentIsSelectionRequired {
        get {
            ComCall(5, this, "int*", &retVal := 0)
            return retVal
        }
    }
    GetCachedSelection() {
        ComCall(6, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    CachedCanSelectMultiple {
        get {
            ComCall(7, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedIsSelectionRequired {
        get {
            ComCall(8, this, "int*", &retVal := 0)
            return retVal
        }
    }
}
class IUIAutomationSelectionPattern2 extends IUIAutomationSelectionPattern {
    CurrentFirstSelectedItem {
        get {
            ComCall(9, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElement(retVal)
        }
    }
    CurrentLastSelectedItem {
        get {
            ComCall(10, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElement(retVal)
        }
    }
    CurrentCurrentSelectedItem {
        get {
            ComCall(11, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElement(retVal)
        }
    }
    CurrentItemCount {
        get {
            ComCall(12, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedFirstSelectedItem {
        get {
            ComCall(13, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElement(retVal)
        }
    }
    CachedLastSelectedItem {
        get {
            ComCall(14, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElement(retVal)
        }
    }
    CachedCurrentSelectedItem {
        get {
            ComCall(15, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElement(retVal)
        }
    }
    CachedItemCount {
        get {
            ComCall(16, this, "int*", &retVal := 0)
            return retVal
        }
    }
}
class IUIAutomationSpreadsheetItemPattern extends IUnknownWrapperBase {
    CurrentFormula {
        get {
            ComCall(3, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    GetCurrentAnnotationObjects() {
        ComCall(4, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    GetCurrentAnnotationTypes() {
        ComCall(5, this, "ptr*", &retVal := 0)
        if retVal
            return UIAUtils_SafeArrayToArray(3, retVal)
    }
    CachedFormula {
        get {
            ComCall(6, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    GetCachedAnnotationObjects() {
        ComCall(7, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    GetCachedAnnotationTypes() {
        ComCall(8, this, "ptr*", &retVal := 0)
        if retVal
            return UIAUtils_SafeArrayToArray(3, retVal)
    }
}
class IUIAutomationSpreadsheetPattern extends IUnknownWrapperBase {
    GetItemByName(name) {
        name := BSTR.FromString(name)
        ComCall(3, this, "ptr", name, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
}
class IUIAutomationStylesPattern extends IUnknownWrapperBase {
    CurrentStyleId {
        get {
            ComCall(3, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentStyleName {
        get {
            ComCall(4, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentFillColor {
        get {
            ComCall(5, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentFillPatternStyle {
        get {
            ComCall(6, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentShape {
        get {
            ComCall(7, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentFillPatternColor {
        get {
            ComCall(8, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentExtendedProperties {
        get {
            ComCall(9, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    GetCurrentExtendedPropertiesAsArray() {
        ComCall(10, this, "ptr*", &propertyArray := 0, "int*", &propertyCount := 0)
        if propertyArray {
            arr := []
            for pProperty in NumNativeArray("ptr", propertyCount, propertyArray) {
                pPropertyName := NumGet(pProperty, 0, "ptr")
                pPropertyValue := NumGet(pProperty, A_PtrSize, "ptr")
                arr.Push({
                    PropertyName: BSTR(pPropertyName).ToString(),
                    PropertyValue: BSTR(pPropertyValue).ToString()
                })
            }
            return arr
        }
    }
    CachedStyleId {
        get {
            ComCall(11, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedStyleName {
        get {
            ComCall(12, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedFillColor {
        get {
            ComCall(13, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedFillPatternStyle {
        get {
            ComCall(14, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedShape {
        get {
            ComCall(15, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedFillPatternColor {
        get {
            ComCall(16, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedExtendedProperties {
        get {
            ComCall(17, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    GetCachedExtendedPropertiesAsArray(&propertyArray, &propertyCount) {
        ComCall(18, this, "ptr*", &propertyArray := 0, "int*", &propertyCount := 0)
        if propertyArray {
            arr := []
            for pProperty in NumNativeArray("ptr", propertyCount, propertyArray) {
                pPropertyName := NumGet(pProperty, 0, "ptr")
                pPropertyValue := NumGet(pProperty, A_PtrSize, "ptr")
                arr.Push({
                    PropertyName: BSTR(pPropertyName).ToString(),
                    PropertyValue: BSTR(pPropertyValue).ToString()
                })
            }
            return arr
        }
    }
}
class IUIAutomationSynchronizedInputPattern extends IUnknownWrapperBase {
    StartListening(inputType) {
        ComCall(3, this, "int", inputType)
    }
    Cancel() {
        ComCall(4, this)
    }
}
class IUIAutomationTableItemPattern extends IUnknownWrapperBase {
    GetCurrentRowHeaderItems() {
        ComCall(3, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    GetCurrentColumnHeaderItems() {
        ComCall(4, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    GetCachedRowHeaderItems() {
        ComCall(5, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    GetCachedColumnHeaderItems() {
        ComCall(6, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
}
class IUIAutomationTablePattern extends IUnknownWrapperBase {
    GetCurrentRowHeaders() {
        ComCall(3, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    GetCurrentColumnHeaders() {
        ComCall(4, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    CurrentRowOrColumnMajor {
        get {
            ComCall(5, this, "int*", &retVal := 0)
            return retVal
        }
    }
    GetCachedRowHeaders() {
        ComCall(6, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    GetCachedColumnHeaders() {
        ComCall(7, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    CachedRowOrColumnMajor {
        get {
            ComCall(8, this, "int*", &retVal := 0)
            return retVal
        }
    }
}
class IUIAutomationTextChildPattern extends IUnknownWrapperBase {
    TextContainer {
        get {
            ComCall(3, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationElement(retVal)
        }
    }
    TextRange {
        get {
            ComCall(4, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationTextRange(retVal)
        }
    }
}
class IUIAutomationTextEditPattern extends IUnknownWrapperBase {
    RangeFromPoint(pt) {
        if pt is Object
            pt := UIAUtils_ObjectToPoint(pt)
        ComCall(3, this, "int64", pt, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationTextRange(retVal)
    }
    RangeFromChild(child) {
        ComCall(4, this, "ptr", child, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationTextRange(retVal)
    }
    GetSelection() {
        ComCall(5, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationTextRangeArray(retVal)
    }
    GetVisibleRanges() {
        ComCall(6, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationTextRangeArray(retVal)
    }
    DocumentRange {
        get {
            ComCall(7, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationTextRange(retVal)
        }
    }
    SupportedTextSelection {
        get {
            ComCall(8, this, "int*", &retVal := 0)
            return retVal
        }
    }
    GetActiveComposition() {
        ComCall(9, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationTextRange(retVal)
    }
    GetConversionTarget() {
        ComCall(10, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationTextRange(retVal)
    }
}
class IUIAutomationTextPattern extends IUnknownWrapperBase {
    RangeFromPoint(pt) {
        if pt is Object
            pt := UIAUtils_ObjectToPoint(pt)
        ComCall(3, this, "int64", pt, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationTextRange(retVal)
    }
    RangeFromChild(child) {
        ComCall(4, this, "ptr", child, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationTextRange(retVal)
    }
    GetSelection() {
        ComCall(5, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationTextRangeArray(retVal)
    }
    GetVisibleRanges() {
        ComCall(6, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationTextRangeArray(retVal)
    }
    DocumentRange {
        get {
            ComCall(7, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationTextRange(retVal)
        }
    }
    SupportedTextSelection {
        get {
            ComCall(8, this, "int*", &retVal := 0)
            return retVal
        }
    }
}
class IUIAutomationTextPattern2 extends IUIAutomationTextPattern {
    RangeFromAnnotation(annotation) {
        ComCall(9, this, "ptr", annotation, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationTextRange(retVal)
    }
    GetCaretRange(&isActive) {
        ComCall(10, this, "int*", &isActive := 0, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationTextRange(retVal)
    }
}
class IUIAutomationTextRange extends IUnknownWrapperBase {
    Clone() {
        ComCall(3, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationTextRange(retVal)
    }
    Compare(range) {
        ComCall(4, this, "ptr", range, "int*", &retVal := 0)
        return retVal
    }
    CompareEndpoints(srcEndPoint, range, targetEndPoint) {
        ComCall(5, this, "int", srcEndPoint, "ptr", range, "int", targetEndPoint, "int*", &retVal := 0)
        return retVal
    }
    ExpandToEnclosingUnit(textUnit) {
        ComCall(6, this, "int", textUnit)
    }
    FindAttribute(attr, val, backward) {
        if !(val is Variant) {
            val := Variant(UIAUtils_GetTextAttributeVariantType(attr), val)
        }
        ComCall(7, this, "int", attr, "ptr", val, "int", backward, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationTextRange(retVal)
    }
    FindText(text, backward, ignoreCase) {
        text := BSTR.FromString(text)
        ComCall(8, this, "ptr", text, "int", backward, "int", ignoreCase, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationTextRange(retVal)
    }
    GetAttributeValue(attr) {
        ComCall(9, this, "int", attr, "ptr", retVal := Variant())
        return retVal[]
    }
    GetBoundingRectangles() {
        ComCall(10, this, "ptr*", &retVal := 0)
        if retVal
            return UIAUtils_SafeArrayToArray(5, retVal)
    }
    GetEnclosingElement() {
        ComCall(11, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    GetText(maxLength) {
        ComCall(12, this, "int", maxLength, "ptr*", retVal := BSTR())
        return retVal.ToString()
    }
    Move(unit, count) {
        ComCall(13, this, "int", unit, "int", count, "int*", &retVal := 0)
        return retVal
    }
    MoveEndpointByUnit(endpoint, unit, count) {
        ComCall(14, this, "int", endpoint, "int", unit, "int", count, "int*", &retVal := 0)
        return retVal
    }
    MoveEndpointByRange(srcEndPoint, range, targetEndPoint) {
        ComCall(15, this, "int", srcEndPoint, "ptr", range, "int", targetEndPoint)
    }
    Select() {
        ComCall(16, this)
    }
    AddToSelection() {
        ComCall(17, this)
    }
    RemoveFromSelection() {
        ComCall(18, this)
    }
    ScrollIntoView(alignToTop) {
        ComCall(19, this, "int", alignToTop)
    }
    GetChildren() {
        ComCall(20, this, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    ShowContextMenu() {
        ComCall(21, this)
    }
    GetEnclosingElementBuildCache(cacheRequest) {
        ComCall(22, this, "ptr", cacheRequest, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    GetChildrenBuildCache(cacheRequest) {
        ComCall(23, this, "ptr", cacheRequest, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElementArray(retVal)
    }
    GetAttributeValues(attributeIds, attributeIdCount?) {
        attributeIdCount := attributeIdCount ?? attributeIds.Length
        if attributeIds is Array 
            attributeIds := UIAUtils_ArrayToNativeArray("int", attributeIds)
        ComCall(24, this, "ptr", attributeIds, "int", attributeIdCount, "ptr*", &retVal := 0)
        if retVal
            return UIAUtils_SafeArrayToArray(0xC, retVal)
    }
}
class IUIAutomationTextRangeArray extends IUnknownWrapperBase {
    Length {
        get {
            ComCall(3, this, "int*", &retVal := 0)
            return retVal
        }
    }
    GetElement(index) {
        ComCall(4, this, "int", index, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationTextRange(retVal)
    }
}
class IUIAutomationTogglePattern extends IUnknownWrapperBase {
    Toggle() {
        ComCall(3, this)
    }
    CurrentToggleState {
        get {
            ComCall(4, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedToggleState {
        get {
            ComCall(5, this, "int*", &retVal := 0)
            return retVal
        }
    }
}
class IUIAutomationTransformPattern extends IUnknownWrapperBase {
    Move(x, y) {
        ComCall(3, this, "double", x, "double", y)
    }
    Resize(width, height) {
        ComCall(4, this, "double", width, "double", height)
    }
    Rotate(degrees) {
        ComCall(5, this, "double", degrees)
    }
    CurrentCanMove {
        get {
            ComCall(6, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentCanResize {
        get {
            ComCall(7, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentCanRotate {
        get {
            ComCall(8, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedCanMove {
        get {
            ComCall(9, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedCanResize {
        get {
            ComCall(10, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedCanRotate {
        get {
            ComCall(11, this, "int*", &retVal := 0)
            return retVal
        }
    }
}
class IUIAutomationTransformPattern2 extends IUIAutomationTransformPattern {
    Zoom(zoomValue) {
        ComCall(12, this, "double", zoomValue)
    }
    ZoomByUnit(ZoomUnit) {
        ComCall(13, this, "int", ZoomUnit)
    }
    CurrentCanZoom {
        get {
            ComCall(14, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedCanZoom {
        get {
            ComCall(15, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentZoomLevel {
        get {
            ComCall(16, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CachedZoomLevel {
        get {
            ComCall(17, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CurrentZoomMinimum {
        get {
            ComCall(18, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CachedZoomMinimum {
        get {
            ComCall(19, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CurrentZoomMaximum {
        get {
            ComCall(20, this, "double*", &retVal := 0)
            return retVal
        }
    }
    CachedZoomMaximum {
        get {
            ComCall(21, this, "double*", &retVal := 0)
            return retVal
        }
    }
}
class IUIAutomationTreeWalker extends IUnknownWrapperBase {
    GetParentElement(element) {
        ComCall(3, this, "ptr", element, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    GetFirstChildElement(element) {
        ComCall(4, this, "ptr", element, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    GetLastChildElement(element) {
        ComCall(5, this, "ptr", element, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    GetNextSiblingElement(element) {
        ComCall(6, this, "ptr", element, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    GetPreviousSiblingElement(element) {
        ComCall(7, this, "ptr", element, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    NormalizeElement(element) {
        ComCall(8, this, "ptr", element, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    GetParentElementBuildCache(element, cacheRequest) {
        ComCall(9, this, "ptr", element, "ptr", cacheRequest, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    GetFirstChildElementBuildCache(element, cacheRequest) {
        ComCall(10, this, "ptr", element, "ptr", cacheRequest, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    GetLastChildElementBuildCache(element, cacheRequest) {
        ComCall(11, this, "ptr", element, "ptr", cacheRequest, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    GetNextSiblingElementBuildCache(element, cacheRequest) {
        ComCall(12, this, "ptr", element, "ptr", cacheRequest, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    GetPreviousSiblingElementBuildCache(element, cacheRequest) {
        ComCall(13, this, "ptr", element, "ptr", cacheRequest, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    NormalizeElementBuildCache(element, cacheRequest) {
        ComCall(14, this, "ptr", element, "ptr", cacheRequest, "ptr*", &retVal := 0)
        if retVal
            return IUIAutomationElement(retVal)
    }
    condition {
        get {
            ComCall(15, this, "ptr*", &retVal := 0)
            if retVal
                return IUIAutomationCondition(retVal)
        }
    }
}
class IUIAutomationValuePattern extends IUnknownWrapperBase {
    SetValue(val) {
        val := BSTR.FromString(val)
        ComCall(3, this, "ptr", val)
    }
    CurrentValue {
        get {
            ComCall(4, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CurrentIsReadOnly {
        get {
            ComCall(5, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedValue {
        get {
            ComCall(6, this, "ptr*", retVal := BSTR())
            return retVal.ToString()
        }
    }
    CachedIsReadOnly {
        get {
            ComCall(7, this, "int*", &retVal := 0)
            return retVal
        }
    }
}
class IUIAutomationVirtualizedItemPattern extends IUnknownWrapperBase {
    Realize() {
        ComCall(3, this)
    }
}
class IUIAutomationWindowPattern extends IUnknownWrapperBase {
    Close() {
        ComCall(3, this)
    }
    WaitForInputIdle(milliseconds) {
        ComCall(4, this, "int", milliseconds, "int*", &retVal := 0)
        return retVal
    }
    SetWindowVisualState(state) {
        ComCall(5, this, "int", state)
    }
    CurrentCanMaximize {
        get {
            ComCall(6, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentCanMinimize {
        get {
            ComCall(7, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentIsModal {
        get {
            ComCall(8, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentIsTopmost {
        get {
            ComCall(9, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentWindowVisualState {
        get {
            ComCall(10, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CurrentWindowInteractionState {
        get {
            ComCall(11, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedCanMaximize {
        get {
            ComCall(12, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedCanMinimize {
        get {
            ComCall(13, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedIsModal {
        get {
            ComCall(14, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedIsTopmost {
        get {
            ComCall(15, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedWindowVisualState {
        get {
            ComCall(16, this, "int*", &retVal := 0)
            return retVal
        }
    }
    CachedWindowInteractionState {
        get {
            ComCall(17, this, "int*", &retVal := 0)
            return retVal
        }
    }
}

class UIAutomationEventHandlerBase {
    __New(function) {
        this.__Function := function
        this.__pQueryInterface := CallbackCreate(QueryInterface)
        this.__pAddRefOrRelease := CallbackCreate(() => 0)
        this.__pHandleEvent := CallbackCreate(this.__HandleEvent.Bind(this), , this.__HandleEvent.MaxParams - 1)
        this.__VirtualTable := Buffer(5 * A_PtrSize)
        this.Ptr := this.__VirtualTable.Ptr
        NumPut(
            "ptr", this.Ptr + A_PtrSize,
            "ptr", this.__pQueryInterface,
            "ptr", this.__pAddRefOrRelease,
            "ptr", this.__pAddRefOrRelease,
            "ptr", this.__pHandleEvent,
            this.__VirtualTable
        )
        DllCall("ole32\CLSIDFromString", "str", %this.__Class%.Guid, "ptr", thisGuid := Buffer(16), "hresult")
        thisGuidH := NumGet(thisGuid, 0, "int64")
        thisGuidL := NumGet(thisGuid, 8, "int64")
        QueryInterface(self, riid, ppvObject) {
            h := NumGet(riid, 0, "int64")
            l := NumGet(riid, 8, "int64")
            if (h == thisGuidH && l == thisGuidL) || (h == 0 && l == 0x46000000000000c0) {
                NumPut("ptr", self, ppvObject)
                return 0
            }
            DllCall('ole32\StringFromGUID2', "ptr", riid, "wstr", str := "{00000000-0000-0000-0000-000000000000}", "int", 39)
            return 0x80004002
        }
    }
    __Delete() {
        CallbackFree(this.__pQueryInterface)
        CallbackFree(this.__pAddRefOrRelease)
        CallbackFree(this.__pHandleEvent)
    }
}

; HandleAutomationEvent(sender, eventId)
class CUIAutomationEventHandler extends UIAutomationEventHandlerBase {
    static Guid := "{146C3C17-F12E-4E22-8C27-F894B9B79C69}"
    __HandleEvent(pVirtualTable, sender, eventId) {
        return this.__Function.Call(IUIAutomationElement(sender), eventId)
    }
}

; HandleChangesEvent(sender, uiaChanges)
class CUIAutomationChangesEventHandler extends UIAutomationEventHandlerBase {
    static Guid := "{58EDCA55-2C3E-4980-B1B9-56C17F27A2A0}"
    __HandleEvent(pVirtualTable, sender, uiaChanges, changesCount) {
        uiaChangesArr := []
        loop changesCount {
            offset := (A_Index - 1) * 52
            temp1 := ComValue(0x400C, NumGet(uiaChanges, offset + 4, "ptr"))
            temp2 := ComValue(0x400C, NumGet(uiaChanges, offset + 28, "ptr"))
            payload := temp1[]
            extraInfo := temp2[]
            temp1[] := 0
            temp2[] := 0
            change := {
                uiaId: NumGet(uiaChanges, offset, "int"),
                payload: payload,
                extraInfo: extraInfo
            }
            uiaChangesArr.Push(change)
        }
        return this.__Function.Call(IUIAutomationElement(sender), uiaChangesArr)
    }
}

; HandleFocusChangedEvent(sender)
class CUIAutomationFocusChangedEventHandler extends UIAutomationEventHandlerBase {
    static Guid := "{C270F6B5-5C69-4290-9745-7A7F97169468}"
    __HandleEvent(pVirtualTable, sender) {
        return this.__Function.Call(IUIAutomationElement(sender))
    }
}

; HandlePropertyChangedEvent(sender, propertyId, newValue)
class CUIAutomationPropertyChangedEventHandler extends UIAutomationEventHandlerBase {
    static Guid := "{40CD37D4-C756-4B0C-8C6F-BDDFEEB13B50}"
    __HandleEvent(pVirtualTable, sender, propertyId, newValue) {
        temp := ComValue(0x400C, newValue)
        newValue := temp[]
        temp[] := 0
        return this.__Function.Call(IUIAutomationElement(sender), propertyId, newValue)
    }
}
; HandleStructureChangedEvent(sender, changeType, runtimeId)
class CUIAutomationStructureChangedEventHandler extends UIAutomationEventHandlerBase {
    static Guid := "{E81D1B4E-11C5-42F8-9754-E7036C79F054}"
    __HandleEvent(pVirtualTable, sender, changeType, runtimeId) {
        runtimeId := UIAUtils_SafeArrayToArray(3, runtimeId)
        return this.__Function.Call(IUIAutomationElement(sender), changeType, runtimeId)
    }
}

; HandleTextEditTextChangedEvent(sender, textEditChangeType, eventStrings)
class CUIAutomationTextEditTextChangedEventHandler extends UIAutomationEventHandlerBase {
    static Guid := "{92FAA680-E704-4156-931A-E32D5BB38F3F}"
    __HandleEvent(pVirtualTable, sender, textEditChangeType, eventStrings) {
        eventStrings := UIAUtils_SafeArrayToArray(8, eventStrings)
        return this.__Function.Call(IUIAutomationElement(sender), textEditChangeType, eventStrings)
    }
}

; HandleNotificationEvent(sender, notificationKind, notificationProcessing, displayString, activityId)
class CUIAutomationNotificationEventHandler extends UIAutomationEventHandlerBase {
    static Guid := "{C7CB2637-E6C2-4D0C-85DE-4948C02175C7}"
    __HandleEvent(pVirtualTable, sender, notificationKind, notificationProcessing, displayString, activityId) {
        displayString := displayString ? BSTR(displayString).ToString() : ""
        activityId := activityId ? BSTR(activityId).ToString() : ""
        return this.__Function.Call(IUIAutomationElement(sender), notificationKind, notificationProcessing, displayString, activityId)
    }
}

; HandleActiveTextPositionChangedEvent(sender, range)
class CUIAutomationActiveTextPositionChangedEventHandler extends IUnknownWrapperBase {
    __HandleEvent(pVirtualTable, sender, range) {
        return this.__Function.Call(IUIAutomationElement(sender), IUIAutomationTextRange(range))
    }
}

class UIAConst {
    static AutomationElementMode_None := 0
    static AutomationElementMode_Full := 1
    static CoalesceEventsOptions_Disabled := 0
    static CoalesceEventsOptions_Enabled := 1
    static ConnectionRecoveryBehaviorOptions_Disabled := 0
    static ConnectionRecoveryBehaviorOptions_Enabled := 1
    static DockPosition_Top := 0
    static DockPosition_Left := 1
    static DockPosition_Bottom := 2
    static DockPosition_Right := 3
    static DockPosition_Fill := 4
    static DockPosition_None := 5
    static ExpandCollapseState_Collapsed := 0
    static ExpandCollapseState_Expanded := 1
    static ExpandCollapseState_PartiallyExpanded := 2
    static ExpandCollapseState_LeafNode := 3
    static LiveSetting_Off := 0
    static LiveSetting_Polite := 1
    static LiveSetting_Assertive := 2
    static NavigateDirection_Parent := 0
    static NavigateDirection_NextSibling := 1
    static NavigateDirection_PreviousSibling := 2
    static NavigateDirection_FirstChild := 3
    static NavigateDirection_LastChild := 4
    static NotificationKind_ItemAdded := 0
    static NotificationKind_ItemRemoved := 1
    static NotificationKind_ActionCompleted := 2
    static NotificationKind_ActionAborted := 3
    static NotificationKind_Other := 4
    static NotificationProcessing_ImportantAll := 0
    static NotificationProcessing_ImportantMostRecent := 1
    static NotificationProcessing_All := 2
    static NotificationProcessing_MostRecent := 3
    static NotificationProcessing_CurrentThenMostRecent := 4
    static OrientationType_None := 0
    static OrientationType_Horizontal := 1
    static OrientationType_Vertical := 2
    static PropertyConditionFlags_None := 0
    static PropertyConditionFlags_IgnoreCase := 1
    static PropertyConditionFlags_MatchSubstring := 2
    static ProviderOptions_ClientSideProvider := 1
    static ProviderOptions_ServerSideProvider := 2
    static ProviderOptions_NonClientAreaProvider := 4
    static ProviderOptions_OverrideProvider := 8
    static ProviderOptions_ProviderOwnsSetFocus := 0x10
    static ProviderOptions_UseComThreading := 0x20
    static ProviderOptions_RefuseNonClientSupport := 0x40
    static ProviderOptions_HasNativeIAccessible := 0x80
    static ProviderOptions_UseClientCoordinates := 0x100
    static RowOrColumnMajor_RowMajor := 0
    static RowOrColumnMajor_ColumnMajor := 1
    static RowOrColumnMajor_Indeterminate := 2
    static ScrollAmount_LargeDecrement := 0
    static ScrollAmount_SmallDecrement := 1
    static ScrollAmount_NoAmount := 2
    static ScrollAmount_LargeIncrement := 3
    static ScrollAmount_SmallIncrement := 4
    static StructureChangeType_ChildAdded := 0
    static StructureChangeType_ChildRemoved := 1
    static StructureChangeType_ChildrenInvalidated := 2
    static StructureChangeType_ChildrenBulkAdded := 3
    static StructureChangeType_ChildrenBulkRemoved := 4
    static StructureChangeType_ChildrenReordered := 5
    static SupportedTextSelection_None := 0
    static SupportedTextSelection_Single := 1
    static SupportedTextSelection_Multiple := 2
    static SynchronizedInputType_KeyUp := 1
    static SynchronizedInputType_KeyDown := 2
    static SynchronizedInputType_LeftMouseUp := 4
    static SynchronizedInputType_LeftMouseDown := 8
    static SynchronizedInputType_RightMouseUp := 0x10
    static SynchronizedInputType_RightMouseDown := 0x20
    static TextEditChangeType_None := 0
    static TextEditChangeType_AutoCorrect := 1
    static TextEditChangeType_Composition := 2
    static TextEditChangeType_CompositionFinalized := 3
    static TextEditChangeType_AutoComplete := 4
    static TextPatternRangeEndpoint_Start := 0
    static TextPatternRangeEndpoint_End := 1
    static TextUnit_Character := 0
    static TextUnit_Format := 1
    static TextUnit_Word := 2
    static TextUnit_Line := 3
    static TextUnit_Paragraph := 4
    static TextUnit_Page := 5
    static TextUnit_Document := 6
    static ToggleState_Off := 0
    static ToggleState_On := 1
    static ToggleState_Indeterminate := 2
    static TreeScope_None := 0
    static TreeScope_Element := 1
    static TreeScope_Children := 2
    static TreeScope_Descendants := 4
    static TreeScope_Subtree := 7
    static TreeScope_Parent := 8
    static TreeScope_Ancestors := 16
    static TreeTraversalOptions_Default := 0
    static TreeTraversalOptions_PostOrder := 1
    static TreeTraversalOptions_LastToFirstOrder := 2
    static AnnotationType_Unknown := 60000
    static AnnotationType_SpellingError := 60001
    static AnnotationType_GrammarError := 60002
    static AnnotationType_Comment := 60003
    static AnnotationType_FormulaError := 60004
    static AnnotationType_TrackChanges := 60005
    static AnnotationType_Header := 60006
    static AnnotationType_Footer := 60007
    static AnnotationType_Highlighted := 60008
    static AnnotationType_Endnote := 60009
    static AnnotationType_Footnote := 60010
    static AnnotationType_InsertionChange := 60011
    static AnnotationType_DeletionChange := 60012
    static AnnotationType_MoveChange := 60013
    static AnnotationType_FormatChange := 60014
    static AnnotationType_UnsyncedChange := 60015
    static AnnotationType_EditingLockedChange := 60016
    static AnnotationType_ExternalChange := 60017
    static AnnotationType_ConflictingChange := 60018
    static AnnotationType_Author := 60019
    static AnnotationType_AdvancedProofingIssue := 60020
    static AnnotationType_DataValidationError := 60021
    static AnnotationType_CircularReferenceError := 60022
    static AnnotationType_Mathematics := 60023
    static AnnotationType_Sensitive := 60024
    static UIA_SummaryChangeId := 90000
    static UIA_ButtonControlTypeId := 50000
    static UIA_CalendarControlTypeId := 50001
    static UIA_CheckBoxControlTypeId := 50002
    static UIA_ComboBoxControlTypeId := 50003
    static UIA_EditControlTypeId := 50004
    static UIA_HyperlinkControlTypeId := 50005
    static UIA_ImageControlTypeId := 50006
    static UIA_ListItemControlTypeId := 50007
    static UIA_ListControlTypeId := 50008
    static UIA_MenuControlTypeId := 50009
    static UIA_MenuBarControlTypeId := 50010
    static UIA_MenuItemControlTypeId := 50011
    static UIA_ProgressBarControlTypeId := 50012
    static UIA_RadioButtonControlTypeId := 50013
    static UIA_ScrollBarControlTypeId := 50014
    static UIA_SliderControlTypeId := 50015
    static UIA_SpinnerControlTypeId := 50016
    static UIA_StatusBarControlTypeId := 50017
    static UIA_TabControlTypeId := 50018
    static UIA_TabItemControlTypeId := 50019
    static UIA_TextControlTypeId := 50020
    static UIA_ToolBarControlTypeId := 50021
    static UIA_ToolTipControlTypeId := 50022
    static UIA_TreeControlTypeId := 50023
    static UIA_TreeItemControlTypeId := 50024
    static UIA_CustomControlTypeId := 50025
    static UIA_GroupControlTypeId := 50026
    static UIA_ThumbControlTypeId := 50027
    static UIA_DataGridControlTypeId := 50028
    static UIA_DataItemControlTypeId := 50029
    static UIA_DocumentControlTypeId := 50030
    static UIA_SplitButtonControlTypeId := 50031
    static UIA_WindowControlTypeId := 50032
    static UIA_PaneControlTypeId := 50033
    static UIA_HeaderControlTypeId := 50034
    static UIA_HeaderItemControlTypeId := 50035
    static UIA_TableControlTypeId := 50036
    static UIA_TitleBarControlTypeId := 50037
    static UIA_SeparatorControlTypeId := 50038
    static UIA_SemanticZoomControlTypeId := 50039
    static UIA_AppBarControlTypeId := 50040
    static UIA_ToolTipOpenedEventId := 20000
    static UIA_ToolTipClosedEventId := 20001
    static UIA_StructureChangedEventId := 20002
    static UIA_MenuOpenedEventId := 20003
    static UIA_AutomationPropertyChangedEventId := 20004
    static UIA_AutomationFocusChangedEventId := 20005
    static UIA_AsyncContentLoadedEventId := 20006
    static UIA_MenuClosedEventId := 20007
    static UIA_LayoutInvalidatedEventId := 20008
    static UIA_Invoke_InvokedEventId := 20009
    static UIA_SelectionItem_ElementAddedToSelectionEventId := 20010
    static UIA_SelectionItem_ElementRemovedFromSelectionEventId := 20011
    static UIA_SelectionItem_ElementSelectedEventId := 20012
    static UIA_Selection_InvalidatedEventId := 20013
    static UIA_Text_TextSelectionChangedEventId := 20014
    static UIA_Text_TextChangedEventId := 20015
    static UIA_Window_WindowOpenedEventId := 20016
    static UIA_Window_WindowClosedEventId := 20017
    static UIA_MenuModeStartEventId := 20018
    static UIA_MenuModeEndEventId := 20019
    static UIA_InputReachedTargetEventId := 20020
    static UIA_InputReachedOtherElementEventId := 20021
    static UIA_InputDiscardedEventId := 20022
    static UIA_SystemAlertEventId := 20023
    static UIA_LiveRegionChangedEventId := 20024
    static UIA_HostedFragmentRootsInvalidatedEventId := 20025
    static UIA_Drag_DragStartEventId := 20026
    static UIA_Drag_DragCancelEventId := 20027
    static UIA_Drag_DragCompleteEventId := 20028
    static UIA_DropTarget_DragEnterEventId := 20029
    static UIA_DropTarget_DragLeaveEventId := 20030
    static UIA_DropTarget_DroppedEventId := 20031
    static UIA_TextEdit_TextChangedEventId := 20032
    static UIA_TextEdit_ConversionTargetChangedEventId := 20033
    static UIA_ChangesEventId := 20034
    static UIA_NotificationEventId := 20035
    static UIA_ActiveTextPositionChangedEventId := 20036
    static HeadingLevel_None := 80050
    static HeadingLevel1 := 80051
    static HeadingLevel2 := 80052
    static HeadingLevel3 := 80053
    static HeadingLevel4 := 80054
    static HeadingLevel5 := 80055
    static HeadingLevel6 := 80056
    static HeadingLevel7 := 80057
    static HeadingLevel8 := 80058
    static HeadingLevel9 := 80059
    static UIA_CustomLandmarkTypeId := 80000
    static UIA_FormLandmarkTypeId := 80001
    static UIA_MainLandmarkTypeId := 80002
    static UIA_NavigationLandmarkTypeId := 80003
    static UIA_SearchLandmarkTypeId := 80004
    static UIA_SayAsInterpretAsMetadataId := 100000
    static UIA_InvokePatternId := 10000
    static UIA_SelectionPatternId := 10001
    static UIA_ValuePatternId := 10002
    static UIA_RangeValuePatternId := 10003
    static UIA_ScrollPatternId := 10004
    static UIA_ExpandCollapsePatternId := 10005
    static UIA_GridPatternId := 10006
    static UIA_GridItemPatternId := 10007
    static UIA_MultipleViewPatternId := 10008
    static UIA_WindowPatternId := 10009
    static UIA_SelectionItemPatternId := 10010
    static UIA_DockPatternId := 10011
    static UIA_TablePatternId := 10012
    static UIA_TableItemPatternId := 10013
    static UIA_TextPatternId := 10014
    static UIA_TogglePatternId := 10015
    static UIA_TransformPatternId := 10016
    static UIA_ScrollItemPatternId := 10017
    static UIA_LegacyIAccessiblePatternId := 10018
    static UIA_ItemContainerPatternId := 10019
    static UIA_VirtualizedItemPatternId := 10020
    static UIA_SynchronizedInputPatternId := 10021
    static UIA_ObjectModelPatternId := 10022
    static UIA_AnnotationPatternId := 10023
    static UIA_TextPattern2Id := 10024
    static UIA_StylesPatternId := 10025
    static UIA_SpreadsheetPatternId := 10026
    static UIA_SpreadsheetItemPatternId := 10027
    static UIA_TransformPattern2Id := 10028
    static UIA_TextChildPatternId := 10029
    static UIA_DragPatternId := 10030
    static UIA_DropTargetPatternId := 10031
    static UIA_TextEditPatternId := 10032
    static UIA_CustomNavigationPatternId := 10033
    static UIA_SelectionPattern2Id := 10034
    static UIA_RuntimeIdPropertyId := 30000
    static UIA_BoundingRectanglePropertyId := 30001
    static UIA_ProcessIdPropertyId := 30002
    static UIA_ControlTypePropertyId := 30003
    static UIA_LocalizedControlTypePropertyId := 30004
    static UIA_NamePropertyId := 30005
    static UIA_AcceleratorKeyPropertyId := 30006
    static UIA_AccessKeyPropertyId := 30007
    static UIA_HasKeyboardFocusPropertyId := 30008
    static UIA_IsKeyboardFocusablePropertyId := 30009
    static UIA_IsEnabledPropertyId := 30010
    static UIA_AutomationIdPropertyId := 30011
    static UIA_ClassNamePropertyId := 30012
    static UIA_HelpTextPropertyId := 30013
    static UIA_ClickablePointPropertyId := 30014
    static UIA_CulturePropertyId := 30015
    static UIA_IsControlElementPropertyId := 30016
    static UIA_IsContentElementPropertyId := 30017
    static UIA_LabeledByPropertyId := 30018
    static UIA_IsPasswordPropertyId := 30019
    static UIA_NativeWindowHandlePropertyId := 30020
    static UIA_ItemTypePropertyId := 30021
    static UIA_IsOffscreenPropertyId := 30022
    static UIA_OrientationPropertyId := 30023
    static UIA_FrameworkIdPropertyId := 30024
    static UIA_IsRequiredForFormPropertyId := 30025
    static UIA_ItemStatusPropertyId := 30026
    static UIA_IsDockPatternAvailablePropertyId := 30027
    static UIA_IsExpandCollapsePatternAvailablePropertyId := 30028
    static UIA_IsGridItemPatternAvailablePropertyId := 30029
    static UIA_IsGridPatternAvailablePropertyId := 30030
    static UIA_IsInvokePatternAvailablePropertyId := 30031
    static UIA_IsMultipleViewPatternAvailablePropertyId := 30032
    static UIA_IsRangeValuePatternAvailablePropertyId := 30033
    static UIA_IsScrollPatternAvailablePropertyId := 30034
    static UIA_IsScrollItemPatternAvailablePropertyId := 30035
    static UIA_IsSelectionItemPatternAvailablePropertyId := 30036
    static UIA_IsSelectionPatternAvailablePropertyId := 30037
    static UIA_IsTablePatternAvailablePropertyId := 30038
    static UIA_IsTableItemPatternAvailablePropertyId := 30039
    static UIA_IsTextPatternAvailablePropertyId := 30040
    static UIA_IsTogglePatternAvailablePropertyId := 30041
    static UIA_IsTransformPatternAvailablePropertyId := 30042
    static UIA_IsValuePatternAvailablePropertyId := 30043
    static UIA_IsWindowPatternAvailablePropertyId := 30044
    static UIA_ValueValuePropertyId := 30045
    static UIA_ValueIsReadOnlyPropertyId := 30046
    static UIA_RangeValueValuePropertyId := 30047
    static UIA_RangeValueIsReadOnlyPropertyId := 30048
    static UIA_RangeValueMinimumPropertyId := 30049
    static UIA_RangeValueMaximumPropertyId := 30050
    static UIA_RangeValueLargeChangePropertyId := 30051
    static UIA_RangeValueSmallChangePropertyId := 30052
    static UIA_ScrollHorizontalScrollPercentPropertyId := 30053
    static UIA_ScrollHorizontalViewSizePropertyId := 30054
    static UIA_ScrollVerticalScrollPercentPropertyId := 30055
    static UIA_ScrollVerticalViewSizePropertyId := 30056
    static UIA_ScrollHorizontallyScrollablePropertyId := 30057
    static UIA_ScrollVerticallyScrollablePropertyId := 30058
    static UIA_SelectionSelectionPropertyId := 30059
    static UIA_SelectionCanSelectMultiplePropertyId := 30060
    static UIA_SelectionIsSelectionRequiredPropertyId := 30061
    static UIA_GridRowCountPropertyId := 30062
    static UIA_GridColumnCountPropertyId := 30063
    static UIA_GridItemRowPropertyId := 30064
    static UIA_GridItemColumnPropertyId := 30065
    static UIA_GridItemRowSpanPropertyId := 30066
    static UIA_GridItemColumnSpanPropertyId := 30067
    static UIA_GridItemContainingGridPropertyId := 30068
    static UIA_DockDockPositionPropertyId := 30069
    static UIA_ExpandCollapseExpandCollapseStatePropertyId := 30070
    static UIA_MultipleViewCurrentViewPropertyId := 30071
    static UIA_MultipleViewSupportedViewsPropertyId := 30072
    static UIA_WindowCanMaximizePropertyId := 30073
    static UIA_WindowCanMinimizePropertyId := 30074
    static UIA_WindowWindowVisualStatePropertyId := 30075
    static UIA_WindowWindowInteractionStatePropertyId := 30076
    static UIA_WindowIsModalPropertyId := 30077
    static UIA_WindowIsTopmostPropertyId := 30078
    static UIA_SelectionItemIsSelectedPropertyId := 30079
    static UIA_SelectionItemSelectionContainerPropertyId := 30080
    static UIA_TableRowHeadersPropertyId := 30081
    static UIA_TableColumnHeadersPropertyId := 30082
    static UIA_TableRowOrColumnMajorPropertyId := 30083
    static UIA_TableItemRowHeaderItemsPropertyId := 30084
    static UIA_TableItemColumnHeaderItemsPropertyId := 30085
    static UIA_ToggleToggleStatePropertyId := 30086
    static UIA_TransformCanMovePropertyId := 30087
    static UIA_TransformCanResizePropertyId := 30088
    static UIA_TransformCanRotatePropertyId := 30089
    static UIA_IsLegacyIAccessiblePatternAvailablePropertyId := 30090
    static UIA_LegacyIAccessibleChildIdPropertyId := 30091
    static UIA_LegacyIAccessibleNamePropertyId := 30092
    static UIA_LegacyIAccessibleValuePropertyId := 30093
    static UIA_LegacyIAccessibleDescriptionPropertyId := 30094
    static UIA_LegacyIAccessibleRolePropertyId := 30095
    static UIA_LegacyIAccessibleStatePropertyId := 30096
    static UIA_LegacyIAccessibleHelpPropertyId := 30097
    static UIA_LegacyIAccessibleKeyboardShortcutPropertyId := 30098
    static UIA_LegacyIAccessibleSelectionPropertyId := 30099
    static UIA_LegacyIAccessibleDefaultActionPropertyId := 30100
    static UIA_AriaRolePropertyId := 30101
    static UIA_AriaPropertiesPropertyId := 30102
    static UIA_IsDataValidForFormPropertyId := 30103
    static UIA_ControllerForPropertyId := 30104
    static UIA_DescribedByPropertyId := 30105
    static UIA_FlowsToPropertyId := 30106
    static UIA_ProviderDescriptionPropertyId := 30107
    static UIA_IsItemContainerPatternAvailablePropertyId := 30108
    static UIA_IsVirtualizedItemPatternAvailablePropertyId := 30109
    static UIA_IsSynchronizedInputPatternAvailablePropertyId := 30110
    static UIA_OptimizeForVisualContentPropertyId := 30111
    static UIA_IsObjectModelPatternAvailablePropertyId := 30112
    static UIA_AnnotationAnnotationTypeIdPropertyId := 30113
    static UIA_AnnotationAnnotationTypeNamePropertyId := 30114
    static UIA_AnnotationAuthorPropertyId := 30115
    static UIA_AnnotationDateTimePropertyId := 30116
    static UIA_AnnotationTargetPropertyId := 30117
    static UIA_IsAnnotationPatternAvailablePropertyId := 30118
    static UIA_IsTextPattern2AvailablePropertyId := 30119
    static UIA_StylesStyleIdPropertyId := 30120
    static UIA_StylesStyleNamePropertyId := 30121
    static UIA_StylesFillColorPropertyId := 30122
    static UIA_StylesFillPatternStylePropertyId := 30123
    static UIA_StylesShapePropertyId := 30124
    static UIA_StylesFillPatternColorPropertyId := 30125
    static UIA_StylesExtendedPropertiesPropertyId := 30126
    static UIA_IsStylesPatternAvailablePropertyId := 30127
    static UIA_IsSpreadsheetPatternAvailablePropertyId := 30128
    static UIA_SpreadsheetItemFormulaPropertyId := 30129
    static UIA_SpreadsheetItemAnnotationObjectsPropertyId := 30130
    static UIA_SpreadsheetItemAnnotationTypesPropertyId := 30131
    static UIA_IsSpreadsheetItemPatternAvailablePropertyId := 30132
    static UIA_Transform2CanZoomPropertyId := 30133
    static UIA_IsTransformPattern2AvailablePropertyId := 30134
    static UIA_LiveSettingPropertyId := 30135
    static UIA_IsTextChildPatternAvailablePropertyId := 30136
    static UIA_IsDragPatternAvailablePropertyId := 30137
    static UIA_DragIsGrabbedPropertyId := 30138
    static UIA_DragDropEffectPropertyId := 30139
    static UIA_DragDropEffectsPropertyId := 30140
    static UIA_IsDropTargetPatternAvailablePropertyId := 30141
    static UIA_DropTargetDropTargetEffectPropertyId := 30142
    static UIA_DropTargetDropTargetEffectsPropertyId := 30143
    static UIA_DragGrabbedItemsPropertyId := 30144
    static UIA_Transform2ZoomLevelPropertyId := 30145
    static UIA_Transform2ZoomMinimumPropertyId := 30146
    static UIA_Transform2ZoomMaximumPropertyId := 30147
    static UIA_FlowsFromPropertyId := 30148
    static UIA_IsTextEditPatternAvailablePropertyId := 30149
    static UIA_IsPeripheralPropertyId := 30150
    static UIA_IsCustomNavigationPatternAvailablePropertyId := 30151
    static UIA_PositionInSetPropertyId := 30152
    static UIA_SizeOfSetPropertyId := 30153
    static UIA_LevelPropertyId := 30154
    static UIA_AnnotationTypesPropertyId := 30155
    static UIA_AnnotationObjectsPropertyId := 30156
    static UIA_LandmarkTypePropertyId := 30157
    static UIA_LocalizedLandmarkTypePropertyId := 30158
    static UIA_FullDescriptionPropertyId := 30159
    static UIA_FillColorPropertyId := 30160
    static UIA_OutlineColorPropertyId := 30161
    static UIA_FillTypePropertyId := 30162
    static UIA_VisualEffectsPropertyId := 30163
    static UIA_OutlineThicknessPropertyId := 30164
    static UIA_CenterPointPropertyId := 30165
    static UIA_RotationPropertyId := 30166
    static UIA_SizePropertyId := 30167
    static UIA_IsSelectionPattern2AvailablePropertyId := 30168
    static UIA_Selection2FirstSelectedItemPropertyId := 30169
    static UIA_Selection2LastSelectedItemPropertyId := 30170
    static UIA_Selection2CurrentSelectedItemPropertyId := 30171
    static UIA_Selection2ItemCountPropertyId := 30172
    static UIA_HeadingLevelPropertyId := 30173
    static UIA_IsDialogPropertyId := 30174
    static StyleId_Custom := 70000
    static StyleId_Heading1 := 70001
    static StyleId_Heading2 := 70002
    static StyleId_Heading3 := 70003
    static StyleId_Heading4 := 70004
    static StyleId_Heading5 := 70005
    static StyleId_Heading6 := 70006
    static StyleId_Heading7 := 70007
    static StyleId_Heading8 := 70008
    static StyleId_Heading9 := 70009
    static StyleId_Title := 70010
    static StyleId_Subtitle := 70011
    static StyleId_Normal := 70012
    static StyleId_Emphasis := 70013
    static StyleId_Quote := 70014
    static StyleId_BulletedList := 70015
    static StyleId_NumberedList := 70016
    static UIA_AnimationStyleAttributeId := 40000
    static UIA_BackgroundColorAttributeId := 40001
    static UIA_BulletStyleAttributeId := 40002
    static UIA_CapStyleAttributeId := 40003
    static UIA_CultureAttributeId := 40004
    static UIA_FontNameAttributeId := 40005
    static UIA_FontSizeAttributeId := 40006
    static UIA_FontWeightAttributeId := 40007
    static UIA_ForegroundColorAttributeId := 40008
    static UIA_HorizontalTextAlignmentAttributeId := 40009
    static UIA_IndentationFirstLineAttributeId := 40010
    static UIA_IndentationLeadingAttributeId := 40011
    static UIA_IndentationTrailingAttributeId := 40012
    static UIA_IsHiddenAttributeId := 40013
    static UIA_IsItalicAttributeId := 40014
    static UIA_IsReadOnlyAttributeId := 40015
    static UIA_IsSubscriptAttributeId := 40016
    static UIA_IsSuperscriptAttributeId := 40017
    static UIA_MarginBottomAttributeId := 40018
    static UIA_MarginLeadingAttributeId := 40019
    static UIA_MarginTopAttributeId := 40020
    static UIA_MarginTrailingAttributeId := 40021
    static UIA_OutlineStylesAttributeId := 40022
    static UIA_OverlineColorAttributeId := 40023
    static UIA_OverlineStyleAttributeId := 40024
    static UIA_StrikethroughColorAttributeId := 40025
    static UIA_StrikethroughStyleAttributeId := 40026
    static UIA_TabsAttributeId := 40027
    static UIA_TextFlowDirectionsAttributeId := 40028
    static UIA_UnderlineColorAttributeId := 40029
    static UIA_UnderlineStyleAttributeId := 40030
    static UIA_AnnotationTypesAttributeId := 40031
    static UIA_AnnotationObjectsAttributeId := 40032
    static UIA_StyleNameAttributeId := 40033
    static UIA_StyleIdAttributeId := 40034
    static UIA_LinkAttributeId := 40035
    static UIA_IsActiveAttributeId := 40036
    static UIA_SelectionActiveEndAttributeId := 40037
    static UIA_CaretPositionAttributeId := 40038
    static UIA_CaretBidiModeAttributeId := 40039
    static UIA_LineSpacingAttributeId := 40040
    static UIA_BeforeParagraphSpacingAttributeId := 40041
    static UIA_AfterParagraphSpacingAttributeId := 40042
    static UIA_SayAsInterpretAsAttributeId := 40043
    static WindowInteractionState_Running := 0
    static WindowInteractionState_Closing := 1
    static WindowInteractionState_ReadyForUserInteraction := 2
    static WindowInteractionState_BlockedByModalWindow := 3
    static WindowInteractionState_NotResponding := 4
    static WindowVisualState_Normal := 0
    static WindowVisualState_Maximized := 1
    static WindowVisualState_Minimized := 2
    static ZoomUnit_NoAmount := 0
    static ZoomUnit_LargeDecrement := 1
    static ZoomUnit_SmallDecrement := 2
    static ZoomUnit_LargeIncrement := 3
    static ZoomUnit_SmallIncrement := 4
}

UIAUtils_ObjectToPoint(obj) {
    return obj.X | obj.Y << 32
}
UIAUtils_PointToObject(pt) {
    return {X: pt & 0xFFFFFFFF, Y: pt >> 32}
}
UIAUtils_ObjectToRect(obj) {
    rect := Buffer(16)
    NumPut("int", obj.left, "int", obj.top, "int", obj.right, "int", obj.bottom, rect)
    return rect
}
UIAUtils_RectToObject(rect) {
    return {
        left: NumGet(rect, 0, "int"),
        top: NumGet(rect, 4, "int"),
        right: NumGet(rect, 8, "int"),
        bottom: NumGet(rect, 12, "int")
    }
}
UIAUtils_ArrayToSafeArray(type, arr) {
    sa := ComObjArray(type, arr.Length)
    for v in arr {
        sa[A_Index - 1] := v
    }
    return sa
}
UIAUtils_SafeArrayToArray(type, psa) {
    return [ComValue(0x2000 | type, psa)*]
}
UIAUtils_IUnknownArrayToSafeArray(arr) {
    sa := ComObjArray(0xD, arr.Length)
    for v in arr {
        sa[A_Index - 1] := v.ComObj
    }
    return sa
}
UIAUtils_IUnknownSafeArrayToArray(psa, wrapper?) {
    if IsSet(wrapper) {
        arr := []
        for v in ComValue(0x200D, psa) {
            arr.Push(wrapper(v))
        }
        return arr
    }
    else {
        return [ComValue(0x200D, psa)*]
    }
}
UIAUtils_ArrayToNativeArray(type, arr) {
    na := NumNativeArray(type, arr.Length)
    for v in arr {
        na[A_Index - 1] := v
    }
    return na
}
UIAUtils_IUnknownArrayToNativeArray(arr) {
    na := NumNativeArray("ptr", arr.Length)
    for v in arr {
        na[A_Index - 1] := v.Ptr
    }
    return na
}
UIAUtils_GetPatternInterface(patternId) {
    static m := [IUIAutomationInvokePattern, IUIAutomationSelectionPattern, IUIAutomationValuePattern, IUIAutomationRangeValuePattern, IUIAutomationScrollPattern, IUIAutomationExpandCollapsePattern, IUIAutomationGridPattern, IUIAutomationGridItemPattern, IUIAutomationMultipleViewPattern, IUIAutomationWindowPattern, IUIAutomationSelectionItemPattern, IUIAutomationDockPattern, IUIAutomationTablePattern, IUIAutomationTableItemPattern, IUIAutomationTextPattern, IUIAutomationTogglePattern, IUIAutomationTransformPattern, IUIAutomationScrollItemPattern, IUIAutomationLegacyIAccessiblePattern, IUIAutomationItemContainerPattern, IUIAutomationVirtualizedItemPattern, IUIAutomationSynchronizedInputPattern, IUIAutomationObjectModelPattern, IUIAutomationAnnotationPattern, IUIAutomationTextPattern2, IUIAutomationStylesPattern, IUIAutomationSpreadsheetPattern, IUIAutomationSpreadsheetItemPattern, IUIAutomationTransformPattern2, IUIAutomationTextChildPattern, IUIAutomationDragPattern, IUIAutomationDropTargetPattern, IUIAutomationTextEditPattern, IUIAutomationCustomNavigationPattern, IUIAutomationSelectionPattern2]
    return m[patternId - 9999]
}
UIAUtils_GetPropertyVariantType(id) {
    static types := [0x2003, 0x2005, 0x0003, 0x0003, 0x0008, 0x0008, 0x0008, 0x0008, 0x000B, 0x000B, 0x000B, 0x0008, 0x0008, 0x0008, 0x2005, 0x0003, 0x000B, 0x000B, 0x000D, 0x000B, 0x0003, 0x0008, 0x000B, 0x0003, 0x0008, 0x000B, 0x0008, 0x000B, 0x000B, 0x000B, 0x000B, 0x000B, 0x000B, 0x000B, 0x000B, 0x000B, 0x000B, 0x000B, 0x000B, 0x000B, 0x000B, 0x000B, 0x000B, 0x000B, 0x000B, 0x0008, 0x000B, 0x0005, 0x000B, 0x0005, 0x0005, 0x0005, 0x0005, 0x0005, 0x0005, 0x0005, 0x0005, 0x000B, 0x000B, 0x200D, 0x000B, 0x000B, 0x0003, 0x0003, 0x0003, 0x0003, 0x0003, 0x0003, 0x000D, 0x0003, 0x0003, 0x0003, 0x2003, 0x000B, 0x000B, 0x0003, 0x0003, 0x000B, 0x000B, 0x000B, 0x000D, 0x200D, 0x200D, 0x0003, 0x200D, 0x200D, 0x0003, 0x000B, 0x000B, 0x000B, 0x000B, 0x0003, 0x0008, 0x0008, 0x0008, 0x0003, 0x0003, 0x0008, 0x0008, 0x200D, 0x0008, 0x0008, 0x0008, 0x000B, 0x000D, 0x000D, 0x000D, 0x0008, 0x000B, 0x000B, 0x000B, 0x000B, 0x000B, 0x0003, 0x0008, 0x0008, 0x0008, 0x000D, 0x000B, 0x000B, 0x0003, 0x0008, 0x0003, 0x0008, 0x0008, 0x0003, 0x0008, 0x000B, 0x000B, 0x0008, 0x200D, 0x2003, 0x000B, 0x000B, 0x000B, 0x0003, 0x000B, 0x000B, 0x000B, 0x0008, 0x2008, 0x000B, 0x0008, 0x2008, 0x200D, 0x0005, 0x0005, 0x0005, 0x000D, 0x000B, 0x000B, 0x000B, 0x0003, 0x0003, 0x0003, 0x2003, 0x2003, 0x0003, 0x0008, 0x0008, 0x0003, 0x2003, 0x0003, 0x0003, 0x2005, 0x2005, 0x0005, 0x2005, 0x000B, 0x000D, 0x000D, 0x000D, 0x0003, 0x0003, 0x000B]
    return types[id - 29999]
}
UIAUtils_GetTextAttributeVariantType(id) {
    static types := [0x0003, 0x0003, 0x0003, 0x0003, 0x0003, 0x0008, 0x0005, 0x0003, 0x0003, 0x0003, 0x0005, 0x0005, 0x0005, 0x000B, 0x000B, 0x000B, 0x000B, 0x000B, 0x0005, 0x0005, 0x0005, 0x0005, 0x0003, 0x0003, 0x0003, 0x0003, 0x0003, 0x2005, 0x0003, 0x0003, 0x0003, 0x2000, 0x000D, 0x0008, 0x0003, 0x000D, 0x000B, 0x0003, 0x0003, 0x0003, 0x0008, 0x0005, 0x0005]
    return types[id - 39999]
}