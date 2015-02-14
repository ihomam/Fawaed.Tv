//
//  viNavigiationBarContent.m
//  FawaedTV
//
//  Created by Homam on 2015-02-12.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "viNavigiationBarContent.h"

@implementation viNavigiationBarContent
-(void)layoutSubviews{
    [super layoutSubviews];
    [self updateLabelsFonts];
}
-(void)updateLabelsFonts{
    CGFloat laTitleFont     = self.laTitle.frame.size.height - 1;
    CGFloat laDetailFont    = self.laTitle.frame.size.height - 3;
    if (laTitleFont > 17) laTitleFont = 17;
    if (laDetailFont > 15) laDetailFont = 15;
    
    self.laTitle.font = [UIFont systemFontOfSize:laTitleFont];
    self.laDetails.font = [UIFont systemFontOfSize:laDetailFont];
}
@end