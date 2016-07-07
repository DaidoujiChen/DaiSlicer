//
//  TestObject.h
//  DaiSlicer
//
//  Created by DaidoujiChen on 2016/6/6.
//  Copyright © 2016年 DaidoujiChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TestObject : NSObject

+ (NSArray *)testMe:(NSArray *)items;

- (NSString *)repeat:(NSString *)string;
- (NSString *)merge:(NSString *)leftString with:(NSString *)rightString;
- (NSString *)block:(NSString *(^)(NSString *string))block;
- (void)asyncBlock:(void(^)(void))asyncBlock;
- (NSInteger)addOne:(NSInteger)value;
- (CGRect)squareFrame;

@end
