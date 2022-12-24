JSEval(str) {
    doc := ComObject("htmlfile")
    doc.write('<meta http-equiv="X-UA-Compatible"content="IE=9"/>')
    return doc.parentWindow.eval(str)
}