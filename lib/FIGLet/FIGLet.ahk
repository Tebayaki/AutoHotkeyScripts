/*
@description
This library parses FIGLet font descriptions and generates cool ascii art text.
About FIGLet: http://www.figlet.org/
Modified from: http://patorjk.com/software/taag/

@example
fl := FIGLet()
fl.Load("Slant", true) ; indicates true to search Slant from fonts library
output := fl.Generate("AutoHotkey")
ui := Gui()
ui.SetFont(, "Casicadia Code")
ui.AddEdit(, output)
ui.Show()
*/
class FIGLet {
    static LAYOUT_DEFAULT := 1
    static LAYOUT_FULL := 2
    static LAYOUT_FIT := 3
    static LAYOUT_SMUSH := 4
    static LAYOUT_CONTROLLED_SMUSH := 5
    FontsPath := A_LineFile "\..\fonts"
    Loaded := false

    /*
    @param flfPath name or path to flf file.
    @param searchFromFonts indicates whether to search flf file from fonts library, flfPath must be without ".flf" extension if true.
    */
    Load(flfPath, searchFromFonts := true, hLayout := FIGLet.LAYOUT_DEFAULT, vLayout := FIGLet.LAYOUT_DEFAULT) {
        if searchFromFonts && SubStr(flfPath, 2, 1) !== ":" {
            flfPath := this.FontsPath "\" flfPath ".flf"
        }
        data := FileRead(flfPath, "utf-8")
        lines := StrSplit(data, ["`r`n", "`n", "`r"])
        headerData := StrSplit(lines.RemoveAt(1), " ")
        headerData.Default := ""
        opts := {}
        opts.HardBlank := SubStr(headerData[1], 6, 1)
        opts.Height := Integer(headerData[2])
        opts.Baseline := Integer(headerData[3])
        opts.MaxLength := Integer(headerData[4])
        opts.OldLayout := Integer(headerData[5])
        opts.NumCommentLines := Integer(headerData[6])
        opts.PrintDirection := headerData.Length >= 7 ? (parseInt(headerData[7]) || 0) : 0
        opts.FullLayout := headerData.Length >= 8 ? parseInt(headerData[8]) : ""
        opts.CodeTagCount := headerData.Length >= 9 ? parseInt(headerData[9]) : ""
        opts.FittingRules := getSmushingRules(opts.OldLayout, opts.FullLayout)
        commentLines := splice(lines, 1, opts.NumCommentLines)
        comment := ""
        for line in commentLines {
            comment .= line (A_Index < commentLines.Length ? "`n" : "")
        }
        figChars := Map()
        charNums := []
        loop 126 - 31 {
            charNums.Push(A_Index + 31)
        }
        charNums.Push(196, 214, 220, 228, 246, 252, 223)
        figChars.numChars := 0
        while lines.Length > 0 && figChars.numChars < charNums.Length {
            cNum := charNums[figChars.numChars + 1]
            figChars[cNum] := splice(lines, 1, opts.height)
            loop opts.height {
                if figChars[cNum].Length < A_Index {
                    figChars[cNum].Length := A_Index
                    figChars[cNum][A_Index] := ""
                }
                else {
                    endCharRegEx := "\" SubStr(figChars[cNum][A_Index], StrLen(figChars[cNum][A_Index]), 1) "+$"
                    figChars[cNum][A_Index] := RegExReplace(figChars[cNum][A_Index], endCharRegEx, "")
                }
            }
            figChars.numChars++
        }
        while lines.Length > 0 {
            temp := StrSplit(lines.RemoveAt(1), " ")
            cNum := temp.Has(1) ? temp[1] : ""
            if IsInteger(cNum) {
                cNum := Integer(cNum)
            }
            else {
                break
            }
            figChars[cNum] := splice(lines, 1, opts.height)
            loop opts.height {
                endCharRegEx := "\Q" SubStr(figChars[cNum][A_Index], StrLen(figChars[cNum][A_Index]) - 1, 1) "\E+$"
                figChars[cNum][A_Index] := RegExReplace(figChars[cNum][A_Index], endCharRegEx, "")
            }
            figChars.numChars++
        }
        figChars.Default := ""
        this.Options := opts
        this.FigChars := figChars
        this.Comment := comment
        this.__DefaultFittingRules := opts.FittingRules.Clone()
        if hLayout !== FIGLet.LAYOUT_DEFAULT {
            this.HorizontalLayout := hLayout
        }
        if vLayout !== FIGLet.LAYOUT_DEFAULT {
            this.VerticalLayout := vLayout
        }
        this.Loaded := true
        return

        static getSmushingRules(oldLayout, newLayout) {
            rules := {}
            codes := [
                [16384, "vLayout", FIGLet.LAYOUT_SMUSH],
                [8192, "vLayout", FIGLet.LAYOUT_FIT],
                [4096, "vRule5", true],
                [2048, "vRule4", true],
                [1024, "vRule3", true],
                [512, "vRule2", true],
                [256, "vRule1", true],
                [128, "hLayout", FIGLet.LAYOUT_SMUSH],
                [64, "hLayout", FIGLet.LAYOUT_FIT],
                [32, "hRule6", true],
                [16, "hRule5", true],
                [8, "hRule4", true],
                [4, "hRule3", true],
                [2, "hRule2", true],
                [1, "hRule1", true]
            ]
            val := newLayout !== "" ? newLayout : oldLayout
            for code in codes {
                if val >= code[1] {
                    val := val - code[1]
                    if !rules.HasOwnProp(code[2]) {
                        rules.%code[2]% := code[3]
                    }
                }
                else if code[2] !== "vLayout" && code[2] !== "hLayout" {
                    rules.%code[2]% := false
                }
            }
            if !rules.HasOwnProp("hLayout") {
                if oldLayout == 0 {
                    rules.hLayout := FIGLet.LAYOUT_FIT
                }
                else if oldLayout == -1 {
                    rules.hLayout := FIGLet.LAYOUT_FULL
                }
                else {
                    if rules.hRule1 || rules.hRule2 || rules.hRule3 || rules.hRule4 || rules.hRule5 || rules.hRule6 {
                        rules.hLayout := FIGLet.LAYOUT_CONTROLLED_SMUSH
                    }
                    else {
                        rules.hLayout := FIGLet.LAYOUT_SMUSH
                    }
                }
            }
            else if rules.hLayout == FIGLet.LAYOUT_SMUSH {
                if rules.hRule1 || rules.hRule2 || rules.hRule3 || rules.hRule4 || rules.hRule5 || rules.hRule6 {
                    rules.hLayout := FIGLet.LAYOUT_CONTROLLED_SMUSH
                }
            }
            if !rules.HasOwnProp("vLayout") {
                if rules.vRule1 || rules.vRule2 || rules.vRule3 || rules.vRule4 || rules.vRule5 {
                    rules.vLayout := FIGLet.LAYOUT_CONTROLLED_SMUSH
                } else {
                    rules.vLayout := FIGLet.LAYOUT_FULL
                }
            }
            else if rules.vLayout == FIGLet.LAYOUT_SMUSH {
                if rules.vRule1 || rules.vRule2 || rules.vRule3 || rules.vRule4 || rules.vRule5 {
                    rules.vLayout := FIGLet.LAYOUT_CONTROLLED_SMUSH
                }
            }
            return rules
        }

        static splice(arr, index, length) {
            ret := []
            loop Min(arr.Length - index + 1, length) {
                ret.Push(arr.RemoveAt(index))
            }
            return ret
        }

        static parseInt(str) {
            if IsInteger(str) {
                return Integer(str)
            }
        }
    }

    Generate(txt) {
        if !this.Loaded || txt == "" {
            return
        }
        lines := StrSplit(txt, ["`r`n", "`n", "`r"])
        figLines := []
        len := lines.Length
        loop len {
            figLines.Push(generateFigTextLine(lines[A_Index], this.FigChars, this.Options))
        }
        len := figLines.Length
        output := figLines[1]
        loop len - 1 {
            output := smushVerticalFigLines(output, figLines[A_Index + 1], this.Options)
        }
        strOutput := ""
        for v in output {
            strOutput .= v (A_Index < output.Length ? "`r`n" : "")
        }
        return strOutput

        static hRule1_Smush(ch1, ch2, hardBlank) {
            if ch1 == ch2 && ch1 != hardBlank {
                return ch1
            }
            return false
        }

        static hRule2_Smush(ch1, ch2) {
            rule2Str := "|/\[]{}()<>"
            if ch1 == "_" {
                if InStr(rule2Str, ch2) {
                    return ch2
                }
            }
            else if ch2 == "_" {
                if InStr(rule2Str, ch1) {
                    return ch1
                }
            }
            return false
        }

        static hRule3_Smush(ch1, ch2) {
            rule3Classes := "| /\ [] {} () <>"
            r3_pos1 := InStr(rule3Classes, ch1)
            r3_pos2 := InStr(rule3Classes, ch2)
            if r3_pos1 && r3_pos2 {
                if r3_pos1 !== r3_pos2 && Abs(r3_pos1 - r3_pos2) !== 1 {
                    return SubStr(rule3Classes, Max(r3_pos1, r3_pos2), 1)
                }
            }
            return false
        }

        static hRule4_Smush(ch1, ch2) {
            rule4Str := "[] {} ()"
            r4_pos1 := InStr(rule4Str, ch1)
            r4_pos2 := InStr(rule4Str, ch2)
            if r4_pos1 && r4_pos2 {
                if Abs(r4_pos1 - r4_pos2) <= 1 {
                    return "|"
                }
            }
            return false
        }

        static hRule5_Smush(ch1, ch2) {
            rule5Str := "/\ \/ ><"
            rule5Hash := { 1: "|", 4: "Y", 7: "X" }
            r5_pos1 := InStr(rule5Str, ch1)
            r5_pos2 := InStr(rule5Str, ch2)
            if r5_pos1 && r5_pos2 {
                if r5_pos2 - r5_pos1 == 1 {
                    return rule5Hash.%r5_pos1%
                }
            }
            return false
        }

        static hRule6_Smush(ch1, ch2, hardBlank) {
            if ch1 == hardBlank && ch2 == hardBlank {
                return hardBlank
            }
            return false
        }

        static vRule1_Smush(ch1, ch2) {
            if ch1 == ch2 {
                return ch1
            }
            return false
        }

        static vRule2_Smush(ch1, ch2) {
            rule2Str := "|/\[]{}()<>"
            if ch1 == "_" {
                if InStr(rule2Str, ch2) {
                    return ch2
                }
            }
            else if ch2 == "_" {
                if InStr(rule2Str, ch1) {
                    return ch1
                }
            }
            return false
        }

        static vRule3_Smush(ch1, ch2) {
            rule3Classes := "| /\ [] {} () <>"
            r3_pos1 := InStr(rule3Classes, ch1)
            r3_pos2 := InStr(rule3Classes, ch2)
            if r3_pos1 && r3_pos2 {
                if r3_pos1 !== r3_pos2 && Abs(r3_pos1 - r3_pos2) !== 1 {
                    return SubStr(rule3Classes, Max(r3_pos1, r3_pos2), 1)
                }
            }
            return false
        }

        static vRule4_Smush(ch1, ch2) {
            if (ch1 == "-" && ch2 == "_") || (ch1 == "_" && ch2 == "-") {
                return "="
            }
            return false
        }

        static vRule5_Smush(ch1, ch2) {
            if ch1 == "|" && ch2 == "|" {
                return "|"
            }
            return false
        }

        static uni_Smush(ch1, ch2, hardBlank) {
            if ch2 == " " || ch2 == "" {
                return ch1
            }
            else if ch2 == hardBlank && ch1 !== " " {
                return ch1
            }
            return ch2
        }

        static canVerticalSmush(txt1, txt2, opts) {
            if opts.fittingRules.vLayout == FIGLet.LAYOUT_FULL {
                return "invalid"
            }
            len := Min(StrLen(txt1), StrLen(txt2))
            if len == 0 {
                return "invalid"
            }
            endSmush := false
            loop len {
                ch1 := SubStr(txt1, A_Index, 1)
                ch2 := SubStr(txt2, A_Index, 1)
                if ch1 != " " && ch2 != " " {
                    if opts.fittingRules.vLayout == FIGLet.LAYOUT_FIT {
                        return "invalid"
                    }
                    else if opts.fittingRules.vLayout == FIGLet.LAYOUT_SMUSH {
                        return "end"
                    }
                    else {
                        if vRule5_Smush(ch1, ch2) {
                            endSmush := endSmush || false
                            continue
                        }
                        validSmush := false
                        validSmush := opts.fittingRules.vRule1 ? vRule1_Smush(ch1, ch2) : validSmush
                        validSmush := !validSmush && opts.fittingRules.vRule2 ? vRule2_Smush(ch1, ch2) : validSmush
                        validSmush := !validSmush && opts.fittingRules.vRule3 ? vRule3_Smush(ch1, ch2) : validSmush
                        validSmush := !validSmush && opts.fittingRules.vRule4 ? vRule4_Smush(ch1, ch2) : validSmush
                        endSmush := true
                        if !validSmush {
                            return "invalid"
                        }
                    }
                }
            }
            if endSmush {
                return "end"
            }
            else {
                return "valid"
            }
        }

        static getVerticalSmushDist(lines1, lines2, opts) {
            maxDist := lines1.Length
            len1 := lines1.Length
            curDist := 1
            while curDist <= maxDist {
                subLines1 := slice(lines1, Max(0, len1 - curDist) + 1, len1 + 1)
                subLines2 := slice(lines2, 1, Min(maxDist, curDist) + 1)
                slen := subLines2.Length
                result := ""
                loop slen {
                    ret := canVerticalSmush(subLines1[A_Index], subLines2[A_Index], opts)
                    if ret == "end" {
                        result := ret
                    }
                    else if ret == "invalid" {
                        result := ret
                        break
                    }
                    else {
                        if result == "" {
                            result := "valid"
                        }
                    }
                }
                if result == "invalid" {
                    curDist--
                    break
                }
                if result == "end" {
                    break
                }
                if result == "valid" {
                    curDist++
                }
            }
            return Min(maxDist, curDist)
        }

        static verticallySmushLines(line1, line2, opts) {
            len := Min(StrLen(line1), StrLen(line2))
            result := ""
            loop len {
                ch1 := SubStr(line1, A_Index, 1)
                ch2 := SubStr(line2, A_Index, 1)
                if ch1 !== " " && ch2 !== " " {
                    if opts.fittingRules.vLayout == FIGLet.LAYOUT_FIT {
                        result .= uni_Smush(ch1, ch2, "")
                    }
                    else if opts.fittingRules.vLayout == FIGLet.LAYOUT_SMUSH {
                        result .= uni_Smush(ch1, ch2, "")
                    }
                    else {
                        validSmush := false
                        validSmush := opts.fittingRules.vRule5 ? vRule5_Smush(ch1, ch2) : validSmush
                        validSmush := !validSmush && opts.fittingRules.vRule1 ? vRule1_Smush(ch1, ch2) : validSmush
                        validSmush := !validSmush && opts.fittingRules.vRule2 ? vRule2_Smush(ch1, ch2) : validSmush
                        validSmush := !validSmush && opts.fittingRules.vRule3 ? vRule3_Smush(ch1, ch2) : validSmush
                        validSmush := !validSmush && opts.fittingRules.vRule4 ? vRule4_Smush(ch1, ch2) : validSmush
                        result .= validSmush
                    }
                }
                else {
                    result .= uni_Smush(ch1, ch2, "")
                }
            }
            return result
        }

        static verticalSmush(lines1, lines2, overlap, opts) {
            len1 := lines1.Length
            len2 := lines2.Length
            piece1 := slice(lines1, 1, Max(0, len1 - overlap) + 1)
            piece2_1 := slice(lines1, Max(0, len1 - overlap) + 1, len1 + 1)
            piece2_2 := slice(lines2, 1, Min(overlap, len2) + 1)
            piece2 := []
            len := piece2_1.Length
            loop len {
                if A_Index > len2 {
                    line := piece2_1[A_Index]
                }
                else {
                    line := verticallySmushLines(piece2_1[A_Index], piece2_2[A_Index], opts)
                }
                piece2.Push(line)
            }
            piece3 := slice(lines2, Min(overlap, len2) + 1, len2 + 1)
            piece1.Push(piece2*)
            piece1.Push(piece3*)
            return piece1
        }

        static padLines(lines, numSpaces) {
            padding := Format("{:" numSpaces "}", "")
            loop lines.Length {
                lines[A_Index] .= padding
            }
        }

        static smushVerticalFigLines(output, lines, opts) {
            len1 := StrLen(output[1])
            len2 := StrLen(lines[1])
            if len1 > len2 {
                padLines(lines, len1 - len2)
            }
            else if len2 > len1 {
                padLines(output, len2 - len1)
            }
            overlap := getVerticalSmushDist(output, lines, opts)
            return verticalSmush(output, lines, overlap, opts)
        }

        static getHorizontalSmushLength(txt1, txt2, opts) {
            if opts.fittingRules.hLayout == FIGLet.LAYOUT_FULL {
                return 0
            }
            len1 := StrLen(txt1)
            if len1 == 0 {
                return 0
            }
            len2 := StrLen(txt2)
            maxDist := len1
            curDist := 1
            breakAfter := false
            validSmush := false
            while curDist <= maxDist {
                seg1 := SubStr(txt1, len1 - curDist + 1, curDist)
                seg2 := SubStr(txt2, 1, Min(curDist, len2))
                loop Min(curDist, len2) {
                    ch1 := SubStr(seg1, A_Index, 1)
                    ch2 := SubStr(seg2, A_Index, 1)
                    if ch1 !== " " && ch2 !== " " {
                        if opts.fittingRules.hLayout == FIGLet.LAYOUT_FIT {
                            curDist--
                            break 2
                        }
                        else if opts.fittingRules.hLayout == FIGLet.LAYOUT_SMUSH {
                            if ch1 == opts.hardBlank || ch2 == opts.hardBlank
                                curDist--
                            break 2
                        }
                        else {
                            breakAfter := true
                            validSmush := false
                            validSmush := opts.fittingRules.hRule1 ? hRule1_Smush(ch1, ch2, opts.hardBlank) : validSmush
                            validSmush := !validSmush && opts.fittingRules.hRule2 ? hRule2_Smush(ch1, ch2) : validSmush
                            validSmush := !validSmush && opts.fittingRules.hRule3 ? hRule3_Smush(ch1, ch2) : validSmush
                            validSmush := !validSmush && opts.fittingRules.hRule4 ? hRule4_Smush(ch1, ch2) : validSmush
                            validSmush := !validSmush && opts.fittingRules.hRule5 ? hRule5_Smush(ch1, ch2) : validSmush
                            validSmush := !validSmush && opts.fittingRules.hRule6 ? hRule6_Smush(ch1, ch2, opts.hardBlank) : validSmush
                            if !validSmush {
                                curDist--
                                break 2
                            }
                        }
                    }
                }
                if breakAfter {
                    break
                }
                curDist++
            }
            return Min(maxDist, curDist)
        }

        static horizontalSmush(textBlock1, textBlock2, overlap, opts) {
            outputFig := []
            loop opts.height {
                txt1 := textBlock1[A_Index]
                txt2 := textBlock2[A_Index]
                len1 := StrLen(txt1)
                len2 := StrLen(txt2)
                overlapStart := len1 - overlap
                piece1 := SubStr(txt1, 1, Max(0, overlapStart))
                piece2 := ""
                seg1 := SubStr(txt1, Max(1, len1 - overlap + 1), overlap)
                seg2 := SubStr(txt2, 1, Min(overlap, len2))
                loop overlap {
                    ch1 := A_Index < len1 ? SubStr(seg1, A_Index, 1) : " "
                    ch2 := A_Index < len2 ? SubStr(seg2, A_Index, 1) : " "
                    if ch1 !== " " && ch2 !== " " {
                        if opts.fittingRules.hLayout == FIGLet.LAYOUT_FIT {
                            piece2 .= uni_Smush(ch1, ch2, opts.hardBlank)
                        }
                        else if opts.fittingRules.hLayout == FIGLet.LAYOUT_SMUSH {
                            piece2 .= uni_Smush(ch1, ch2, opts.hardBlank)
                        }
                        else {
                            nextCh := ""
                            nextCh := !nextCh && opts.fittingRules.hRule1 ? hRule1_Smush(ch1, ch2, opts.hardBlank) : nextCh
                            nextCh := !nextCh && opts.fittingRules.hRule2 ? hRule2_Smush(ch1, ch2) : nextCh
                            nextCh := !nextCh && opts.fittingRules.hRule3 ? hRule3_Smush(ch1, ch2) : nextCh
                            nextCh := !nextCh && opts.fittingRules.hRule4 ? hRule4_Smush(ch1, ch2) : nextCh
                            nextCh := !nextCh && opts.fittingRules.hRule5 ? hRule5_Smush(ch1, ch2) : nextCh
                            nextCh := !nextCh && opts.fittingRules.hRule6 ? hRule6_Smush(ch1, ch2, opts.hardBlank) : nextCh
                            nextCh := nextCh || uni_Smush(ch1, ch2, opts.hardBlank)
                            piece2 .= nextCh
                        }
                    }
                    else {
                        piece2 .= uni_Smush(ch1, ch2, opts.hardBlank)
                    }
                }
                if overlap >= len2 {
                    piece3 := ""
                }
                else {
                    piece3 := SubStr(txt2, overlap + 1, Max(0, len2 - overlap))
                }
                outputFig.Push(piece1 piece2 piece3)
            }
            return outputFig
        }

        static generateFigTextLine(txt, figChars, opts) {
            outputFigText := []
            loop opts.height {
                outputFigText.Push("")
            }
            len := StrLen(txt)
            loop parse txt {
                figChar := figChars[Ord(A_LoopField)]
                if figChar {
                    overlap := 0
                    if opts.fittingRules.hLayout !== FIGLet.LAYOUT_FULL {
                        overlap := 10000
                        loop opts.height {
                            overlap := Min(overlap, getHorizontalSmushLength(outputFigText[A_Index], figChar[A_Index], opts))
                        }
                        overlap := overlap == 10000 ? 0 : overlap
                    }
                    outputFigText := horizontalSmush(outputFigText, figChar, overlap, opts)
                }
            }
            for v in outputFigText {
                outputFigText[A_Index] := RegExReplace(v, "\" opts.hardBlank, " ")
            }
            return outputFigText
        }

        static slice(arr, start, end) {
            ret := []
            loop Min(arr.Length + 1, end) - start {
                ret.Push(arr[start++])
            }
            return ret
        }
    }

    HorizontalLayout {
        get => this.Options.FittingRules.hLayout
        set {
            switch value {
                case FIGLet.LAYOUT_DEFAULT:
                    _ := this.__DefaultFittingRules
                    params := { hLayout: _.hLayout, hRule1: _.hRule1, hRule2: _.hRule2, hRule3: _.hRule3, hRule4: _.hRule4, hRule5: _.hRule5, hRule6: _.hRule6 }
                case FIGLet.LAYOUT_FULL:
                    params := { hLayout: value, hRule1: false, hRule2: false, hRule3: false, hRule4: false, hRule5: false, hRule6: false }
                case FIGLet.LAYOUT_FIT:
                    params := { hLayout: value, hRule1: false, hRule2: false, hRule3: false, hRule4: false, hRule5: false, hRule6: false }
                case FIGLet.LAYOUT_SMUSH:
                    params := { hLayout: value, hRule1: false, hRule2: false, hRule3: false, hRule4: false, hRule5: false, hRule6: false }
                case FIGLet.LAYOUT_CONTROLLED_SMUSH:
                    params := { hLayout: value, hRule1: true, hRule2: true, hRule3: true, hRule4: true, hRule5: true, hRule6: true }
                default:
                    throw Error("Invalid layout")
            }
            for k, v in params.OwnProps() {
                this.Options.FittingRules.%k% := v
            }
        }
    }

    VerticalLayout {
        get => this.Options.FittingRules.vLayout
        set {
            switch value {
                case FIGLet.LAYOUT_DEFAULT:
                    _ := this.__DefaultFittingRules
                    params := { vLayout: _.vLayout, vRule1: _.vRule1, vRule2: _.vRule2, vRule3: _.vRule3, vRule4: _.vRule4, vRule5: _.vRule5 }
                case FIGLet.LAYOUT_FULL:
                    params := { vLayout: value, vRule1: false, vRule2: false, vRule3: false, vRule4: false, vRule5: false }
                case FIGLet.LAYOUT_FIT:
                    params := { vLayout: value, vRule1: false, vRule2: false, vRule3: false, vRule4: false, vRule5: false }
                case FIGLet.LAYOUT_SMUSH:
                    params := { vLayout: value, vRule1: false, vRule2: false, vRule3: false, vRule4: false, vRule5: false }
                case FIGLet.LAYOUT_CONTROLLED_SMUSH:
                    params := { vLayout: value, vRule1: true, vRule2: true, vRule3: true, vRule4: true, vRule5: true }
                default:
                    throw Error("Invalid layout")
            }
            for k, v in params.OwnProps() {
                this.Options.FittingRules.%k% := v
            }
        }
    }
}