//
//  TestObject.m
//  DaiSlicer
//
//  Created by DaidoujiChen on 2016/6/6.
//  Copyright © 2016年 DaidoujiChen. All rights reserved.
//

#import "TestObject.h"

@implementation TestObject

#pragma mark - Class Method

+ (NSArray *)testMe:(NSArray *)items {
    NSLog(@"items : %@", items);
    return items;
}

#pragma mark - Instance Method

- (NSString *)repeat:(NSString *)string {
    return [NSString stringWithFormat:@"%@%@", string, string];
}

- (NSString *)merge:(NSString *)leftString with:(NSString *)rightString {
    return [NSString stringWithFormat:@"%@%@", leftString, rightString];
}

- (NSString *)block:(NSString *(^)(NSString *string))block {
    NSLog(@"here, %@", block(@"hello"));
    return block(@"hello");
}

- (NSInteger)addOne:(NSInteger)value {
    return value + 1;
}

- (CGRect)squareFrame {
    return CGRectMake(0, 0, 100, 100);
}

@end
