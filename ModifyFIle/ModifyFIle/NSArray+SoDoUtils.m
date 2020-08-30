//
//  NSArray+SoDoUtils.m
//  ModifyFIle
//
//  Created by SoDo on 2020/8/27.
//  Copyright © 2020 shaochong du. All rights reserved.
//

#import "NSArray+SoDoUtils.h"

@implementation NSArray (SoDoUtils)

- (NSArray *)allNestDictionaryKeys {
    NSMutableArray *allKeys = [NSMutableArray array];
    for (NSDictionary *dic in self) {
        [allKeys addObjectsFromArray:dic.allKeys];
    }
    return [allKeys copy];
}

- (NSArray *)allNestDictionaryValues {
    NSMutableArray *allValues = [NSMutableArray array];
    for (NSDictionary *dic in self) {
        [allValues addObjectsFromArray:dic.allValues];
    }
    return [allValues copy];
}

- (NSString *)valueForArrrayKey:(NSString *)key {
    for (NSDictionary *dic in self) {
        if ([dic.allKeys containsObject:key]) {
            return dic[key];
        }
    }
    return nil;
}

@end
