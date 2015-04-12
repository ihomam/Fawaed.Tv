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
#import "UIImage+BlurredFrame.h"

@interface audioPlayerVC ()
@property (weak, nonatomic) IBOutlet    UISlider        *sliTime;
@property (weak, nonatomic) IBOutlet    UILabel         *laTimeTotal;
@property (weak, nonatomic) IBOutlet    UILabel         *laTimeConsumed;
@property (weak, nonatomic) IBOutlet    UILabel         *laTitle;
@property (weak, nonatomic) IBOutlet    UIButton        *btnPlayPause;
@property (weak, nonatomic) IBOutlet    UIImageView     *imgVEpisodeImg;
@property                               BOOL            canShowSliTimeProgress;
@end

@implementation audioPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.canShowSliTimeProgress = YES;
    [self prepareData];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self prepareUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
#pragma mark - actions
- (IBAction)stopPlaying:(id)sender {
    AFSoundManagerStatus status = [[AFSoundManager sharedManager] status];
    switch (status) {
        case AFSoundManagerStatusPlaying:{
            [[AFSoundManager sharedManager]pause];
            [self.btnPlayPause setImage:[UIImage imageNamed:@"player-play"] forState:UIControlStateNormal];
        }
            break;
        case AFSoundManagerStatusPaused:{
            [[AFSoundManager sharedManager]resume];
            [self.btnPlayPause setImage:[UIImage imageNamed:@"player-pause"] forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}
- (IBAction)forward:(id)sender {
    
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
- (IBAction)backward:(id)sender {
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
- (IBAction)changeTime:(id)sender {
    self.canShowSliTimeProgress = NO;
    [[AFSoundManager sharedManager]moveToSection:self.sliTime.value];
    self.canShowSliTimeProgress = YES;
}
#pragma mark - prepare vc
-(void)prepareUI{
    [self.sliTime setThumbImage:[UIImage imageNamed:@"player-dot"] forState:UIControlStateNormal];
    [self.sliTime setTintColor:[UIColor whiteColor]];
    self.laTitle.text = self.epObj.episodeTitle;
    if (self.epObj.episodeLinkImageObject) {
        UIImage *img = self.epObj.episodeLinkImageObject;
        self.imgVEpisodeImg.image = [img applyBlurWithRadius:1.7
                                                   tintColor:[UIColor colorWithWhite:.1 alpha:.6]
                                       saturationDeltaFactor:1
                                                   maskImage:Nil
                                                     atFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
    }else{
        [self.epObj getImageObjFromWebservice:^(UIImage *img) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imgVEpisodeImg.image = [img applyBlurWithRadius:1.7
                                                           tintColor:[UIColor colorWithWhite:.1 alpha:.6]
                                               saturationDeltaFactor:1
                                                           maskImage:Nil
                                                             atFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
            });
        }];
    }
}
-(void)prepareData{
    NSString *urlToFile = self.epObj.episodeLinkListen;
    [AFSoundManager sharedManager].audioPlayer = Nil;
    [AFSoundManager sharedManager].player = Nil;
    
    if (self.isGoingToLocalFile) {
        urlToFile = self.epObj.episodeLinkMp3Local;
        [[AFSoundManager sharedManager]startPlayingLocalFileWithName:self.epObj.episodeTitle
                                                              atPath:urlToFile
                                                 withCompletionBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
                                                     [self prepareMPMediaController:percentage
                                                                        elapsedTime:elapsedTime
                                                                      timeRemaining:timeRemaining
                                                                              error:error
                                                                           finished:finished];
        }];
    }else{
        [[AFSoundManager sharedManager]startStreamingRemoteAudioFromURL:urlToFile
                                                               andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
                                                                   [self prepareMPMediaController:percentage
                                                                                      elapsedTime:elapsedTime
                                                                                    timeRemaining:timeRemaining
                                                                                            error:error
                                                                                         finished:finished];
        }];
    }
}
-(void)prepareMPMediaController:(int)percentage
                    elapsedTime:(CGFloat)elapsedTime
                  timeRemaining:(CGFloat)timeRemaining
                          error:(NSError *)error
                       finished:(BOOL)finished{
    if(self.canShowSliTimeProgress)self.sliTime.value=(float)percentage/100;
    self.laTimeConsumed.text = [self stringFromInterval:elapsedTime];
    self.laTimeTotal.text = [self stringFromInterval:[AFSoundManager sharedManager].duration];
    NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
    [songInfo setObject:self.epObj.episodeTitle forKey:MPMediaItemPropertyTitle];
    [songInfo setObject:self.epObj.episodeLecturer forKey:MPMediaItemPropertyArtist];
    [songInfo setObject:@([AFSoundManager sharedManager].duration) forKey:MPMediaItemPropertyPlaybackDuration];
    [songInfo setObject:@(elapsedTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
}
-(NSString *)stringFromInterval:(NSTimeInterval)timeInterval{
    NSString *time;
    static int secondsPerMinute  = 60;
    static int minutesPerHour    = 60;
    static int secondsPerHour    = 3600;
    static int hoursPerDay       = 24;
    
    // convert the time to an integer, as we don't need double precision, and we do need to use the modulous operator
    int ti      = round(timeInterval);
    int hours   = (ti / secondsPerHour) % hoursPerDay;
    int minutes = (ti / secondsPerMinute) % minutesPerHour;
    int seconds = ti % secondsPerMinute;
    
    time        = [NSString stringWithFormat:@"%.2d",seconds];
    if (minutes>0) {time = [NSString stringWithFormat:@"%.2d:%.2d",minutes,seconds];}
    if (hours>0){time = [NSString stringWithFormat:@"%.2d:%.2d:%.2d",hours,minutes,seconds];}
    
    return time;
}

@end
