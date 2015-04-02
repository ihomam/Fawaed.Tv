//
//  soudePlayerVC.m
//  FawaedTV
//
//  Created by Homam on 2015-02-11.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "audioPlayerVC.h"
#import "AFSoundManager.h"
#import "episodeObject.h"

@interface audioPlayerVC ()
@property (weak, nonatomic) IBOutlet UISlider *sliTime;
@property (weak, nonatomic) IBOutlet UILabel *laTimeTotal;
@property (weak, nonatomic) IBOutlet UILabel *laTimeConsumed;
@property (weak, nonatomic) IBOutlet UILabel *laTitle;
@property BOOL canShowSliTimeProgress;
@property (nonatomic,strong) NSTimer *forwardTimer;
@property (nonatomic,strong) NSTimer *backwardTimer;
@end

@implementation audioPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.canShowSliTimeProgress = YES;
    [self prepareData];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [self becomeFirstResponder];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - actions
- (IBAction)stopPlaying:(id)sender {
    AFSoundManagerStatus status = [[AFSoundManager sharedManager] status];
    switch (status) {
        case AFSoundManagerStatusPlaying:
            [[AFSoundManager sharedManager]pause];
            break;
        case AFSoundManagerStatusPaused:
            [[AFSoundManager sharedManager]resume];
            break;
        default:
            [self prepareData];
            break;
    }
}
- (IBAction)forward:(id)sender {
    
    NSTimeInterval farword      = [AFSoundManager sharedManager].audioPlayer.currentTime + 5;
    NSTimeInterval duration     = [AFSoundManager sharedManager].audioPlayer.duration;
    
    if (farword<duration){
        CGFloat section = ((farword * 100) / duration)/100;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AFSoundManager sharedManager] pause];
            [[AFSoundManager sharedManager]moveToSection:section];
            [[AFSoundManager sharedManager]resume];
        });
    }

}
- (IBAction)backward:(id)sender {
    NSTimeInterval backward     = [AFSoundManager sharedManager].audioPlayer.currentTime - 5;
    NSTimeInterval duration     = [AFSoundManager sharedManager].audioPlayer.duration;
    if (backward>0){
        CGFloat section = ((backward * 100) / duration)/100;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AFSoundManager sharedManager] pause];
            [[AFSoundManager sharedManager]moveToSection:section];
            [[AFSoundManager sharedManager]resume];
        });
    }
}
- (IBAction)changeTime:(id)sender {
    self.canShowSliTimeProgress = NO;
    [[AFSoundManager sharedManager]moveToSection:self.sliTime.value];
    self.canShowSliTimeProgress = YES;
}
#pragma mark - prepare vc
-(void)prepareData{
    self.laTitle.text = self.epObj.episodeTitle;
    NSString *urlToFile = self.epObj.episodeLinkListen;
    if (self.isGoingToLocalFile) {
        urlToFile = self.epObj.episodeLinkMp3Local;
        [[AFSoundManager sharedManager]startPlayingLocalFileWithName:self.epObj.episodeTitle atPath:urlToFile withCompletionBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
            if(self.canShowSliTimeProgress)self.sliTime.value=(float)percentage/100;
            self.laTimeConsumed.text = stringFromInterval(elapsedTime);
            
            NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
            [songInfo setObject:self.epObj.episodeTitle forKey:MPMediaItemPropertyTitle];
            [songInfo setObject:self.epObj.episodeLecturer forKey:MPMediaItemPropertyArtist];
            [songInfo setObject:@([AFSoundManager sharedManager].audioPlayer.duration) forKey:MPMediaItemPropertyPlaybackDuration];
            [songInfo setObject:@(elapsedTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
//            [songInfo setObject: forKey:MPMediaItemPropertyArtwork];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        }];
        
    }else{
        [[AFSoundManager sharedManager]startStreamingRemoteAudioFromURL:urlToFile andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
            if(self.canShowSliTimeProgress)self.sliTime.value=(float)percentage/100;
            self.laTimeConsumed.text = stringFromInterval(elapsedTime);
        }];
    }
    if([[AFSoundManager sharedManager] status] == AFSoundManagerStatusPlaying)
        self.laTimeTotal.text   = stringFromInterval([AFSoundManager sharedManager].audioPlayer.duration);
}


NSString *stringFromInterval(NSTimeInterval timeInterval){
    static int secondsPerMinute  = 60;
    static int minutesPerHour    = 60;
    static int secondsPerHour    = 3600;
    static int hoursPerDay       = 24;
    
    // convert the time to an integer, as we don't need double precision, and we do need to use the modulous operator
    int ti      = round(timeInterval);
    int hours   = (ti / secondsPerHour) % hoursPerDay;
    int minutes = (ti / secondsPerMinute) % minutesPerHour;
    int seconds = ti % secondsPerMinute;
    
    NSString *time = [NSString stringWithFormat:@"%.2d",seconds];
    if (minutes>0) {time = [NSString stringWithFormat:@"%.2d:%.2d",minutes,seconds];}
    if (hours>0){time = [NSString stringWithFormat:@"%.2d:%.2d:%.2d",hours,minutes,seconds];}

    return time;
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
            [self forward:Nil];
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            [self backward:Nil];
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
-(void)continuousForward{
    if(!self.forwardTimer){
        self.forwardTimer = [NSTimer scheduledTimerWithTimeInterval:1 block:^{
            [self forward:Nil];
        } repeats:YES];
    }else{
        [self.forwardTimer invalidate];
        self.forwardTimer = Nil;
    }
}

-(void)continuousBackward{
    if(!self.backwardTimer){
        self.backwardTimer = [NSTimer scheduledTimerWithTimeInterval:1 block:^{
            [self backward:Nil];
        } repeats:YES];
    }else{
        [self.backwardTimer invalidate];
        self.backwardTimer = Nil;
    }}
@end
