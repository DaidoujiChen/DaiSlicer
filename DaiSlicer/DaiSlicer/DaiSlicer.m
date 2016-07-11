//
//  DaiSlicer.m
//  DaiSlicer
//
//  Created by DaidoujiChen on 2016/6/6.
//  Copyright © 2016年 VMFive. All rights reserved.
//

#import "DaiSlicer.h"

@implementation DaiSlicer

#pragma mark - Private Class Method

+ (void)forClassMethod:(id)obj method:(SEL)selector byBlock:(id)block {
    Class metaClass = object_getClass(obj);
    
    // 建立一個新的 selector 名稱
    // 準備做 method swizzling
    Method originalMethod = class_getInstanceMethod(metaClass, selector);
    NSString *swizzledSelectorName = [NSString stringWithFormat:@"Dai_%p_%s", obj, sel_getName(selector)];
    SEL swizzledSelector = NSSelectorFromString(swizzledSelectorName);
    IMP blockIMP = imp_implementationWithBlock(block);
    BOOL didAddMethod = class_addMethod(metaClass, swizzledSelector, blockIMP, method_getTypeEncoding(originalMethod));
    Method swizzledMethod = class_getInstanceMethod(metaClass, swizzledSelector);
    
    // 如果新增時失敗, 表示之前已經有這個 method
    // 所以我們要先移除掉舊的
    // 由於先前 exchange 過, 這邊要先 exchange 回來
    // 然後殺掉舊的
    if (!didAddMethod) {
        method_exchangeImplementations(originalMethod, swizzledMethod);
        Method method = class_getInstanceMethod(metaClass, swizzledSelector);
        IMP oldBlockIMP = method_getImplementation(method);
        method_setImplementation(method, blockIMP);
        imp_removeBlock(oldBlockIMP);
    }
    
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

+ (void)forInstanceMethod:(id)obj method:(SEL)selector byBlock:(id)block {
    
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
    
    // 如果 class 名稱不同 比方 Object 與 Dai_Object 才需要 isa swizzling
    // 而且兩個 class 的 size 必須相同才可以做這件事
    // Class aClass = NSClassFromString(className);
    if (![NSStringFromClass([obj class]) isEqualToString:className] && class_getInstanceSize([obj class]) == class_getInstanceSize(aClass)) {
        object_setClass(obj, aClass);
    }
    
    IMP blockIMP = imp_implementationWithBlock(block);
    Method targetMethod = class_getInstanceMethod(objClass, selector);
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
    
    // 首先判斷要置換對象是否為 class
    if (object_isClass(obj)) {
        
        // Class
        [self forClassMethod:obj method:selector byBlock:block];
    }
    else {
        
        // Instance
        [self forInstanceMethod:obj method:selector byBlock:block];
    };
}

@end
