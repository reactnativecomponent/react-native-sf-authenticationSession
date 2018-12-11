//
//  SFAuthentication.h
//  SFAuthentication
//
//  Created by Dowin on 2018/12/11.
//  Copyright © 2018 Dowin. All rights reserved.
//

#import <Foundation/Foundation.h>'
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <SafariServices/SFAuthenticationSession.h>
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif


@interface SFAuthentication : NSObject<RCTBridgeModule>

@property(nonatomic,strong)SFAuthenticationSession *authentifier;



@end
