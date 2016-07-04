//
//  DaiSlicerTests.m
//  DaiSlicerTests
//
//  Created by DaidoujiChen on 2016/6/6.
//  Copyright © 2016年 DaidoujiChen. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DaiSlicer.h"
#import "TestObject.h"

@interface DaiSlicerTests : XCTestCase

@end

@implementation DaiSlicerTests

- (void)testSingleMethod {
    TestObject *testObject = [TestObject new];
    slice(testObject, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        NSLog(@"input = %@, %@", input, obj);
        NSString *output = pass(obj, @selector(repeat:), input);
        NSLog(@"output = %@", output);
        return output;
    });
    NSAssert([[testObject repeat:@"daidouji"] isEqualToString:@"daidoujidaidouji"], @"不一樣 O口O\"");
}

- (void)testMultipleMethods {
    TestObject *testObject = [TestObject new];
    slice(testObject, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        NSLog(@"repeat input = %@", input);
        NSString *output = pass(obj, @selector(repeat:), input);
        NSLog(@"repeat output = %@", output);
        return output;
    });
    NSAssert([[testObject repeat:@"daidouji"] isEqualToString:@"daidoujidaidouji"], @"不一樣 O口O\"");
    
    slice(testObject, @selector(merge:with:), ^NSString *(NSObject *obj, NSString *leftString, NSString *rightString) {
        NSLog(@"merge input = %@, %@", leftString, rightString);
        NSString *output = pass(obj, @selector(merge:with:), leftString, rightString);
        NSLog(@"merge output = %@", output);
        return output;
    });
    NSAssert([[testObject merge:@"daidouji" with:@"chen"] isEqualToString:@"daidoujichen"], @"不一樣 O口O\"");
}

- (void)testReplaceMethod {
    TestObject *testObject = [TestObject new];
    
    slice(testObject, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        NSString *output = pass(obj, @selector(repeat:), input);
        return output;
    });
    NSAssert([[testObject repeat:@"daidouji"] isEqualToString:@"daidoujidaidouji"], @"不一樣 O口O\" 11");
    
    slice(testObject, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        return @"replace";
    });
    NSAssert([[testObject repeat:@"daidouji"] isEqualToString:@"replace"], @"不一樣 O口O\" 22");
}

- (void)testIndependent {
    TestObject *testObjectA = [TestObject new];
    TestObject *testObjectB = [TestObject new];
    
    slice(testObjectA, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        return @"testObjectA";
    });
    slice(testObjectB, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        return @"testObjectB";
    });
    
    NSAssert([[testObjectA repeat:@"daidouji"] isEqualToString:@"testObjectA"], @"不一樣 O口O\"");
    NSAssert([[testObjectB repeat:@"daidouji"] isEqualToString:@"testObjectB"], @"不一樣 O口O\"");
}

- (void)testReplaceIndependent {
    TestObject *testObjectA = [TestObject new];
    TestObject *testObjectB = [TestObject new];
    
    slice(testObjectA, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        return @"testObjectA";
    });
    slice(testObjectA, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        return @"testObjectAA";
    });
    
    slice(testObjectB, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        return @"testObjectB";
    });
    slice(testObjectB, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        return @"testObjectBB";
    });
    
    NSAssert([[testObjectA repeat:@"daidouji"] isEqualToString:@"testObjectAA"], @"不一樣 O口O\"");
    NSAssert([[testObjectB repeat:@"daidouji"] isEqualToString:@"testObjectBB"], @"不一樣 O口O\"");
}

- (void)testClassMethod {
    slice([TestObject class], @selector(testMe:), ^NSArray *(NSObject *obj, NSArray *array) {
        return pass(obj, @selector(testMe:), @[ @"world", @"ya" ]);
    });
    NSAssert([[[TestObject slicer] testMe:@[]].firstObject isEqualToString:@"world"], @"不一樣 O口O\"");
}

- (void)testBlock {
    TestObject *testObject = [TestObject new];
    
    slice(testObject, @selector(block:), ^(NSObject *obj, NSString *(^block)(NSString *string)) {
        NSString *(^myBlock)(NSString *string) = ^NSString *(NSString *string) {
            return @"O3O";
        };
        return pass(obj, @selector(block:), myBlock);
    });
    
    NSString *result = [testObject block: ^NSString *(NSString *string) {
        return [string stringByAppendingString:@"daidouji"];
    }];
    
    NSAssert([result isEqualToString:@"O3O"], @"不一樣 O口O\"");
}

- (void)testNotPointer {
    TestObject *testObject = [TestObject new];
    
    slice(testObject, @selector(addOne:), ^NSInteger(NSObject *obj, NSInteger value) {
        IMP imp = usingIMP(obj, @selector(addOne:));
        return ((NSInteger (*)(id, SEL, NSInteger))imp)(obj, @selector(addOne:), value);
    });
    NSAssert([testObject addOne:5] == 6, @"不一樣 O口O\"");
    
    slice(testObject, @selector(addOne:), ^NSInteger(NSObject *obj, NSInteger value) {
        return 4;
    });
    NSAssert([testObject addOne:5] == 4, @"不一樣 O口O\"");
}

@end
