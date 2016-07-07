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

#define slice(target, selector, sliceBlock) \
({ \
    SEL sliceSelector = selector; \
    [DaiSlicer slice:target method:sliceSelector byBlock:sliceBlock]; \
})

#define sliceBlock(buildYourBlock, methodReturnType, args...) \
({ \
    ^methodReturnType(NSObject *obj, ## args) { \
        buildYourBlock; \
    }; \
})

#define invoke(types, args...) \
((types)usingIMP(obj, sliceSelector))(obj, sliceSelector, ## args);

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

@end
