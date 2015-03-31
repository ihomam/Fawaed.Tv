//
//  episodeObject.m
//  FawaedTV
//
//  Created by Homam on 2014-12-13.
//  Copyright (c) 2014 Homam. All rights reserved.
//

#import "episodeObject.h"

@implementation episodeObject
-(BOOL)checkIfMp3FileInLocalFolder{
    BOOL exist          = NO;
    NSString *fileName  = [NSString stringWithFormat:@"%d.mp3",self.episodeID];
    NSString *pathFile  = [NSString stringWithFormat:@"%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],fileName];
    exist               = [[NSFileManager defaultManager]fileExistsAtPath:pathFile isDirectory:Nil];
    self.episodeLinkMp3Local= pathFile;
    return exist;
}
-(NSString *)episodeLinkMp3Local{
    static NSString *path   = Nil;
    NSString *fileName      = [NSString stringWithFormat:@"%d.mp3",self.episodeID];
    path                    = [NSString stringWithFormat:@"%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],fileName];
    
    return path;
}
-(NSString *)episodeLinkAviLocal{
    static NSString *path   = Nil;
    NSString *fileName      = [NSString stringWithFormat:@"%d.avi",self.episodeID];
    path                    = [NSString stringWithFormat:@"%@/%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0],fileName];
    
    return path;
}

@end

@implementation episodeDownloadObject
@end