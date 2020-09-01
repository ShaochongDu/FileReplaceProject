//
//  AppDelegate.m
//  FileReplace
//
//  Created by SoDo on 2020/8/26.
//  Copyright © 2020 shaochong du. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    
//    [self textReplace];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)textReplace {
//    NSString *str = @"#import @\"AnalysysDemo.h\" 易观分配唯一标识//  AnalysysAgent.m.Analysystest.AnalysysAAAA.9089AnalysysAAAAA.AnalysysbbbbA.1.Analysys000- (NSString *)AnalysysElementPosition:(NSIndexPath *)indexPath; [self.Analysys_visual_viewType isEqualToString:@""],- (void)setAnalysysViewID:(NSString *)tencentShanhuViewID";
        NSString *str = @"#import \"AnalysysDemo.h\" 分配唯一标识";
        NSMutableString *result = [str mutableCopy];
        NSString *needReplaceStr = @"Analysys";
        NSString *replacedStr = @"TencentShanhu";
        [result enumerateSubstringsInRange:NSMakeRange(0, [result length])
                                   options:NSStringEnumerationByWords
                                usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
            NSLog(@"%@", substring);
            if ([substring containsString:@"."]) {
                // 1. 处理self.ansXXX 或 AnalysysAgent.m
                NSArray *words = [substring componentsSeparatedByString:@"."];
                NSUInteger curLocation = 0;//字符位置
                for (int i = 0; i < words.count; i++) {
                    NSString *word = (NSString *)words[i];
                    if (word.length >= needReplaceStr.length) {
                        NSString *string = [word substringToIndex:needReplaceStr.length];
                        if ([string isEqualToString:needReplaceStr]) {
                            [result replaceCharactersInRange:NSMakeRange(substringRange.location+curLocation+i, needReplaceStr.length)
                                                  withString:replacedStr];
                            curLocation += (word.length + (replacedStr.length - needReplaceStr.length));
                        } else {
                            curLocation += word.length;
                        }
                    } else {
                        curLocation += word.length;
                    }
                }
            } else if([substring hasPrefix:@"set"]) {
                //  2. 处理set方法
                NSString *name = [substring substringFromIndex:3];
                if (name.length >= needReplaceStr.length) {
                    NSString *string = [name substringToIndex:needReplaceStr.length];
                    if ([string isEqualToString:needReplaceStr]) {
                        [result replaceCharactersInRange:NSMakeRange(substringRange.location+3, needReplaceStr.length)
                                              withString:replacedStr];
                    }
                }
            } else {
                //  3. 普通匹配以xxx开头
                if (substringRange.length >= needReplaceStr.length) {
                    NSString *string = [substring substringToIndex:needReplaceStr.length];
                    if ([string isEqualToString:needReplaceStr]) {
                        [result replaceCharactersInRange:NSMakeRange(substringRange.location, needReplaceStr.length)
                                              withString:replacedStr];
                    }
                }
            }
        }];
        NSLog(@"*********\n%@", result);
}




@end
