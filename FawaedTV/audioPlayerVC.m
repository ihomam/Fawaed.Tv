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

@end

@implementation audioPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)stopPlaying:(id)sender {
    [[AFSoundManager sharedManager]stop];
}
#pragma mark - prepare vc
-(void)prepareData{
    NSString *urlToFile = self.epObj.episodeLinkListen;
    if (self.isGoingToLocalFile) {
        urlToFile = self.epObj.episodeLinkMp3Local;
        [[AFSoundManager sharedManager]startPlayingLocalFileWithName:self.epObj.episodeTitle
                                                              atPath:urlToFile
                                                 withCompletionBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
            NSLog(@"%d %f %f %@ %d",percentage,elapsedTime,timeRemaining,error,finished);
            
        }];
    }else{
        [[AFSoundManager sharedManager]startStreamingRemoteAudioFromURL:urlToFile
                                                               andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
            NSLog(@"%d %f %f %@ %d",percentage,elapsedTime,timeRemaining,error,finished);
        }];
    }

}

@end
