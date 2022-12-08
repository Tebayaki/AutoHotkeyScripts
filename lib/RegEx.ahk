MatchUrl(str) => RegExMatch(str, "\b(([\w-]+://?|www[.])[^\s()<>]+(?:[\w\d]+[\w\d]+|([^[:punct:]\s]|/)))")

RegExMatchAll(haystack, needleRegex, startingPos := 1) {
    matches := []
    RegExReplace(haystack, needleRegex '(?Cfn)', , , , startingPos)
    return matches.Length ? matches : ""
    fn(m, _1, _2, _3, _4) => (matches.Push(m), 0)
}