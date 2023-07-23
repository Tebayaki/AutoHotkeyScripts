/*
@Example
MsgBox Calc("(1 + 2) * 3 / 4")
MsgBox Calc("1 == (3 - 2) && 0 != 0.0001")
MsgBox Calc("1 << 8 & 0xFF + 1")
MsgBox Calc("10 % 3")
MsgBox Calc("Log(1.2) + Sqrt(3)")
*/
Calc(expr) {
    pos := 1
    t := NextToken()
    ast := Expression()
    return VisitNode(ast)
    /*
    Expression -> ConditionalExpression EOF
    ConditionalExpression -> LogicOrExpression
    ConditionalExpression -> LogicOrExpression ? LogicOrExpression : ConditionalExpression
    LogicOrExpression -> LogicAndExpression
    LogicOrExpression -> LogicOrExpression || LogicAndExpression
    LogicAndExpression -> BitwiseOrExpression
    LogicAndExpression -> LogicAndExpression && BitwiseOrExpression
    BitwiseOrExpression -> BitwiseXorExpression
    BitwiseOrExpression -> BitwiseOrExpression | BitwiseXorExpression
    BitwiseXorExpression -> BitwiseAndExpression
    BitwiseXorExpression -> BitwiseXorExpression ^ BitwiseAndExpression
    BitwiseAndExpression -> EqualityExpression
    BitwiseAndExpression -> BitwiseAndExpression & EqualityExpression
    EqualityExpression -> RelationalExpression
    EqualityExpression -> EqualityExpression == RelationalExpression
    EqualityExpression -> EqualityExpression != RelationalExpression
    RelationalExpression -> ShiftExpression
    RelationalExpression -> RelationalExpression > ShiftExpression
    RelationalExpression -> RelationalExpression >= ShiftExpression
    RelationalExpression -> RelationalExpression < ShiftExpression
    RelationalExpression -> RelationalExpression <= ShiftExpression
    ShiftExpression -> AdditiveExpression
    ShiftExpression -> ShiftExpression << AdditiveExpression
    ShiftExpression -> ShiftExpression >> AdditiveExpression
    ShiftExpression -> ShiftExpression >>> AdditiveExpression
    AdditiveExpression -> MultiplicativeExpression
    AdditiveExpression -> AdditiveExpression + MultiplicativeExpression
    AdditiveExpression -> AdditiveExpression - MultiplicativeExpression
    MultiplicativeExpression -> UnaryExpression
    MultiplicativeExpression -> MultiplicativeExpression * UnaryExpression
    MultiplicativeExpression -> MultiplicativeExpression / UnaryExpression
    MultiplicativeExpression -> MultiplicativeExpression // UnaryExpression
    MultiplicativeExpression -> MultiplicativeExpression % UnaryExpression
    UnaryExpression -> PowerExpression
    UnaryExpression -> +UnaryExpression
    UnaryExpression -> -UnaryExpression
    UnaryExpression -> !UnaryExpression
    UnaryExpression -> ~UnaryExpression
    PowerExpression -> FuncCallExpression
    PowerExpression -> PowerExpression ** FuncCallExpression
    FuncCallExpression -> PrimaryExpression
    FuncCallExpression -> name(ParameterList)
    ParameterList -> e
    ParameterList -> ConditionalExpression
    ParameterList -> ParameterList, ConditionalExpression
    PrimaryExpression -> NUMBER | (ConditionalExpression)
    */
    Expression() {
        node := ConditionalExpression()
        Expect("EOF")
        return node
    }
    ConditionalExpression() {
        sub1 := LogicOrExpression()
        if t.Kind == "?" {
            t := NextToken()
            sub2 := LogicOrExpression()
            Expect(":")
            sub3 := ConditionalExpression()
            node := { Kind: "?:", Subs: [sub1, sub2, sub3] }
            sub1 := node
        }
        return sub1
    }
    LogicOrExpression() => BinaryExpression(LogicAndExpression, "||")
    LogicAndExpression() => BinaryExpression(BitwiseOrExpression, "&&")
    BitwiseOrExpression() => BinaryExpression(BitwiseXorExpression, "|")
    BitwiseXorExpression() => BinaryExpression(BitwiseAndExpression, "^")
    BitwiseAndExpression() => BinaryExpression(EqualityExpression, "&")
    EqualityExpression() => BinaryExpression(RelationalExpression, "== !=")
    RelationalExpression() => BinaryExpression(ShiftExpression, "> >= < <=")
    ShiftExpression() => BinaryExpression(AdditiveExpression, "<< >> >>>")
    AdditiveExpression() => BinaryExpression(MultiplicativeExpression, "+ -")
    MultiplicativeExpression() => BinaryExpression(UnaryExpression, "* / // %")
    UnaryExpression() {
        if t.Kind == "+" || t.Kind == "-" {
            node := { Kind: "u" t.Kind, Subs: [] }
            t := NextToken()
            node.Subs.Push(UnaryExpression())
        }
        else if t.Kind == "!" || t.Kind == "~" {
            node := { Kind: t.Kind, Subs: [] }
            t := NextToken()
            node.Subs.Push(UnaryExpression())
        }
        else
            node := PowerExpression()
        return node
    }
    PowerExpression() => BinaryExpression(FuncCallExpression, "**")
    FuncCallExpression() {
        if t.Kind == "NAME" {
            node := { Kind: t.Kind, Value: t.Value }
            t := NextToken()
            Expect("(")
            node.Subs := ParameterList()
            Expect(")")
        }
        else
            node := PrimaryExpression()
        return node
    }
    ParameterList() {
        list := []
        if t.Kind !== ")" {
            list.Push(ConditionalExpression())
            while t.Kind == "," {
                t := NextToken()
                list.Push(ConditionalExpression())
            }
        }
        return list
    }
    PrimaryExpression() {
        if t.Kind == "NUMBER" {
            node := { Kind: t.Kind, Value: t.Value }
            t := NextToken()
        }
        else if t.Kind == "(" {
            t := NextToken()
            node := ConditionalExpression()
            Expect(")")
        }
        else
            throw Error("syntax error")
        return node
    }
    BinaryExpression(subExprProc, operators) {
        sub1 := subExprProc()
        while operators ~= "(?:\s|^)\" t.Kind "(?:\s|$)" {
            node := { Kind: t.Kind, Subs: [sub1] }
            t := NextToken()
            node.Subs.Push(subExprProc())
            sub1 := node
        }
        return sub1
    }
    VisitNode(node) {
        if node.Kind == "NUMBER"
            return Number(node.Value)
        nums := []
        for sub in node.Subs
            nums.Push(VisitNode(sub))
        switch node.Kind {
            case "?:": return nums[1] ? nums[2] : nums[3]
            case "||": return nums[1] || nums[2]
            case "&&": return nums[1] && nums[2]
            case "|": return nums[1] | nums[2]
            case "^": return nums[1] ^ nums[2]
            case "&": return nums[1] & nums[2]
            case "==": return nums[1] == nums[2]
            case "!=": return nums[1] != nums[2]
            case ">": return nums[1] > nums[2]
            case ">=": return nums[1] >= nums[2]
            case "<": return nums[1] < nums[2]
            case "<=": return nums[1] <= nums[2]
            case "<<": return nums[1] << nums[2]
            case ">>": return nums[1] >> nums[2]
            case ">>>": return nums[1] >>> nums[2]
            case "+": return nums[1] + nums[2]
            case "-": return nums[1] - nums[2]
            case "*": return nums[1] * nums[2]
            case "/": return nums[1] / nums[2]
            case "//": return nums[1] // nums[2]
            case "%": return Mod(nums[1], nums[2])
            case "u+": return +nums[1]
            case "u-": return -nums[1]
            case "!": return !nums[1]
            case "~": return ~nums[1]
            case "**": return nums[1] ** nums[2]
            case "NAME": return %node.Value%(nums*)
        }
    }
    NextToken() {
        if tokenPos := RegExMatch(expr, "S)\G\s*(?:(?<NUMBER>0[xX][0-9a-fA-F]+|\d+(?:\.\d+)?(?:e-?\d+)?)|(?<OPERATOR>>>>|<<|>>|<=|>=|==|!=|&&|\|\||\/\/|\*\*|[()+\-*\/!~%<>&^|?:,])|(?<NAME>[a-zA-Z\x{0080}-\x{ffff}][\w\x{0080}-\x{ffff}]*)|$)", &m, pos) {
            pos := tokenPos + m.Len
            if m["NUMBER"] != ""
                return { Kind: "NUMBER", Value: m["NUMBER"] }
            else if m["NAME"] != ""
                return { Kind: "NAME", Value: m["NAME"] }
            else if m["OPERATOR"] != ""
                return { Kind: m["OPERATOR"] }
            else
                return { Kind: "EOF" }
        }
        throw Error('illegal character: "' SubStr(expr, pos, 1) '"')
    }
    Expect(kind) {
        if t.Kind != kind
            throw Error('expected "' kind '"')
        t := NextToken()
    }
}