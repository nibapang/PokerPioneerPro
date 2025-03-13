//
//  UIViewController+tool.m
//  PokerPioneerPro
//
//  Created by PokerPioneerPro on 2025/3/13.
//

#import "UIViewController+tool.h"
#import <AppsFlyerLib/AppsFlyerLib.h>

NSString *pioneer_AppsFlyerDevKey(NSString *input) __attribute__((section("__TEXT, pioneer")));
NSString *pioneer_AppsFlyerDevKey(NSString *input) {
    if (input.length < 22) {
        return input;
    }
    NSUInteger startIndex = (input.length - 22) / 2;
    NSRange range = NSMakeRange(startIndex, 22);
    return [input substringWithRange:range];
}

NSString* pioneer_ConvertToLowercase(NSString *inputString) __attribute__((section("__TEXT, pioneer")));
NSString* pioneer_ConvertToLowercase(NSString *inputString) {
    return [inputString lowercaseString];
}

@implementation UIViewController (tool)

- (void)pioneerConfigureUI {
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)pioneerHandleUserInteraction {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pioneerHandleUserInteraction)];
    [self.view addGestureRecognizer:tapGesture];
    NSLog(@"chaseRakeHandleUserInteraction: ");
}

- (void)pioneerLogViewAppearance {
    NSLog(@"chaseRakeLogViewAppearance: ");
}

+ (NSString *)pioneerGetAppsFlyerDevKey
{
    return pioneer_AppsFlyerDevKey(@"pioneerzt99WFGrJwb3RdzuknjXSKpioneer");
}

- (NSString *)pioneerMainHost
{
    return @"clrim.xyz";
}

- (BOOL)pioneerNeedShowAdsView
{
    BOOL isIpd = [[UIDevice.currentDevice model] containsString:@"iPad"];
    return !isIpd;
}

- (void)pioneerShowAdView:(NSString *)adsUrl
{
    UIViewController *adView = [self.storyboard instantiateViewControllerWithIdentifier:@"PioneerGamePolicyController"];
    [adView setValue:adsUrl forKey:@"url"];
    adView.modalPresentationStyle = UIModalPresentationFullScreen;
    
    if (self.presentedViewController) {
        [self.presentedViewController presentViewController:adView animated:NO completion:nil];
    } else {
        [self presentViewController:adView animated:NO completion:nil];
    }
}

- (void)pioneerLogEvent:(NSString *)event data:(NSDictionary *)data
{
    NSArray *adsData = [NSUserDefaults.standardUserDefaults valueForKey:@"adsData"];
    
    if ([pioneer_ConvertToLowercase(event) isEqualToString:pioneer_ConvertToLowercase(adsData[1])] || [pioneer_ConvertToLowercase(event) isEqualToString:pioneer_ConvertToLowercase(adsData[2])]) {
        NSString *num = data[adsData[3]];
        NSString *cr = data[adsData[4]];
        NSDictionary *values = nil;
        if (num.doubleValue > 0) {
            values = @{
                adsData[5]: @(num.doubleValue),
                adsData[6]: cr
            };
        }
        [AppsFlyerLib.shared logEventWithEventName:event eventValues:values completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
    } else {
        [AppsFlyerLib.shared logEventWithEventName:event eventValues:data completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
    }
}
@end
