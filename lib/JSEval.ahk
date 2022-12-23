JSEval(str) {
    doc := ComObject("htmlfile")
    doc.write('<meta http-equiv="X-UA-Compatible" content="IE=9" />')
    js := doc.parentWindow
    return js.eval(str)
}