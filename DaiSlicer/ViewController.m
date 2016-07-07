//
//  ViewController.m
//  DaiSlicer
//
//  Created by DaidoujiChen on 2016/6/6.
//  Copyright © 2016年 DaidoujiChen. All rights reserved.
//

#import "ViewController.h"
#import "DaiSlicer.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    slice(self.webView, @selector(webView:identifierForInitialRequest:fromDataSource:), sliceBlock({
        NSLog(@">>> %@", arg2.URL);
        return invoke(id (*)(id, SEL, id, id, id), arg1, arg2, arg3);
    }, id, id arg1, NSMutableURLRequest *arg2, id arg3));
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]]];
}

@end
