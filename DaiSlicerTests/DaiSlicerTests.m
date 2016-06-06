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
        NSString *output = passthrough(obj, @selector(repeat:), input);
        NSLog(@"output = %@", output);
        return output;
    });
    NSAssert([[testObject repeat:@"daidouji"] isEqualToString:@"daidoujidaidouji"], @"不一樣 O口O\"");
}

- (void)testMultipleMethods {
    TestObject *testObject = [TestObject new];
    slice(testObject, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        NSLog(@"repeat input = %@", input);
        NSString *output = passthrough(obj, @selector(repeat:), input);
        NSLog(@"repeat output = %@", output);
        return output;
    });
    slice(testObject, @selector(merge:with:), ^NSString *(NSObject *obj, NSString *leftString, NSString *rightString) {
        NSLog(@"merge input = %@, %@", leftString, rightString);
        NSString *output = passthrough(obj, @selector(merge:with:), leftString, rightString);
        NSLog(@"merge output = %@", output);
        return output;
    });
    NSAssert([[testObject repeat:@"daidouji"] isEqualToString:@"daidoujidaidouji"], @"不一樣 O口O\"");
    NSAssert([[testObject merge:@"daidouji" with:@"chen"] isEqualToString:@"daidoujichen"], @"不一樣 O口O\"");
}

- (void)testReplaceMethod {
    TestObject *testObject = [TestObject new];
    
    slice(testObject, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        NSLog(@"11111");
        NSLog(@"input = %@", input);
        NSString *output = passthrough(obj, @selector(repeat:), input);
        NSLog(@"output = %@", output);
        return output;
    });
    NSAssert([[testObject repeat:@"daidouji"] isEqualToString:@"daidoujidaidouji"], @"不一樣 O口O\" 11");
    
    slice(testObject, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        NSLog(@"22222");
        NSLog(@"===== %@", obj);
        return @"replace";
    });
    
    NSAssert([[testObject repeat:@"daidouji"] isEqualToString:@"replace"], @"不一樣 O口O\" 22");
}

- (void)testIndependent {
    TestObject *testObjectA = [TestObject new];
    sliceByIdentifier(testObjectA, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        return @"testObjectA";
    }, @"forA");
    
    TestObject *testObjectB = [TestObject new];
    sliceByIdentifier(testObjectB, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        return @"testObjectB";
    }, @"forB");
    
    NSAssert([[testObjectA repeat:@"daidouji"] isEqualToString:@"testObjectA"], @"不一樣 O口O\"");
    NSAssert([[testObjectB repeat:@"daidouji"] isEqualToString:@"testObjectB"], @"不一樣 O口O\"");
}

- (void)testReplaceIndependent {
    TestObject *testObjectA = [TestObject new];
    sliceByIdentifier(testObjectA, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        return @"testObjectA";
    }, @"forA");
    sliceByIdentifier(testObjectA, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        return @"testObjectAA";
    }, @"forA");
    
    TestObject *testObjectB = [TestObject new];
    sliceByIdentifier(testObjectB, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        return @"testObjectB";
    }, @"forB");
    sliceByIdentifier(testObjectB, @selector(repeat:), ^NSString *(NSObject *obj, NSString *input) {
        return @"testObjectBB";
    }, @"forB");
    
    NSAssert([[testObjectA repeat:@"daidouji"] isEqualToString:@"testObjectAA"], @"不一樣 O口O\"");
    NSAssert([[testObjectB repeat:@"daidouji"] isEqualToString:@"testObjectBB"], @"不一樣 O口O\"");
}

- (void)testClassMethod {
    slice([TestObject class], @selector(testMe:), ^NSArray *(NSObject *obj, NSArray *array) {
        return passthrough(obj, @selector(testMe:), @[ @"world", @"ya" ]);
    });
    NSAssert([[[TestObject slicer] testMe:@[]].firstObject isEqualToString:@"world"], @"不一樣 O口O\"");
}

- (void)testBlock {
    TestObject *testObject = [TestObject new];
    
    slice(testObject, @selector(block:), ^(NSObject *obj, NSString *(^block)(NSString *string)) {
        NSString *(^myBlock)(NSString *string) = ^NSString *(NSString *string) {
            return @"O3O";
        };
        return passthrough(obj, @selector(block:), myBlock);
    });
    
    NSString *result = [testObject block: ^NSString *(NSString *string) {
        return [string stringByAppendingString:@"daidouji"];
    }];
    
    NSAssert([result isEqualToString:@"O3O"], @"不一樣 O口O\"");
}

@end
