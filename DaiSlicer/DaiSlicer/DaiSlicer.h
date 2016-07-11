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

#define slice(target, selector, sliceBlock) \
({ \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wundeclared-selector\"") \
_Pragma("clang diagnostic ignored \"-Wunused-variable\"") \
    SEL originSelector = selector; \
    NSString *swizzledSelectorName = [NSString stringWithFormat:@"Dai_%p_%s", target, sel_getName(selector)]; \
    SEL swizzledSelector = NSSelectorFromString(swizzledSelectorName); \
    [DaiSlicer slice:target method:originSelector byBlock:sliceBlock]; \
_Pragma("clang diagnostic pop") \
})

#define sliceBlock(buildYourBlock, methodReturnType, args...) \
({ \
    ^methodReturnType(NSObject *obj, ## args) { \
        buildYourBlock; \
    }; \
})

#define invoke(types, args...) \
({ \
    IMP imp; \
    if (object_isClass(obj)) { \
        imp = usingClassIMP(obj, swizzledSelector); \
    } \
    else { \
        imp = usingInstanceIMP(obj, originSelector);\
    } \
    ((types)imp)(obj, originSelector, ## args); \
})

#define usingClassIMP(target, selector) \
({ \
    IMP imp = class_getMethodImplementation(object_getClass(obj), selector); \
    imp; \
})

#define usingInstanceIMP(target, selector) \
({ \
    Class aClass = target.superclass; \
    IMP imp = class_getMethodImplementation(aClass, selector); \
    imp; \
})

@interface DaiSlicer : NSObject

+ (void)slice:(id)obj method:(SEL)selector byBlock:(id)block;

@end
