; Reference:
; https://www.cnblogs.com/wxl845235800/p/11079403.html
; https://blog.csdn.net/lz0499/article/details/77345166
; https://www.jianshu.com/p/86e8c3acd41d

; AutoHotkey v2.0-beta 2
; 使用LAB模型+CIEDE2000算法获取两个颜色的色差，值越大，相似度越小

; 使用例，填入两个需要对比的16进制数值
DeltaE := GetDeltaEByHex(0x000000, 0xffffff)
MsgBox("白色和黑色的色差为：" DeltaE)
DeltaE := GetDeltaEByHex("0x4C974C", "0x4D78CC")
MsgBox("蓝色和深蓝色的色差为：" DeltaE)

GetDeltaEByHex(hex1, hex2) {
    RGB1 := Hex2RGB(hex1)
    RGB2 := Hex2RGB(hex2)

    XYZ1 := RGB2XYZ(RGB1.R, RGB1.G, RGB1.B)
    XYZ2 := RGB2XYZ(RGB2.R, RGB2.G, RGB2.B)

    Lab1 := XYZ2Lab(XYZ1.X, XYZ1.Y, XYZ1.Z)
    Lab2 := XYZ2Lab(XYZ2.X, XYZ2.Y, XYZ2.Z)

    return GetDeltaEByLab(Lab1.L, Lab1.a, Lab1.b, Lab2.L, Lab2.a, Lab2.b)
}

; 16进制转化为RGB
Hex2RGB(hex) {
    R := (hex & 0xFF0000) >> 16
    G := (hex & 0x00FF00) >> 8
    B := (hex & 0x0000FF) >> 0
    return { R: R, G: G, B: B }
}
; RGB转化为16进制
RGB2Hex(r, g, b) => Format("0x{:06x}", (r << 16) + (g << 8) + b)

; RGB转换为XYZ
RGB2XYZ(R, G, B) {
    RR := Gamma(R / 255), GG := Gamma(G / 255), BB := Gamma(B / 255)
    X := 0.4124564 * RR + 0.3575761 * GG + 0.1804375 * BB
    Y := 0.2126729 * RR + 0.7151522 * GG + 0.0721750 * BB
    Z := 0.0193339 * RR + 0.1191920 * GG + 0.9503041 * BB
    return { X: X, Y: Y, Z: Z }
}

; 色彩矫正
Gamma(x) => (x > 0.04045) ? ((x + 0.055) / 1.055) ** 2.4 : x / 12.92

XYZ2Lab(X, Y, Z) {
    static param_13 := 1 / 3
        , param_16116 := 16 / 116
        , Xn := 0.950456
        , Yn := 1
        , Zn := 1.088754

    X /= Xn
    Y /= Yn
    Z /= Zn

    fY := (Y > 0.008856) ? Y ** param_13 : 7.787 * Y + param_16116
    fX := (X > 0.008856) ? X ** param_13 : 7.787 * X + param_16116
    fZ := (Z > 0.008856) ? Z ** param_13 : 7.787 * Z + param_16116

    L := 116 * fY - 16
    L := (L > 0) ? L : 0
    a := 500 * (fX - fY)
    b := 200 * (fY - fZ)
    return { L: L, a: a, b: b }
}

GetDeltaEByLab(L1, a1, b1, L2, a2, b2) {
    static pi := 3.141592653589793
        , kL := 1
        , kC := 1
        , kH := 1

    mean_Cab := (GetChroma(a1, b1) + GetChroma(a2, b2))    ; 两个样品彩度的算术平均值
    mean_Cab_pow7 := mean_Cab ** 7
    G := 0.5 * (1 - (mean_Cab_pow7 / (mean_Cab_pow7 + 25 ** 7)) ** 0.5)    ; G表示CIELab 颜色空间a轴的调整因子,是彩度的函数.

    LL1 := L1, aa1 := a1 * (1 + G), bb1 := b1
    LL2 := L2, aa2 := a2 * (1 + G), bb2 := b2

    cc1 := GetChroma(aa1, bb1)    ; 两样本的彩度值
    cc2 := GetChroma(aa2, bb2)

    hh1 := GetHueAngle(aa1, bb1)    ; 两样本的色调角
    hh2 := GetHueAngle(aa2, bb2)

    delta_LL := LL1 - LL2
    delta_CC := cc1 - cc2
    delta_hh := hh1 - hh2
    delta_HH := 2 * Sin(pi * delta_hh / 360) * (cc1 * cc2) ** 0.5

    mean_LL := (LL1 + LL2) / 2
    mean_cc := (cc1 + cc2) / 2
    mean_hh := (hh1 + hh2) / 2

    SL := 1 + 0.015 * ((mean_LL - 50) ** 2) / (20 + (mean_LL - 50) ** 2) ** 0.5
    SC := 1 + 0.045 * mean_cc
    T := 1 - 0.17 * Cos((mean_hh - 30) * pi / 180) + 0.24 * Cos(2 * mean_hh * pi / 180) + 0.32 * Cos((3 * mean_hh + 6) * pi / 180) - 0.2 * cos((4 * mean_hh - 63) * pi / 180)
    SH := 1 + 0.015 * mean_cc * T

    mean_Cab_pow7 := mean_cc ** 7
    RC := 2 * (mean_Cab_pow7 / (mean_Cab_pow7 + 25 ** 7)) ** 0.5
    delta_xita := 30 * Exp(-((mean_hh - 275) / 25) ** 2)
    RT := -Sin((2 * delta_xita) * pi / 180) * RC    ; 旋转函数RT

    L_item := delta_LL / (kL * SL)
    C_item := delta_CC / (kC * SC)
    H_item := delta_HH / (kH * SH)

    return (L_item * L_item + C_item * C_item + H_item * H_item + RT * C_item * H_item) ** 0.5
}

; 彩度计算
GetChroma(a, b) => (a * a + b * b) ** 0.5

; 色调角计算
GetHueAngle(a, b) {
    if a = 0
        return 90

    static pi := 3.141592653589793
    h := (180 / pi) * Tan(b / a)

    if a > 0 and b > 0
        return h
    else if a < 0 and b > 0
        return 180 + h
    else if a < 0 and b < 0
        return 180 + h
    else
        return 360 + h
}