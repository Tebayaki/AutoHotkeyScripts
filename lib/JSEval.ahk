JSEval(expr) {
    doc := ComObject("htmlfile")
    doc.write('<meta http-equiv="X-UA-Compatible"content="IE=9"/>')
    return doc.parentWindow.eval(expr)
}

/* for x86 or ScriptControl64
JSEval(expr) {
    sc := ComObject("ScriptControl")
    sc.Language := "JavaScript"
    return sc.Eval(expr)
}
*/