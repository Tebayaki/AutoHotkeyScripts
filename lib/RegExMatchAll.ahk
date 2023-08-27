RegExMatchAll(haystack, needleRegex, startingPos := 1) {
    matches := []
    RegExReplace(haystack, needleRegex '(?Cfn)', , , , startingPos)
    return matches
    fn(m, _1, _2, _3, _4) => (matches.Push(m), 0)
}