//
//  SoDoViewController.m
//  ModifyFIle
//
//  Created by SoDo on 2020/8/26.
//  Copyright © 2020 shaochong du. All rights reserved.
//

#import "SoDoViewController.h"

#import "NSArray+SoDoUtils.h"

typedef NS_ENUM(NSInteger, ReplaceType) {
    ReplaceTypeAll, // 全文替换
    ReplaceTypePrefix // 匹配单次开头
};

@interface SoDoViewController ()

@property (weak) IBOutlet NSTextField *filePathTextField;

@property (weak) IBOutlet NSTextField *toBeReplacedStrTF;
@property (weak) IBOutlet NSTextField *replacedStrTF;
@property (weak) IBOutlet NSButton *replaceBtn;//执行替换

@property (unsafe_unretained) IBOutlet NSTextView *logTextView;

@property (nonatomic, assign) ReplaceType replaceType;

@property (nonatomic, strong) NSMutableSet *fileTypes;   //  处理的文件类型
@property (nonatomic, strong) NSMutableArray *replacedDataArray;//替换文件对应关系
@property (nonatomic, strong) NSArray *selectedFilsUrls;// 用户选中的路径

@property (nonatomic, assign) NSInteger fileFolderCount;//处理文件夹个数
@property (nonatomic, assign) NSInteger fileCount;//处理总文件个数

@end

@implementation SoDoViewController

-(void)viewWillAppear {
    [super viewWillAppear];
    self.view.window.restorable = NO;
    [self.view.window setContentSize:NSMakeSize(800, 600)];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fileFolderCount = 0;
    self.fileCount = 0;
    self.replaceType = ReplaceTypeAll;
        
    // 默认替换文件类型全部选择
    self.fileTypes = [NSMutableSet setWithObjects:@".h", @".m", @".json", @".xib", @".plist", @".pch", @".storyboard", @".txt", nil];
    
    // 默认替换对应关系
    self.toBeReplacedStrTF.stringValue = @"\"Analysys,\"ANS,Analysys,analysys,eguan,_ans,_ANS,ANS,Ans,ans";
    self.replacedStrTF.stringValue = @"\"TencentShanhu,\"TencentShanhu,TencentShanhu,tencentShanhu,tencentShanhu,_tencentShanhu,_TencentShanhu,TencentShanhu,TencentShanhu,tencentShanhu";
    [self setReplacedRelated];
    
    [self createCheckBox];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

#pragma mark - 视图

/// 创建CheckBox
- (void)createCheckBox {
    NSArray *fileTypes = @[@"所有类型",@".h", @".m", @".json", @".xib", @".plist", @".pch", @".storyboard", @".txt"];
    
    NSButton *lastBtn;
    CGFloat checkBoxWidth = 30;
    for (int i = 0; i < fileTypes.count; i++) {
        NSButton *btn = [NSButton buttonWithTitle:fileTypes[i] target:self action:@selector(checkBoxAction:)];
        [btn setButtonType:NSButtonTypeSwitch];
        btn.tag = 1000+i;
        btn.state = NSControlStateValueOn;
        btn.font = [NSFont systemFontOfSize:18];
        CGSize size = [btn.title sizeWithAttributes:@{NSFontAttributeName:btn.font}];
        if (lastBtn) {
            btn.frame = CGRectMake(lastBtn.frame.origin.x + lastBtn.frame.size.width + 10, 490, size.width + checkBoxWidth, size.height);
        } else {
            btn.frame = CGRectMake(20, 490, size.width + checkBoxWidth, size.height);
        }
        lastBtn = btn;
        [self.view addSubview:btn];
    }
}

- (void)showAlertString:(NSString *)msg {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Tips";
    alert.alertStyle = NSAlertStyleWarning;
    [alert addButtonWithTitle:@"OK"];
    [alert setInformativeText:msg];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        
    }];
}


#pragma mark - 事件交互

/// 文件选择
/// @param sender btn
- (IBAction)openFileAction:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = YES ;
    panel.canChooseDirectories = YES;
    panel.allowsMultipleSelection = YES;
    [panel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            self.logTextView.string = @"";
            self.selectedFilsUrls = [panel URLs];
            for(NSURL *url in self.selectedFilsUrls) {
                self.filePathTextField.stringValue = url.path;
            }
        }
    }];
}

/// CheckBox勾选
/// @param sender btn
- (void)checkBoxAction:(NSButton *)sender {
    if (sender.tag == 1000) {
        // 所有类型
        NSArray *tags = @[@1001,@1002,@1003,@1004,@1005,@1006,@1007,@1008];
        for (NSView *view in self.view.subviews) {
            if ([tags containsObject:[NSNumber numberWithInteger:view.tag]]) {
                NSButton *btn = (NSButton *)view;
                if (sender.state == NSControlStateValueOn) {
                    btn.state = NSControlStateValueOn;
                    [self.fileTypes addObject:btn.title];
                } else {
                    btn.state = NSControlStateValueOff;
                    [self.fileTypes removeObject:btn.title];
                }
            }
        }
    } else {
        if (sender.state == NSControlStateValueOn) {
            [self.fileTypes addObject:sender.title];
        } else {
            [self.fileTypes removeObject:sender.title];
            NSButton *btn = (NSButton *)[self.view viewWithTag:1000];
            btn.state = NSControlStateValueOff;
        }
    }
    
    NSLog(@"替换文本类型：%@", self.fileTypes);
}

- (IBAction)allReplaceAction:(NSButton *)sender {
    self.replaceType = ReplaceTypeAll;
}

- (IBAction)prefixReplaceAction:(NSButton *)sender {
    self.replaceType = ReplaceTypePrefix;
}

/// 执行替换操作
/// @param sender btn
- (IBAction)replacedAction:(NSButton *)sender {
    if (self.selectedFilsUrls.count == 0) {
        [self showAlertString:@"请选择文件路径！！！"];
        return;
    }
//    if (self.fileTypes.count == 0) {
//        [self showAlertString:@"请勾选文件类型！！！"];
//        return;
//    }
    
    NSArray *toBeReplacedArray = [self.toBeReplacedStrTF.stringValue componentsSeparatedByString:@","];
    NSArray *replacedArray = [self.replacedStrTF.stringValue componentsSeparatedByString:@","];
    if (self.toBeReplacedStrTF.stringValue.length == 0 ||
        self.replacedStrTF.stringValue.length == 0 ||
        toBeReplacedArray.count == 0 ||
        replacedArray.count == 0 ||
        toBeReplacedArray.count != replacedArray.count) {
        [self showAlertString:@"替换前字符串必须与替换后字符串个数相同，且不能为空。若为多个则以英文逗号分隔！"];
        return;
    }
    
    //  处理替换文本对应关系
    [self setReplacedRelated];
    
    self.fileFolderCount = 0;
    self.fileCount = 0;
    self.logTextView.string = @"";
    
    self.replaceBtn.enabled = NO;
    self.replaceBtn.title = @"正在执行";
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self appendTextViewString:@"*************************************************************"];
        [self appendTextViewString:@"******************* 开始替换已选择文件 *****************"];
        [self appendTextViewString:@"*************************************************************"];
        for(NSURL *url in self.selectedFilsUrls) {
            [self readFileWithPath:url.path];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.replaceBtn.enabled = YES;
            self.replaceBtn.title = @"执行替换";
        });
        
        [self appendTextViewString:@"\n\n*************************************************************"];
        [self appendTextViewString:@"****************** 所有文件均已处理完成 ****************"];
        NSString *recordString = [NSString stringWithFormat:@"******** 文件夹个数：%ld 文件个数：%ld ***************", self.fileFolderCount, self.fileCount];
        [self appendTextViewString:recordString];
        [self appendTextViewString:@"*************************************************************\n\n"];
    });
    
}

#pragma mark - 操作


/// 读取文件
/// @param filePath 路径
- (void)readFileWithPath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //    NSArray *fileArray = [fileManager subpathsAtPath:filePath];
    //    NSLog(@"当前目录（%@）下文件--%@", filePath, fileArray);
    
    BOOL isDirectory = NO; // 是否文件夹
    BOOL isPathExists = [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
    if (isPathExists) {
        if (isDirectory) {
            self.fileFolderCount++;
            
            NSString *fileName = [self fileNameWithPath:filePath];
            NSString *logString = [NSString stringWithFormat:@"-- 遍历文件夹(%@)下所有文件-- ", fileName];
            [self appendTextViewString:logString];
            
            //  修改文件夹名称
            filePath = [self renameFile:filePath isDir:YES];
            
            NSError *error;
            NSArray *fileArray = [fileManager contentsOfDirectoryAtPath:filePath error:&error];
            NSString *subPath = nil;
            if (error == nil) {
                for (NSString *str in fileArray) {
                    subPath  = [filePath stringByAppendingPathComponent:str];
                    //                    BOOL subPathExists = [fileManager fileExistsAtPath:subPath isDirectory:nil];
                    [self readFileWithPath:subPath];
                }
            }
        } else {
            
            filePath = [self renameFile:filePath isDir:NO];
            
            [self readFileContentWithFilePath:filePath];
        }
    } else {
        NSLog(@"路径(%@)不存在!", filePath);
    }
}

/// 获取文件名
/// @param filePath path
- (NSString *)fileNameWithPath:(NSString *)filePath {
    NSRange range = [filePath rangeOfString:@"/" options:NSBackwardsSearch];
    return [filePath substringFromIndex:range.location+1];
}

/// 获取上层文件夹名
/// @param filePath path
- (NSString *)fileFolderWithPath:(NSString *)filePath {
    NSRange range = [filePath rangeOfString:@"/" options:NSBackwardsSearch];
    return [filePath substringToIndex:range.location];
}

/// 修改当前文件夹或文件名
/// @param filePath 当前文件
/// @param isDir 是否文件夹
- (NSString *)renameFile:(NSString *)filePath isDir:(BOOL)isDir {
    NSString *fileFolder = [self fileFolderWithPath:filePath];
    NSString *fileName = [self fileNameWithPath:filePath];
    NSString *originalfilePath = [fileFolder stringByAppendingPathComponent:fileName];
    if (isDir) {
        /** --文件夹不能重命名-- */
        return originalfilePath;
    } else {
        if (![self fileShowModify:filePath]) {
            return originalfilePath;
        }
    }
    
    //  替换文件名称
    NSString *newFileName = [self replaceContent:fileName];
    
    //  文件重命名
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *newPath = [fileFolder stringByAppendingPathComponent:newFileName];
    NSError *error;
    BOOL isSuccess = [fileManager moveItemAtPath:originalfilePath toPath:newPath error:&error];
    
    NSString *logString;
    if (error || !isSuccess) {
        logString = [NSString stringWithFormat:@"---- rename fail! %@ ---- ", error];
    } else {
        logString = [NSString stringWithFormat:@"---- 文件重命名完成 %@ -> %@ ---- ", fileName, newFileName];
    }
    [self appendTextViewString:logString];
    
    return newPath;
}

/// 读取文件及内容并修改
/// @param filePath 文件路径`
- (void)readFileContentWithFilePath:(NSString *)filePath {
    if (![self fileShowModify:filePath]) {
        return;
    }
    //  处理文件内容
    //    NSString *fileName = [self fileNameWithPath:filePath];
    
    //    NSString *logString = [NSString stringWithFormat:@"------ 开始处理文件%@...... ", fileName];
    //    [self appendTextViewString:logString];
    
    self.fileCount++;
    
    NSString *originalContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSString *content = [self replaceContent:originalContent];
    
    NSError *error;
    //保存文件内容
    BOOL result = [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSString *logString;
    if (error || !result) {
        logString = [NSString stringWithFormat:@"-------- 写入失败! %@ --------", error];
    } else {
        logString = [NSString stringWithFormat:@"-------- 文件内容替换完成 - %@ --------", [self fileNameWithPath:filePath]];
    }
    [self appendTextViewString:logString];
}

/// 判断文件类型是否需要修改
/// @param filePath path
- (BOOL)fileShowModify:(NSString *)filePath {
    if (self.fileTypes.count == 0) {
        return YES;
    }
    
    NSString *fileName = [self fileNameWithPath:filePath];
    for (NSString *suffix in self.fileTypes) {
        if ([fileName containsString:suffix]) {
            return YES;
        }
    }
    return NO;
}

/// 根据字符串对应关系替换文本内容
/// @param content 文本
- (NSString *)replaceContent:(NSString *)content {
    
    NSMutableString *result = [content mutableCopy];
    
    for (NSDictionary *dic in self.replacedDataArray) {
        NSString *needReplaceStr = dic.allKeys.firstObject;//需要替换的字符
        NSString *replacedStr = dic.allValues.firstObject;//替换后字符
        
        if (self.replaceType == ReplaceTypeAll) {
            // 1. 全部替换，不区分在开始、中间或结束位置
            content = [content stringByReplacingOccurrencesOfString:needReplaceStr withString:replacedStr];
            result = [content mutableCopy];
        } else {
            // 2. 替换以指定字符串开头的单词
            //        NSString *str = @"Hello world, Hello ni hao!";
            //        NSString *replacedString = @"He";
            //        NSString *toString = @"**";
            [result enumerateSubstringsInRange:NSMakeRange(0, [result length])
                                       options:NSStringEnumerationByWords
                                    usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                //            NSLog(@"%@", substring);
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
        }
    }
    return [result copy];
}

/// 整理替换对象对应关系
- (void)setReplacedRelated {
    if (self.replacedDataArray == nil) {
        self.replacedDataArray = [NSMutableArray array];
    } else {
        [self.replacedDataArray removeAllObjects];
    }
    NSArray *toBeReplacedArray = [self.toBeReplacedStrTF.stringValue componentsSeparatedByString:@","];
    NSArray *replacedArray = [self.replacedStrTF.stringValue componentsSeparatedByString:@","];
    for (int i = 0; i < toBeReplacedArray.count; i++) {
        [self.replacedDataArray addObject:@{toBeReplacedArray[i]: replacedArray[i]}];
    }
}

/// 日志追加
/// @param text 文本
- (void)appendTextViewString:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logTextView.string = [NSString stringWithFormat:@"%@", self.logTextView.string.length > 0 ? [NSString stringWithFormat:@"%@\n%@", self.logTextView.string, text] : text];
        
        [self.logTextView scrollRangeToVisible:NSMakeRange(self.logTextView.string.length, 1)];
    });
}


@end
