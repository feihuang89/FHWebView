//
//  PKFileTool.h
//  Picooc
//
//  Created by Africa on 17/3/6.
//  Copyright © 2017年 有品·PICOOC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FHFileTool : NSObject

/**
 拷贝文件到temp文件夹

 @param path 需要拷贝的路径
 @param completion 返回拷贝后的文件路径
 */
+ (void)copyFileToTempDirWithFilePath:(NSString *)path completionHandle:(void(^)(NSError *error, NSString *toPath))completion;

@end
