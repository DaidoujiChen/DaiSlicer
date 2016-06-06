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

#define slice(target, selector, block) sliceByIdentifier(target, selector, block, nil);

#define sliceByIdentifier(target, selector, block, identifier) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wundeclared-selector\"") \
[DaiSlicer slice:target method:selector byBlock:block withIdentifier:identifier]; \
_Pragma("clang diagnostic pop")

#define passthrough(target, selector, args...) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wundeclared-selector\"") \
({ \
Class aClass = target.superclass; \
IMP imp = class_getMethodImplementation(aClass, selector); \
imp(obj, selector, ## args); \
}) \
_Pragma("clang diagnostic pop")

@interface NSObject (DaiSlicer)

+ (id)slicer;

@end

@interface DaiSlicer : NSObject

+ (void)slice:(id)obj method:(SEL)selector byBlock:(id)block;
+ (void)slice:(id)obj method:(SEL)selector byBlock:(id)block withIdentifier:(NSString *)identifier;

@end
