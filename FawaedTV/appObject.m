//
//  appObject.m
//  FawaedTV
//
//  Created by Homam on 2015-04-12.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "appObject.h"
#import "AFSoundManager.h"

@interface appObject()
    @property (nonatomic,strong)            NSTimer         *forwardTimer;
    @property (nonatomic,strong)            NSTimer         *backwardTimer;
@end
@implementation appObject
- (BOOL)canBecomeFirstResponder
{
    return YES;
}


- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    AFSoundManagerStatus playerStatus =  [[AFSoundManager sharedManager] status];
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause:{
            if (playerStatus == AFSoundManagerStatusPlaying) {
                [[AFSoundManager sharedManager]pause];
            }else if(playerStatus == AFSoundManagerStatusPaused){
                [[AFSoundManager sharedManager]resume];
            }
        }
            break;
        case UIEventSubtypeRemoteControlPlay:
            [[AFSoundManager sharedManager]resume];
            break;
        case UIEventSubtypeRemoteControlPause:
            [[AFSoundManager sharedManager]pause];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            [self forward];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self backward];
            break;
        case UIEventSubtypeRemoteControlBeginSeekingForward:
            [self continuousForward];
            break;
        case UIEventSubtypeRemoteControlEndSeekingForward:
            [self continuousForward];
            break;
        case UIEventSubtypeRemoteControlBeginSeekingBackward:
            [self continuousBackward];
            break;
        case UIEventSubtypeRemoteControlEndSeekingBackward:
            [self continuousBackward];
            break;
        default:
            break;
    }
}
- (void)forward{
    
    NSTimeInterval farword      = [AFSoundManager sharedManager].currentTime + 5;
    NSTimeInterval duration     = [AFSoundManager sharedManager].duration;
    
    if (farword<duration){
        CGFloat section = ((farword * 100) / duration)/100;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AFSoundManager sharedManager] pause];
            [[AFSoundManager sharedManager]moveToSection:section];
            [[AFSoundManager sharedManager]resume];
        });
    }
    
}
- (void)backward{
    NSTimeInterval backward     = [AFSoundManager sharedManager].currentTime - 5;
    NSTimeInterval duration     = [AFSoundManager sharedManager].duration;
    if (backward>0){
        CGFloat section = ((backward * 100) / duration)/100;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AFSoundManager sharedManager] pause];
            [[AFSoundManager sharedManager]moveToSection:section];
            [[AFSoundManager sharedManager]resume];
        });
    }
}
-(void)continuousForward{
    if(!self.forwardTimer){
        self.forwardTimer = [NSTimer scheduledTimerWithTimeInterval:1 block:^{
            [self forward];
        } repeats:YES];
    }else{
        [self.forwardTimer invalidate];
        self.forwardTimer = Nil;
    }
}

-(void)continuousBackward{
    if(!self.backwardTimer){
        self.backwardTimer = [NSTimer scheduledTimerWithTimeInterval:1 block:^{
            [self backward];
        } repeats:YES];
    }else{
        [self.backwardTimer invalidate];
        self.backwardTimer = Nil;
    }}


@end
