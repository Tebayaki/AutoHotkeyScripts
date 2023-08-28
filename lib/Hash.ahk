; MsgBox HashString("a", "MD5", "UTF-8").ToString()
; MsgBox HashNumber(97, "MD5", "char").ToString()
; MsgBox HashFile(A_ScriptFullPath, "SHA256").ToString()
; MsgBox Hash(Buffer(100, 0), "MD5").ToString()

HashString(str, algorithm, encoding := "UTF-8") {
    if encoding = "UTF-16" || encoding = "CP1200"
        return Hash({Ptr: StrPtr(str), Size: StrPut(str) - (str = "" ? 0 : 2)}, algorithm)
    buf := Buffer(StrPut(str, encoding))
    StrPut(str, buf, encoding)
    buf.Size -= (str = "" ? 0 : 1)
    return Hash(buf, algorithm)
}

HashNumber(num, algorithm, type := "int") {
    static sizeof := {Char: 1, UChar: 1, Short: 2, UShort: 2, Int: 4, UInt: 4, Ptr: A_PtrSize, UPtr: A_PtrSize, Int64: 8, UInt64: 8, Float: 4, Double: 8}
    buf := Buffer(sizeof.%type%), NumPut(type, num, buf)
    return Hash(buf, algorithm)
}

HashFile(filename, algorithm) {
    fileObj := FileOpen(filename, "r")
    if hFileMapping := DllCall("CreateFileMappingW", "ptr", fileObj.Handle, "ptr", 0, "uint", 0x02, "uint", 0, "uint", 0, "ptr", 0, "ptr") {
        if pView := DllCall("MapViewOfFile", "ptr", hFileMapping, "uint", 0x0004, "uint", 0, "uint", 0, "uptr", 0, "ptr") {
            res := Hash({Ptr: pView, Size: fileObj.Length}, algorithm)
            DllCall("UnmapViewOfFile", "ptr", pView)
        }
        DllCall("CloseHandle", "ptr", hFileMapping)
    }
    return res ?? ""
}

/*
@BCrypt_RSA_ALGORITHM                    L"RSA"
@BCrypt_RSA_SIGN_ALGORITHM               L"RSA_SIGN"
@BCrypt_DH_ALGORITHM                     L"DH"
@BCrypt_DSA_ALGORITHM                    L"DSA"
@BCrypt_RC2_ALGORITHM                    L"RC2"
@BCrypt_RC4_ALGORITHM                    L"RC4"
@BCrypt_AES_ALGORITHM                    L"AES"
@BCrypt_DES_ALGORITHM                    L"DES"
@BCrypt_DESX_ALGORITHM                   L"DESX"
@BCrypt_3DES_ALGORITHM                   L"3DES"
@BCrypt_3DES_112_ALGORITHM               L"3DES_112"
@BCrypt_MD2_ALGORITHM                    L"MD2"
@BCrypt_MD4_ALGORITHM                    L"MD4"
@BCrypt_MD5_ALGORITHM                    L"MD5"
@BCrypt_SHA1_ALGORITHM                   L"SHA1"
@BCrypt_SHA256_ALGORITHM                 L"SHA256"
@BCrypt_SHA384_ALGORITHM                 L"SHA384"
@BCrypt_SHA512_ALGORITHM                 L"SHA512"
@BCrypt_AES_GMAC_ALGORITHM               L"AES-GMAC"
@BCrypt_AES_CMAC_ALGORITHM               L"AES-CMAC"
@BCrypt_ECDSA_P256_ALGORITHM             L"ECDSA_P256"
@BCrypt_ECDSA_P384_ALGORITHM             L"ECDSA_P384"
@BCrypt_ECDSA_P521_ALGORITHM             L"ECDSA_P521"
@BCrypt_ECDH_P256_ALGORITHM              L"ECDH_P256"
@BCrypt_ECDH_P384_ALGORITHM              L"ECDH_P384"
@BCrypt_ECDH_P521_ALGORITHM              L"ECDH_P521"
@BCrypt_RNG_ALGORITHM                    L"RNG"
@BCrypt_RNG_FIPS186_DSA_ALGORITHM        L"FIPS186DSARNG"
@BCrypt_RNG_DUAL_EC_ALGORITHM            L"DUALECRNG"

#if (NTDDI_VERSION >= NTDDI_WIN8)
@BCrypt_SP800108_CTR_HMAC_ALGORITHM      L"SP800_108_CTR_HMAC"
@BCrypt_SP80056A_CONCAT_ALGORITHM        L"SP800_56A_CONCAT"
@BCrypt_PBKDF2_ALGORITHM                 L"PBKDF2"
@BCrypt_CAPI_KDF_ALGORITHM               L"CAPI_KDF"
@BCrypt_TLS1_1_KDF_ALGORITHM             L"TLS1_1_KDF"
@BCrypt_TLS1_2_KDF_ALGORITHM             L"TLS1_2_KDF"
#endif

#if (NTDDI_VERSION >= NTDDI_WINTHRESHOLD)
@BCrypt_ECDSA_ALGORITHM                  L"ECDSA"
@BCrypt_ECDH_ALGORITHM                   L"ECDH"
@BCrypt_XTS_AES_ALGORITHM                L"XTS-AES"
#endif

#if (NTDDI_VERSION >= NTDDI_WIN10_RS4)
@BCrypt_HKDF_ALGORITHM                   L"HKDF"
#endif

#if (NTDDI_VERSION >= NTDDI_WIN10_FE)
@BCrypt_CHACHA20_POLY1305_ALGORITHM      L"CHACHA20_POLY1305"
*/
Hash(data, algorithm) {
    if !DllCall("BCrypt\BCryptOpenAlgorithmProvider", "ptr*", &hAlg := 0, "wstr", algorithm, "ptr", 0, "uint", 0) {
        if !DllCall("BCrypt\BCryptGetProperty", "ptr", hAlg, "wstr", "ObjectLength", "uint*", &cbHashObject := 0, "uint", 4, "uint*", 0, "uint", 0)
            && !DllCall("BCrypt\BCryptGetProperty", "ptr", hAlg, "wstr", "HashDigestLength", "uint*", &cbHash := 0, "uint", 4, "uint*", 0, "uint", 0)
            && !DllCall("BCrypt\BCryptCreateHash", "ptr", hAlg, "ptr*", &hHash := 0, "ptr", bHashObject := Buffer(cbHashObject), "uint", cbHashObject, "ptr", 0, "uint", 0, "uint", 0) {
            if !DllCall("BCrypt\BCryptHashData", "ptr", hHash, "ptr", data, "uint", data.Size, "uint", 0)
                status := DllCall("BCrypt\BCryptFinishHash", "ptr", hHash, "ptr", bHash := Buffer(cbHash), "uint", cbHash, "uint", 0)
            DllCall("BCrypt\BCryptDestroyHash", "ptr", hHash)
        }
        DllCall("BCrypt\BCryptCloseAlgorithmProvider", "ptr", hAlg, "uint", 0)
    }
    if IsSet(status) && !status {
        bHash.ToString := CryptBinaryToString
        return bHash
    }

    CryptBinaryToString(binary) {
        DllCall("crypt32\CryptBinaryToStringW", "ptr", binary, "uint", binary.Size, "uint", 0x4000000C, "ptr", 0, "uint*", &cnt := 0)
        VarSetStrCapacity(&str, cnt * 2)
        DllCall("crypt32\CryptBinaryToStringW", "ptr", binary, "uint", binary.Size, "uint", 0x4000000C, "wstr", str, "uint*", cnt)
        return str
    }
}