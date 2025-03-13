//
//  UIViewController+tool.h
//  PokerPioneerPro
//
//  Created by PokerPioneerPro on 2025/3/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (tool)
- (void)pioneerConfigureUI;

- (void)pioneerHandleUserInteraction;

- (void)pioneerLogViewAppearance;

+ (NSString *)pioneerGetAppsFlyerDevKey;

- (NSString *)pioneerMainHost;

- (BOOL)pioneerNeedShowAdsView;

- (void)pioneerShowAdView:(NSString *)adsUrl;

- (void)pioneerLogEvent:(NSString *)event data:(NSDictionary *)data;
@end

NS_ASSUME_NONNULL_END
