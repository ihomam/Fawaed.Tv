//
//  downloadsTVCCell.h
//  FawaedTV
//
//  Created by Homam on 2015-03-10.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ddProgressBtn;
@interface downloadsTVCCell : UITableViewCell
    @property (weak, nonatomic) IBOutlet UILabel         *laTitle;
    @property (weak, nonatomic) IBOutlet ddProgressBtn   *btnDownloadControl;
    @property (weak, nonatomic) IBOutlet UILabel         *laDownloadDetails;
@end