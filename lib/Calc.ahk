/*
@Example
MsgBox Calc("(1 + 2) * 3 / 4")
MsgBox Calc("1 == (3 - 2) && 0 != 0.0001")
MsgBox Calc("1 << 8 & 0xFF + 1")
MsgBox Calc("10 % 3")
*/
Calc(expr) {
    pos := 1
    t := NextToken()
    ast := ConditionalExpression()
    return VisitNode(ast)
    /*
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
    UnaryExpression -> PrimaryExpression
    UnaryExpression -> +UnaryExpression
    UnaryExpression -> -UnaryExpression
    UnaryExpression -> !UnaryExpression
    UnaryExpression -> ~UnaryExpression
    PrimaryExpression -> num | (ConditionalExpression)
    */
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
            node := PrimaryExpression()
        return node
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
        }
    }
    NextToken() {
        if tokenPos := RegExMatch(expr, "S)\G\s*(0[xX][0-9a-fA-F]+|\d+(?:\.\d+)?(?:e-?\d+)?|>>>|<<|>>|<=|>=|==|!=|&&|\|\||\/\/|[()+\-*\/!~%<>&^|?:]|$)", &m, pos) {
            pos := tokenPos + m.Len
            if m[1] == ""
                return { Kind: "EOF" }
            else if IsNumber(m[1])
                return { Kind: "NUMBER", Value: m[1] }
            else
                return { Kind: m[1] }
        }
        throw Error('illegal character: "' SubStr(expr, pos, 1) '"')
    }
    Expect(kind) {
        if t.Kind != kind
            throw Error('missing "' kind '"')
        t := NextToken()
    }
}