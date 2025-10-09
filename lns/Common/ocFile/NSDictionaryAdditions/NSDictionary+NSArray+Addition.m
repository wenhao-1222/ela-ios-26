//
//  NSDictionary+NSArray+Addition.m
//  WeiboPad
//
//  Created by junmin liu on 10-10-6.
//  Copyright 2010 Openlab. All rights reserved.
//

#import "NSDictionary+NSArray+Addition.h"


@implementation NSDictionary (Additions)

- (BOOL)boolValueForKey:(NSString *)key {
    return [self boolValueForKey:key defaultValue:NO];
}

- (BOOL)boolValueForKey:(NSString *)key defaultValue:(BOOL)defaultValue {
    id value = [self objectForKey:key];
    
    if (value == [NSNull null] || value == nil) {
        return defaultValue;
    } else {
        return [value boolValue];
    }
}

- (int)intValueForKey:(NSString *)key {
    return [self intValueForKey:key defaultValue:0];
}

- (int)intValueForKey:(NSString *)key defaultValue:(int)defaultValue {
    id value = [self objectForKey:key];
    
    if (value == [NSNull null] || value == nil) {
        return defaultValue;
    } else {
        return [value intValue];
    }
}

- (NSString *)stringValueForKey:(NSString *)key {
    return [self stringValueForKey:key defaultValue:@""];
}

- (NSString *)stringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    id value = [self objectForKey:key];
    if (value == nil || value == [NSNull null]) {
        return defaultValue;
    }
    
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }
    
    return value;
}

- (long long)longLongValueForKey:(NSString *)key {
    return [self longLongValueForKey:key defaultValue:0];
}

- (long long)longLongValueForKey:(NSString *)key defaultValue:(long long)defaultValue {
	id value = [self objectForKey:key];
    
    if (value == [NSNull null] || value == nil) {
        return defaultValue;
    } else {
        return [value longLongValue];
    }
}

- (double)doubleValueForKey:(NSString *)key {
    return [self doubleValueForKey:key defaultValue:0];
}

- (double)doubleValueForKey:(NSString *)key defaultValue:(double)defaultValue {
	id value = [self objectForKey:key];
    
    if (value == [NSNull null] || value == nil) {
        return defaultValue;
    } else {
        return [value doubleValue];
    }
}

- (NSDictionary *)dictionaryValueForKey:(NSString *)key {
    NSObject *obj = [self objectForKey:key];
    if (obj && [obj isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)obj;
    }
    return nil;
}

- (NSArray *)arrayValueForKey:(NSString *)key {
    NSObject *obj = [self objectForKey:key];
    if (obj && [obj isKindOfClass:[NSArray class]]) {
        return (NSArray *)obj;
    }
    return nil;
}

- (time_t)timeValueForKey:(NSString *)key {
    return [self timeValueForKey:key defaultValue:0];
}

- (time_t)timeValueForKey:(NSString *)key defaultValue:(time_t)defaultValue {
	id timeObject = [self objectForKey:key];
    if ([timeObject isKindOfClass:[NSNumber class]]) {
        NSNumber *n = (NSNumber *)timeObject;
        CFNumberType numberType = CFNumberGetType((CFNumberRef)n);
        NSTimeInterval t;
        if (numberType == kCFNumberLongLongType) {
            t = [n longLongValue] / 1000;
        }
        else {
            t = [n longValue];
        }
        return t;
    }
    else if ([timeObject isKindOfClass:[NSString class]]) {
        NSString *stringTime   = timeObject;
        if (stringTime.length == 13) {
            long long llt = [stringTime longLongValue];
            NSTimeInterval t = llt / 1000;
            return t;
        }
        else if (stringTime.length == 10) {
            long long lt = [stringTime longLongValue];
            NSTimeInterval t = lt;
            return t;
        }
        else {
            if (!stringTime || (id)stringTime == [NSNull null]) {
                stringTime = @"";
            }
            struct tm created;
            time_t now;
            time(&now);
            
            if (stringTime) {
                if (strptime([stringTime UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL) {
                    strptime([stringTime UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
                }
                return mktime(&created);
            }
        }
    }
	return defaultValue;
}

- (NSString *)descriptionWithLocale:(id)locale{
    
    NSMutableString *strM = [NSMutableString stringWithString:@"{\n"];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [strM appendFormat:@"\t%@ = %@;\n", key, obj];
    }];
    
    [strM appendString:@"}\n"];
    
    return strM;
}

@end

@implementation NSMutableDictionary (Additions)

- (void)setKey:(NSString *)key andValue:(id)value
{
    if (key == nil || value == nil) {
        return;
//    } else if (value == nil) {
//        [self setValue:@"" forKey:key];
    } else {
        [self setValue:value forKey:key];
    }
}

@end

@implementation NSMutableArray (Additions)

- (void)addAnObject:(id)anObject {
    [self addAnObject:anObject defaultValue:[NSNull null]];
}

- (void)addAnObject:(id)anObject defaultValue:(id)defaultValue {
    if (anObject) {
        [self addObject:anObject];
    } else {
        if (defaultValue) {
            [self addObject:defaultValue];
        } else {
            [self addObject:[NSNull null]];
        }
    }
}

- (NSString *)descriptionWithLocale:(id)locale{
    NSMutableString *strM = [NSMutableString stringWithString:@"(\n"];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [strM appendFormat:@"\t%@,\n", obj];
    }];
    
    [strM appendString:@")"];
    
    return strM;
}

@end

