//
//  SoDoViewController.m
//  ModifyFIle
//
//  Created by SoDo on 2020/8/26.
//  Copyright © 2020 shaochong du. All rights reserved.
//

#import "SoDoViewController.h"


@interface SoDoViewController ()

@property (weak) IBOutlet NSTextField *filePathTextField;

@property (nonatomic, strong) NSArray *fileTypes;   //  处理的文件类型

@property (nonatomic, strong) NSDictionary *replacedMap;//替换文件对应关系

@end

@implementation SoDoViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.fileTypes = @[@".h", @".m"];
    
    //  替换时一定注意先后顺序，最长的放在最前面，防止重复替换
    //  如：将ans和analysys替换为tencentShanhu
    //  需先替换analysys为tencentShanhu，再替换ans
    self.replacedMap = @{
        @"ans": @"tencentShanhu",
        @"Ans": @"TencentShanhu",
        @"ANS": @"TencentShanhu",
        @"analysys": @"tencentShanhu",
        @"Analysys": @"TencentShanhu"
    };
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

/// 文件选择
/// @param sender btn
- (IBAction)openFileAction:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseFiles = YES ;
    panel.canChooseDirectories = YES;
    panel.allowsMultipleSelection = YES;
    [panel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSArray *fileURLs = [panel URLs];
            for(NSURL *url in fileURLs) {
                NSLog(@"选择文件路径:---%@", url);
                self.filePathTextField.stringValue = url.path;
                [self readFileWithPath:url.path];
            }
        }
    }];
}


/// 读取文件
/// @param filePath 路径
- (void)readFileWithPath:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
//    NSArray *fileArray = [fileManager subpathsAtPath:filePath];
//    NSLog(@"当前目录（%@）下文件--%@", filePath, fileArray);
    
    NSString *fileFolder = [self fileFolderWithPath:filePath];
    NSString *fileName = [self fileNameWithPath:filePath];
    
    BOOL isDirectory = NO; // 是否文件夹
    BOOL isPathExists = [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
    if (isPathExists) {
        if (isDirectory) {
            NSLog(@"---------遍历文件夹(%@)下所有文件------", fileName);
            //  修改文件夹名称
            [self renameFile:fileName fileFolder:fileFolder isDir:YES];
            
            NSError *error;
            NSArray *fileArray = [fileManager contentsOfDirectoryAtPath:filePath error:&error];
            NSString *subPath = nil;
            if (error == nil) {
                for (NSString *str in fileArray) {
                    subPath  = [filePath stringByAppendingPathComponent:str];
                    BOOL subPathExists = [fileManager fileExistsAtPath:subPath isDirectory:nil];
                    [self readFileWithPath:subPath];
                }
            }
        } else {
            [self renameFile:fileName fileFolder:fileFolder isDir:NO];
            //  处理文件内容
            NSLog(@"开始处理文件%@......", fileName);
            
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
/// @param fileName 当前文件
/// @param fileFolder 上层文件夹
/// @param isDir 是否文件夹
- (void)renameFile:(NSString *)fileName fileFolder:(NSString *)fileFolder isDir:(BOOL)isDir {
    if (isDir) {
        /** --文件夹不能重命名-- */
        return;
    } else {
        BOOL hasSuffix = NO;
        //  文件后缀判断
        for (NSString *suffix in self.fileTypes) {
            if ([fileName containsString:suffix]) {
                hasSuffix = YES;
                break;
            }
        }
        if (!hasSuffix) {
            return;
        }
    }
    
    // 是否包含替换字符
    BOOL showRename = NO;
    NSString *prefixString;
    for (NSString *prefix in self.replacedMap.allKeys) {
        if ([fileName containsString:prefix]) {
            prefixString = prefix;
            showRename = YES;
            break;
        }
    }
    
    if (!showRename) {
        return;
    }

    //  替换文件名称
    NSString *newFileName = [fileName stringByReplacingOccurrencesOfString:prefixString withString:self.replacedMap[prefixString]];
    
    //  重命名
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *oldfilePath = [fileFolder stringByAppendingPathComponent:fileName];
    NSString *moveToPath = [fileFolder stringByAppendingPathComponent:newFileName];
    NSError *error;
    BOOL isSuccess = [fileManager moveItemAtPath:oldfilePath toPath:moveToPath error:&error];
    if (error) {
        NSLog(@"rename fail! %@", error);
    }
}

/// 读取文件及内容并修改
/// @param filePath 文件路径`
- (void)readFileContentWithFilePath:(NSString *)filePath {
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSString *replcedContent = [content stringByReplacingOccurrencesOfString:@"analysys" withString:@"TencentShanhu"];
    
    NSError *error;
    //保存文件内容
    BOOL result = [replcedContent writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"写入失败! %@", error);
    }
}



@end
