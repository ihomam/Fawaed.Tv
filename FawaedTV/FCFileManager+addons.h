//
//  FCFileManager+addons.h
//  FawaedTV
//
//  Created by Homam on 25/12/15.
//  Copyright © 2015 Homam. All rights reserved.
//

#import <FCFileManager/FCFileManager.h>

@interface FCFileManager (addons)

+(NSArray *)listMediaFilesInDocumentsDirectory;
+(void)addSkipBackupAttributeToItemAtPath:(NSURL *)URL;
+(NSString *)sizeInMBForFileAtPath:(NSString *)path;

@end
