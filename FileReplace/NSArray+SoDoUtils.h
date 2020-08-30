//
//  NSArray+SoDoUtils.h
//  FileReplace
//
//  Created by SoDo on 2020/8/27.
//  Copyright © 2020 shaochong du. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (SoDoUtils)

/// 内嵌map结构 获取所有key
- (NSArray *)allNestDictionaryKeys;

/// 内嵌map结构 获取所有value
- (NSArray *)allNestDictionaryValues;

/// 根据key 获取内嵌map对应的value
/// @param key key
- (NSString *)valueForArrrayKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
