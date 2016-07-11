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

@property (nonatomic, strong) XCTestExpectation *testExpectation;

@end

@implementation DaiSlicerTests

- (void)testSingleMethod {
    TestObject *testObject = [TestObject new];

    slice(testObject, @selector(repeat:), sliceBlock({
        NSString *output = invoke(NSString *(*)(id, SEL, id), input);
        return output;
    }, NSString *, NSString *input));
    
    NSAssert([[testObject repeat:@"daidouji"] isEqualToString:@"daidoujidaidouji"], @"不一樣 O口O\"");
}

- (void)testMultipleMethods {
    TestObject *testObject = [TestObject new];
    
    slice(testObject, @selector(repeat:), sliceBlock({
        NSString *output = invoke(NSString *(*)(id, SEL, id), input);
        return output;
    }, NSString *, NSString *input));
    NSAssert([[testObject repeat:@"daidouji"] isEqualToString:@"daidoujidaidouji"], @"不一樣 O口O\"");
    
    slice(testObject, @selector(merge:with:), sliceBlock({
        NSString *output = invoke(NSString *(*)(id, SEL, id, id), leftString, rightString);
        return output;
    }, NSString *, NSString *leftString, NSString *rightString));
    NSAssert([[testObject merge:@"daidouji" with:@"chen"] isEqualToString:@"daidoujichen"], @"不一樣 O口O\"");
}

- (void)testReplaceMethod {
    TestObject *testObject = [TestObject new];
    
    slice(testObject, @selector(repeat:), sliceBlock({
        NSString *output = invoke(NSString *(*)(id, SEL, id), input);
        return output;
    }, NSString *, NSString *input));
    NSAssert([[testObject repeat:@"daidouji"] isEqualToString:@"daidoujidaidouji"], @"不一樣 O口O\" 11");
    
    slice(testObject, @selector(repeat:), sliceBlock({
        return @"replace";
    }, NSString *, NSString *input));
    NSAssert([[testObject repeat:@"daidouji"] isEqualToString:@"replace"], @"不一樣 O口O\" 22");
}

- (void)testIndependent {
    TestObject *testObjectA = [TestObject new];
    TestObject *testObjectB = [TestObject new];
    
    slice(testObjectA, @selector(repeat:), sliceBlock({
        return @"testObjectA";
    }, NSString *, NSString *input));
    slice(testObjectB, @selector(repeat:), sliceBlock({
        return @"testObjectB";
    }, NSString *, NSString *input));
    
    NSAssert([[testObjectA repeat:@"daidouji"] isEqualToString:@"testObjectA"], @"不一樣 O口O\"");
    NSAssert([[testObjectB repeat:@"daidouji"] isEqualToString:@"testObjectB"], @"不一樣 O口O\"");
}

- (void)testReplaceIndependent {
    TestObject *testObjectA = [TestObject new];
    TestObject *testObjectB = [TestObject new];
    
    slice(testObjectA, @selector(repeat:), sliceBlock({
        return @"testObjectA";
    }, NSString *, NSString *input));
    slice(testObjectA, @selector(repeat:), sliceBlock({
        return @"testObjectAA";
    }, NSString *, NSString *input));
    
    slice(testObjectB, @selector(repeat:), sliceBlock({
        return @"testObjectB";
    }, NSString *, NSString *input));
    slice(testObjectB, @selector(repeat:), sliceBlock({
        return @"testObjectBB";
    }, NSString *, NSString *input));
    
    NSAssert([[testObjectA repeat:@"daidouji"] isEqualToString:@"testObjectAA"], @"不一樣 O口O\"");
    NSAssert([[testObjectB repeat:@"daidouji"] isEqualToString:@"testObjectBB"], @"不一樣 O口O\"");
}

- (void)testClassMethod {
    slice([TestObject class], @selector(testMe:), sliceBlock({
        return invoke(NSArray *(*)(id, SEL, id), @[ @"world", @"ya" ]);
    }, NSArray *, NSArray *array));
    NSAssert([[TestObject testMe:@[]].firstObject isEqualToString:@"world"], @"不一樣 O口O\"");
    
    slice([TestObject class], @selector(testMe:), sliceBlock({
        return invoke(NSArray *(*)(id, SEL, id), @[ @"ya", @"world" ]);
    }, NSArray *, NSArray *array));
    NSAssert([[TestObject testMe:@[]].firstObject isEqualToString:@"ya"], @"不一樣 O口O\"");
}

- (void)testBlock {
    TestObject *testObject = [TestObject new];
    
    slice(testObject, @selector(block:), sliceBlock({
        NSString *(^myBlock)(NSString *string) = ^NSString *(NSString *string) {
            return @"O3O";
        };
        return invoke(NSString *(*)(id, SEL, id), myBlock);
    }, NSString *, NSString *(^block)(NSString *string)));
    NSAssert([[testObject block: ^NSString *(NSString *string) {
        return [string stringByAppendingString:@"daidouji"];
    }] isEqualToString:@"O3O"], @"不一樣 O口O\"");
}

- (void)testNotPointer {
    TestObject *testObject = [TestObject new];
    
    slice(testObject, @selector(addOne:), sliceBlock({
        return invoke(NSInteger (*)(id, SEL, NSInteger), value);
    }, NSInteger, NSInteger value));
    NSAssert([testObject addOne:5] == 6, @"不一樣 O口O\"");
    
    slice(testObject, @selector(addOne:), sliceBlock({
        return 4;
    }, NSInteger, NSInteger value));
    NSAssert([testObject addOne:5] == 4, @"不一樣 O口O\"");
}

- (void)testStructReturn {
    TestObject *testObject = [TestObject new];
    
    slice(testObject, @selector(squareFrame), sliceBlock({
        return invoke(CGRect (*)(id, SEL));
    }, CGRect));
    NSAssert(CGRectEqualToRect([testObject squareFrame], CGRectMake(0, 0, 100, 100)), @"不一樣 O口O\"");
    
    slice(testObject, @selector(squareFrame), sliceBlock({
        return CGRectMake(0, 0, 10, 10);
    }, CGRect));
    NSAssert(CGRectEqualToRect([testObject squareFrame], CGRectMake(0, 0, 10, 10)), @"不一樣 O口O\"");
}

- (void)testAsyncBlock {
    self.testExpectation = [self expectationWithDescription:[NSString stringWithFormat:@"Testing Async Method %s", sel_getName(_cmd)]];
    
    TestObject *testObject = [TestObject new];
    
    slice(testObject, @selector(asyncBlock:), sliceBlock({
        void (^myAsyncBlock)(void) = ^() {
            asyncBlock();
        };
        invoke(void (*)(id, SEL, id), myAsyncBlock);
    }, void, void(^asyncBlock)(void)));
    
    
    __weak DaiSlicerTests *weakSelf = self;
    [testObject asyncBlock: ^{
        NSLog(@"===== Success");
        [weakSelf.testExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10.0f handler: ^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"Expectation Failed %s with error : %@", sel_getName(_cmd), error);
        }
    }];
}

@end
