package com.bjpowernode.crm.commons.utils;

import java.util.UUID;

public class UUIDUtils {
    public static String getUUID(){
        String s = UUID.randomUUID().toString().replaceAll("-", "");
        return s;
    }
}
