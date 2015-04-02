//
//  ddProgressBtn.m
//  FawaedTV
//
//  Created by Homam on 2015-03-14.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "ddProgressBtn.h"
#import "episodeObject.h"

@implementation ddProgressBtn
-(void)handelEpDownObj:(episodeDownloadObject *)epDownObj{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (epDownObj.episodeDownloadCurrentStatus) {
            case downloadStatusInitiating:{
                [self addLoadingInidicator];
                break;
            }
            case downloadStatusDownloading:{
                [self setProgress:epDownObj.episodeDownloadProgress.fractionCompleted];
                break;
            }
            case downloadStatusFinished:{
                if (!epDownObj.episodeDownloadError) {
                    [self animateToType:buttonRightTriangleType];
                }else{
                    [self animateToType:buttonDownArrowType];
                }
                break;
            }
            case downloadStatusCanceled:{
                [self animateToType:buttonDownArrowType];
                break;
            }
            case downloadStatusBasic:{
                [self animateToType:buttonDownArrowType];
                break;
            }
            default:{
                [self animateToType:buttonDownArrowType];
                break;
            }
        }
        
    });
}
-(void)setCheckmark{
    [self animateToType:buttonOkType];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    UIEdgeInsets hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    if(UIEdgeInsetsEqualToEdgeInsets(hitTestEdgeInsets, UIEdgeInsetsZero) || !self.enabled || self.hidden) {
        return [super pointInside:point withEvent:event];
    }
    
    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets);
    
    return CGRectContainsPoint(hitFrame, point);
}

@end
