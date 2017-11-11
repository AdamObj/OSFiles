//
//  OSPhoneUtils.m
//  FileDownloader
//
//  Created by Swae on 2017/11/11.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "OSPhoneUtils.h"
#import "RMPhoneFormat.h"

@implementation OSPhoneUtils

+ (NSString *)formatPhone:(NSString *)phone forceInternational:(bool)forceInternational
{
    if (phone == nil)
        return @"";
    
    return [[RMPhoneFormat instance] format:phone implicitPlus:forceInternational];
}

+ (NSString *)formatPhoneUrl:(NSString *)phone
{
    if (phone == nil)
        return @"";
    
    unichar cleanPhone[phone.length];
    int cleanPhoneLength = 0;
    
    int length = (int)phone.length;
    for (int i = 0; i < length; i++)
    {
        unichar c = [phone characterAtIndex:i];
        if (!(c == ' ' || c == '(' || c == ')' || c == '-'))
            cleanPhone[cleanPhoneLength++] = c;
    }
    
    return [[NSString alloc] initWithCharacters:cleanPhone length:cleanPhoneLength];
}

+ (NSString *)cleanPhone:(NSString *)phone
{
    if (phone.length == 0)
        return @"";
    
    char buf[phone.length];
    int bufPtr = 0;
    
    int length = (int)phone.length;
    for (int i = 0; i < length; i++)
    {
        unichar c = [phone characterAtIndex:i];
        if (c >= '0' && c <= '9')
        {
            buf[bufPtr++] = (char)c;
        }
    }
    
    return [[NSString alloc] initWithBytes:buf length:bufPtr encoding:NSUTF8StringEncoding];
}

+ (NSString *)cleanInternationalPhone:(NSString *)phone forceInternational:(bool)forceInternational
{
    if (phone.length == 0)
        return @"";
    
    char buf[phone.length];
    int bufPtr = 0;
    
    bool hadPlus = false;
    int length = (int)phone.length;
    for (int i = 0; i < length; i++)
    {
        unichar c = [phone characterAtIndex:i];
        if ((c >= '0' && c <= '9') || (c == '+' && !hadPlus))
        {
            buf[bufPtr++] = (char)c;
            if (c == '+')
                hadPlus = true;
        }
    }
    
    NSString *result = [[NSString alloc] initWithBytes:buf length:bufPtr encoding:NSUTF8StringEncoding];
    if (forceInternational && bufPtr != 0 && buf[0] != '+')
        result = [[NSString alloc] initWithFormat:@"+%@", result];
    return result;
}


@end
