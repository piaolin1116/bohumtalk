package com.bohumtalk.app.util;

import java.io.UnsupportedEncodingException;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.Key;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import android.util.Base64;

public class AesUtil {
    private String iv;
    private byte[] ivbyte;
    private Key keySpec;
    private SecretKeySpec md5KeySpec;
    private IvParameterSpec initalVector;

    public AesUtil(String key) throws UnsupportedEncodingException {
        this(key, key.substring(0,16), 16);
    }

    public AesUtil(String key, String ivVal) throws UnsupportedEncodingException {

        this(key, ivVal, 16);
    }
    public AesUtil(String key, String ivVal, int length) throws UnsupportedEncodingException {

        this.iv = ivVal;

        this.ivbyte = new byte[16];

        byte[] ivImsiByte = ivVal.getBytes("UTF-8");
        int ivLength = ivImsiByte.length>16?16:ivImsiByte.length;
        System.arraycopy(ivImsiByte, 0, this.ivbyte, 0, ivLength);

        byte[] keyBytes = new byte[length];
        byte[] b = key.getBytes("UTF-8");
        int len = b.length;
        if (len > keyBytes.length) {
            len = keyBytes.length;
        }
        System.arraycopy(b, 0, keyBytes, 0, len);
        SecretKeySpec keySpec = new SecretKeySpec(keyBytes, "AES");

        this.keySpec = keySpec;
    }



    public AesUtil(byte[] key, byte[] ivVal) throws Exception {
        MessageDigest md5 = MessageDigest.getInstance("MD5");
        this.md5KeySpec = new SecretKeySpec(md5.digest(key), "AES");
        this.initalVector = new IvParameterSpec(md5.digest(ivVal));
    }

    // 암호화
    public String aesEncode(String str) throws java.io.UnsupportedEncodingException,
            NoSuchAlgorithmException,
            NoSuchPaddingException,
            InvalidKeyException,
            InvalidAlgorithmParameterException,
            IllegalBlockSizeException,
            BadPaddingException {
        Cipher c = Cipher.getInstance("AES/CBC/PKCS5Padding");
        c.init(Cipher.ENCRYPT_MODE, keySpec, new IvParameterSpec(this.ivbyte));

        byte[] encrypted = c.doFinal(str.getBytes("UTF-8"));
        String enStr = new String(Base64.encode(encrypted,Base64.DEFAULT));

        return enStr;
    }

    //복호화
    public String aesDecode(String str) throws java.io.UnsupportedEncodingException,
            NoSuchAlgorithmException,
            NoSuchPaddingException,
            InvalidKeyException,
            InvalidAlgorithmParameterException,
            IllegalBlockSizeException,
            BadPaddingException {
        Cipher c = Cipher.getInstance("AES/CBC/PKCS5Padding");
        c.init(Cipher.DECRYPT_MODE, keySpec, new IvParameterSpec(this.ivbyte));

        byte[] byteStr = Base64.decode(str.getBytes(),Base64.DEFAULT);

        return new String(c.doFinal(byteStr),"UTF-8");
    }

    // 암호화
    public String aesNoPaddingEncode(String str) throws java.io.UnsupportedEncodingException,
            NoSuchAlgorithmException,
            NoSuchPaddingException,
            InvalidKeyException,
            InvalidAlgorithmParameterException,
            IllegalBlockSizeException,
            BadPaddingException {
        Cipher c = Cipher.getInstance("AES/CBC/NoPadding");
        c.init(Cipher.ENCRYPT_MODE, keySpec, new IvParameterSpec(iv.getBytes()));

        byte[] encrypted = c.doFinal(padString(str).getBytes("UTF-8"));
        String enStr = new String(Base64.encode(encrypted,Base64.DEFAULT));

        return enStr;
    }

    //복호화
    public String aesNoPaddingDecode(String str) throws java.io.UnsupportedEncodingException,
            NoSuchAlgorithmException,
            NoSuchPaddingException,
            InvalidKeyException,
            InvalidAlgorithmParameterException,
            IllegalBlockSizeException,
            BadPaddingException {
        Cipher c = Cipher.getInstance("AES/CBC/NoPadding");
        c.init(Cipher.DECRYPT_MODE, keySpec, new IvParameterSpec(iv.getBytes("UTF-8")));

        byte[] byteStr = Base64.decode(str.getBytes(),Base64.DEFAULT);

        return new String(c.doFinal(byteStr),"UTF-8");
    }

    // 암호화
    public String aesMD5Encode(String str) throws java.io.UnsupportedEncodingException,
            NoSuchAlgorithmException,
            NoSuchPaddingException,
            InvalidKeyException,
            InvalidAlgorithmParameterException,
            IllegalBlockSizeException,
            BadPaddingException {
        Cipher c = Cipher.getInstance("AES/CBC/PKCS5Padding");
        c.init(Cipher.ENCRYPT_MODE, md5KeySpec, initalVector);

        byte[] encrypted = c.doFinal(str.getBytes("UTF-8"));
        String enStr = new String(Base64.encode(encrypted,Base64.DEFAULT));

        return enStr;
    }

    //복호화
    public String aesMD5Decode(String str) throws java.io.UnsupportedEncodingException,
            NoSuchAlgorithmException,
            NoSuchPaddingException,
            InvalidKeyException,
            InvalidAlgorithmParameterException,
            IllegalBlockSizeException,
            BadPaddingException {
        Cipher c = Cipher.getInstance("AES/CBC/PKCS5Padding");
        c.init(Cipher.DECRYPT_MODE, md5KeySpec, initalVector);

        byte[] byteStr = Base64.decode(str.getBytes(),Base64.DEFAULT);

        return new String(c.doFinal(byteStr),"UTF-8");
    }

    public String padString(String source)
    {
        char paddingChar = ' ';
        int size = 16;
        int x = source.length() % size;
        int padLength = size - x;

        for (int i = 0; i < padLength; i++)
        {
            source += paddingChar;
        }

        return source;
    }

}