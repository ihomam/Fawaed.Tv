//
//  donwloadBtn.m
//  FawaedTV
//
//  Created by Homam on 29/12/15.
//  Copyright © 2015 Homam. All rights reserved.
//

#import "downloadBtn.h"
#import "episodeObject.h"
#import <FFCircularProgressView/FFCircularProgressView.h>
#import <FFCircularProgressView/UIColor+iOS7.h>
@interface downloadBtn()
    @property (nonatomic,strong) FFCircularProgressView *viDownloadState;
@end

@implementation downloadBtn
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}
-(void)setup{
    CGFloat width  = self.frame.size.width;
    CGFloat height = self.frame.size.height;
//    CGFloat minVal = MIN(width, height);
    
    self.viDownloadState           = [[FFCircularProgressView alloc]initWithFrame:CGRectMake(0,0,
                                                                                             35,
                                                                                             35)];
    self.viDownloadState.center    = CGPointMake(width/2, height/2);
    self.viDownloadState.tintColor = [UIColor whiteColor];
    self.viDownloadState.hidden    = YES;
    self.viDownloadState.userInteractionEnabled = NO;
    [self addSubview:self.viDownloadState];
}
-(void)setProgressTintColorios7Blue{
    self.viDownloadState.tintColor = [UIColor ios7Blue];
}
-(void)handleBtnDownloadProgressForEpDownObja:(episodeDownloadObject *)epDownObja{
    downloadStatus btnStatus = epDownObja.episodeDownloadCurrentStatus;
    switch (btnStatus) {
        case downloadStatusInitiating:{
            if (!self.highlighted)
                [self setHighlighted:YES];
            
            [self.viDownloadState setProgress:0];
            self.viDownloadState.hidden = NO;
            [self.viDownloadState startSpinProgressBackgroundLayer];
            break;
        }
            
        case downloadStatusDownloading:{
            [self.viDownloadState setProgress:epDownObja.episodeDownloadProgress.fractionCompleted];
            self.viDownloadState.hidden = NO;
            [self.viDownloadState stopSpinProgressBackgroundLayer];
            
            if (!self.highlighted)
                [self setHighlighted:YES];
            break;
        }
            
        case downloadStatusFinished:{
            self.viDownloadState.hidden = YES;
            [self setHighlighted:NO];
            
            if (!epDownObja.episodeDownloadError) {
                [self setSelected:YES];
            }
            
            break;
        }
            
        case downloadStatusCanceled:{
            self.viDownloadState.hidden = YES;
            [self setHighlighted:NO];
            break;
        }
            
        case downloadStatusBasic:{
            self.viDownloadState.hidden = YES;
            [self setHighlighted:NO];
            break;
        }
        default:{
            self.viDownloadState.hidden = YES;
            [self setHighlighted:NO];
            break;
        }
    }
}

@end
