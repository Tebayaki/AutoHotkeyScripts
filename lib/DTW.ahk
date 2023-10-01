/*
rewrite from python dtw
@example
x := [6, 3, 5, 7, 5]
y := [5, 4, 6, 8, 3]
res := DTW(x, y, (a, b) => Abs(a - b))
MsgBox res.MinDistance / res.Path.Length
*/
DTW(x, y, dist, warp := 1, window := 'inf', weight := 1) {
    static INF := NumGet(ObjPtr(&_ := 0x7F800000) + A_PtrSize * 2, "float")
    window := window == 'inf' ? INF : window
    r := x.Length, c := y.Length
    if window != 'inf' {
        D0 := full(r + 1, c + 1, INF)
        for i in range(1, r + 1)
            for j in range(max(1, i - window), min(c + 1, i + window + 1))
                D0[i + 1][j + 1] := 0
        D0[1][1] := 0
    }
    else {
        D0 := full(r + 1, c + 1)
        loop c
            D0[1][A_Index + 1] := INF
        loop r
            D0[A_Index + 1][1] := INF
    }

    for i in range(0, r)
        for j in range(0, c)
            if window == INF || (j >= max(0, i - window) && j <= min(c, i + window))
                D0[i + 2][j + 2] := dist(x[i + 1], y[j + 1])

    for v in Cost := ((_, arr*) => arr)(D0*)
        Cost[A_Index] := ((_?, arr*) => arr)(v*)

    for i in range(0, r) {
        if window != INF
            jrange := range(max(0, i - window), min(c, i + window + 1))
        for j in jrange ?? range(0, c) {
            min_list := [D0[i + 1][j + 1]]
            for k in range(1, warp + 1) {
                i_k := min(i + k, r)
                j_k := min(j + k, c)
                min_list.Push(D0[i_k + 1][j + 1] * weight, D0[i + 1][j_k + 1] * weight)
            }
            D0[i + 2][j + 2] += min(min_list*)
        }
    }
    if r == 1 {
        path := []
        loop c
            path.Push([1, A_Index])
    }
    else if c == 1 {
        path := []
        loop r
            path.Push([A_Index, 1])
    }
    else {
        path := traceBack(D0)
    }

    for v in D1 := ((_, arr*) => arr)(D0*)
        D1[A_Index] := ((_?, arr*) => arr)(v*)

    return { MinDistance: D1[-1][-1], CostMatrix: Cost, AccMatrix: D1, Path: path }

    static range(start, stop) => ((&i) => stop > i := start++)

    static full(len1, len2, fill := 0) {
        static d2 := []
        d1 := []
        d1.Length := len1
        d2.Length := len2
        d2.Default := fill
        loop len1
            d1[A_Index] := d2.Clone()
        return d1
    }

    static traceBack(D) {
        i := D.Length - 1, j := D[1].Length - 1
        path := [[i, j]]
        while i > 1 || j > 1 {
            switch Min(a := D[i][j], b := D[i][j + 1], D[i + 1][j]) {
                case a: i--, j--
                case b: i--
                default: j--
            }
            path.InsertAt(1, [i, j])
        }
        return path
    }
}

SimpleDTW(x, y, dist) {
    static inf := NumGet(ObjPtr(&_ := 0x7F800000) + A_PtrSize * 2, "float")
    r := x.Length, c := y.Length
    D := ComObjArray(5, r + 1, c + 1)
    loop c
        D[0, A_Index] := inf
    loop r
        D[A_Index, 0] := inf
    D[0, 0] := 0
    loop r {
        i := A_Index
        loop c
            D[i, A_Index] := dist(x[i], y[A_Index]) + min(D[i - 1, A_Index - 1], D[i, A_Index - 1], D[i - 1, A_Index])
    }
    ; traceback
    i := r - 1, j := c - 1, count := 1
    while i && j {
        switch min(a := D[i, j], b := D[i, j + 1], D[i + 1, j]) {
            case a: i--, j--
            case b: i--
            default: j--
        }
        count++
    }
    return D[r, c] / (count + i + j)
}
