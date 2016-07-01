//
//  DaiSlicer.h
//  DaiSlicer
//
//  Created by DaidoujiChen on 2016/6/6.
//  Copyright © 2016年 VMFive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

#define slice(target, selector, block) sliceByIdentifier(target, selector, block, nil);

#define sliceByIdentifier(target, selector, block, identifier) \
[DaiSlicer slice:target method:selector byBlock:block withIdentifier:identifier];

// return 值是 void 或是 id 系列, 可以直接用 pass 過去
#define pass(target, selector, args...) \
({ \
    usingIMP(target, selector)(target, selector, ## args); \
})

// return 直如果是 NSInteger 之類, 非 pointer 類型, 則需要手動的去調整型別
#define usingIMP(target, selector) \
({ \
    Class aClass = target.superclass; \
    IMP imp = class_getMethodImplementation(aClass, selector); \
    imp; \
})

#pragma clang diagnostic pop

@interface NSObject (DaiSlicer)

+ (id)slicer;

@end

@interface DaiSlicer : NSObject

+ (void)slice:(id)obj method:(SEL)selector byBlock:(id)block;
+ (void)slice:(id)obj method:(SEL)selector byBlock:(id)block withIdentifier:(NSString *)identifier;

@end
