//
//  DaiSlicer.m
//  DaiSlicer
//
//  Created by DaidoujiChen on 2016/6/6.
//  Copyright © 2016年 VMFive. All rights reserved.
//

#import "DaiSlicer.h"

@implementation NSObject (DaiSlicer)

+ (void)setSlicer:(id)slicer {
    objc_setAssociatedObject(self, @selector(slicer), slicer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (id)slicer {
    return objc_getAssociatedObject(self, _cmd);
}

@end

@implementation DaiSlicer

#pragma mark - Private Class Method

+ (void)forClassMethod:(id)obj method:(SEL)selector byBlock:(id)block className:(NSString *)className {
    
    Class aClass = NSClassFromString(className);
    Class metaClass = object_getClass(aClass);
    
    // 如果 class 名稱不同 比方 Object 與 Dai_Object 才需要 isa swizzling
    // 而且兩個 class 的 size 必須相同才可以做這件事
    //Class aClass = NSClassFromString(className);
    if (![NSStringFromClass([obj class]) isEqualToString:className] && class_getInstanceSize(object_getClass([obj class])) == class_getInstanceSize(metaClass)) {
        object_setClass(obj, metaClass);
    }
    
    IMP blockIMP = imp_implementationWithBlock(block);
    Method targetMethod = class_getInstanceMethod(aClass, selector);
    const char *typeEncoding = method_getTypeEncoding(targetMethod);
    BOOL didAddMethod = class_addMethod(metaClass, selector, blockIMP, typeEncoding);
    
    // 如果插失敗了 表示之前建立過 所以重新設定 selector 對應 blockIMP
    // 並且刪除掉舊的 oldBlockIMP
    if (!didAddMethod) {
        Method method = class_getInstanceMethod(metaClass, selector);;
        IMP oldBlockIMP = method_getImplementation(method);
        method_setImplementation(method, blockIMP);
        imp_removeBlock(oldBlockIMP);
    }
}

+ (void)forInstanceMethod:(id)obj method:(SEL)selector byBlock:(id)block className:(NSString *)className {
    
    Class aClass = NSClassFromString(className);
    
    // 如果 class 名稱不同 比方 Object 與 Dai_Object 才需要 isa swizzling
    // 而且兩個 class 的 size 必須相同才可以做這件事
    //Class aClass = NSClassFromString(className);
    if (![NSStringFromClass([obj class]) isEqualToString:className] && class_getInstanceSize([obj class]) == class_getInstanceSize(aClass)) {
        object_setClass(obj, aClass);
    }
    
    IMP blockIMP = imp_implementationWithBlock(block);
    Method targetMethod = class_getInstanceMethod(object_getClass(obj), selector);
    const char *typeEncoding = method_getTypeEncoding(targetMethod);
    BOOL didAddMethod = class_addMethod(aClass, selector, blockIMP, typeEncoding);
    
    // 如果插失敗了 表示之前建立過 所以重新設定 selector 對應 blockIMP
    // 並且刪除掉舊的 oldBlockIMP
    if (!didAddMethod) {
        Method method = class_getInstanceMethod(aClass, selector);
        IMP oldBlockIMP = method_getImplementation(method);
        method_setImplementation(method, blockIMP);
        imp_removeBlock(oldBlockIMP);
    }
}

#pragma mark - Class Method

+ (void)slice:(id)obj method:(SEL)selector byBlock:(id)block {
    
    // 找出我們要建立的 class 名稱
    Class objClass = object_getClass(obj);
    NSString *className = [NSString stringWithFormat:@"%s", class_getName(objClass)];
    NSString *prefix = [NSString stringWithFormat:@"Dai_%p_", obj];
    if (![className containsString:prefix]) {
        className = [NSString stringWithFormat:@"%@%s", prefix, class_getName(objClass)];
    }
    
    // 檢查這個 class 是否註冊過了
    Class aClass = NSClassFromString(className);
    if (!aClass) {
        aClass = objc_allocateClassPair(object_getClass(obj), className.UTF8String, 0);
        objc_registerClassPair(aClass);
    }
    
    // 首先判斷要置換對象是否為 class
    if (object_isClass(obj)) {
        
        // Class
        [obj setSlicer:NSClassFromString(className)];
        [self forClassMethod:obj method:selector byBlock:block className:className];
    }
    else {
        
        // Instance
        [self forInstanceMethod:obj method:selector byBlock:block className:className];
    };
}

@end
