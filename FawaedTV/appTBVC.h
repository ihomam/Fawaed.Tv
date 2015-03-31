//
//  appTBVC.h
//  FawaedTV
//
//  Created by Homam on 2015-02-10.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, playerType) {
    playerTypeAudioOnline,
    playerTypeAudioLocal,
    playerTypeVideoOnline,
    playerTypeVideoLocal
};
@interface appTBVC : UITabBarController
-(void)buildFilePlayerForObject:(id)mediaObj forType:(playerType)type;
@end
