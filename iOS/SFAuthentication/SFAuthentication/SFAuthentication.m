//
//  SFAuthentication.m
//  SFAuthentication
//
//  Created by Dowin on 2018/12/11.
//  Copyright © 2018 Dowin. All rights reserved.
//

#import "SFAuthentication.h"

@implementation SFAuthentication
- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_REMAP_METHOD(getSafariData, address:(NSString *)address callbackURL:(NSString *)callbackURL
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    if (@available(iOS 11.0, *)) {

        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self zm_swizzleInstanceMethodWithSrcClass:[UIViewController class]
                                                srcSel:@selector(presentViewController:animated:completion:)
                                           swizzledSel:@selector(liya_presentViewController:animated:completion:)];

        });
        
        NSURL * siteURL = [NSURL URLWithString:address];
        self.authentifier = [[SFAuthenticationSession alloc]initWithURL:siteURL callbackURLScheme:callbackURL completionHandler:^(NSURL * _Nullable callbackURL, NSError * _Nullable error) {
            NSLog(@"%@",[error localizedDescription]);
            NSString  *urlStr = [NSString stringWithFormat:@"%@",callbackURL];
            if (error != nil) {
                reject(@"CompletionHandler non nil error", [error localizedDescription], error);
            } else {
                resolve(callbackURL.absoluteString);
            }
        }];

        BOOL success = [self.authentifier start];
        if (success == NO) {
            NSError *error = [NSError errorWithDomain:@"Open safari" code:404 userInfo:nil];
            reject(@"Open safari", @"could not start opening safari", error);
        }
    } else {
        NSError *error = [NSError errorWithDomain:@"OS requirement" code:404 userInfo:nil];
        reject(@"OS requirement", @"iOS 11+ required", error);
        return;
    }
}

- (void)liya_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    Class SFAuthenticationViewController = NSClassFromString(@"SFAuthenticationViewController");
    if (SFAuthenticationViewController && [viewControllerToPresent isKindOfClass:SFAuthenticationViewController]) {
        viewControllerToPresent.view.alpha = 0.0;
        viewControllerToPresent.view.frame = CGRectZero;
        viewControllerToPresent.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
//    [self liya_presentViewController:viewControllerToPresent animated:flag completion:completion];
}
- (void)zm_swizzleInstanceMethodWithSrcClass:(Class)srcClass
                                      srcSel:(SEL)srcSel
                                 swizzledSel:(SEL)swizzledSel{

    Method srcMethod = class_getInstanceMethod(srcClass, srcSel);
    Method swizzledMethod = class_getInstanceMethod([self class], swizzledSel);
    if (!srcClass || !srcMethod || !swizzledMethod) return;

    //加一层保护措施，如果添加成功，则表示该方法不存在于本类，而是存在于父类中，不能交换父类的方法,否则父类的对象调用该方法会crash；添加失败则表示本类存在该方法
    BOOL addMethod = class_addMethod(srcClass, srcSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (addMethod)
    {
        //再将原有的实现替换到swizzledMethod方法上，从而实现方法的交换，并且未影响到父类方法的实现
        class_replaceMethod(srcClass, swizzledSel, method_getImplementation(srcMethod), method_getTypeEncoding(srcMethod));
    }else
    {
        method_exchangeImplementations(srcMethod, swizzledMethod);
    }
}
@end
