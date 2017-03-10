//
//  PKFileTool.m
//  Picooc
//
//  Created by Africa on 17/3/6.
//  Copyright © 2017年 有品·PICOOC. All rights reserved.
//

#import "FHFileTool.h"

@implementation FHFileTool

+ (void)copyFileToTempDirWithFilePath:(NSString *)path completionHandle:(void(^)(NSError *error, NSString *toPath))completion
{
    NSString *tempDir = NSTemporaryDirectory();
    NSString *toPath = [tempDir stringByAppendingPathComponent:path.lastPathComponent];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    [fileManager removeItemAtPath:toPath error:nil];
    
    NSError *error;
    [fileManager copyItemAtPath:path toPath:toPath error:&error];
    
    NSString *completionPath = nil;
    if (!error) {
        completionPath = toPath;
    }
    
    if (completion) {
        completion(error, completionPath);
    }
}

@end
