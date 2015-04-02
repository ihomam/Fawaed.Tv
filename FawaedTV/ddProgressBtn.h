//
//  ddProgressBtn.h
//  FawaedTV
//
//  Created by Homam on 2015-03-14.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import "VBFPopFlatButton.h"
@class episodeDownloadObject;

@interface ddProgressBtn : VBFPopFlatButton

-(void)handelEpDownObj:(episodeDownloadObject *)epDownObj;
-(void)setCheckmark;
@end
