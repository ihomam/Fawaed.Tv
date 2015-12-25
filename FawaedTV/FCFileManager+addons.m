//
//  FCFileManager+addons.m
//  FawaedTV
//
//  Created by Homam on 25/12/15.
//  Copyright © 2015 Homam. All rights reserved.
//

#import "FCFileManager+addons.h"

@implementation FCFileManager (addons)

+(NSArray *)listMediaFilesInDocumentsDirectory{
    NSArray *files;
    NSString *pathDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    files                   = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:pathDocuments error:nil];
    NSPredicate *predicate  = [NSPredicate predicateWithBlock:^BOOL(NSString *fileName, NSDictionary *bindings) {
        return ([fileName hasSuffix:@"mp3"]||[fileName hasSuffix:@"avi"]);
    }];
    files                   = [files filteredArrayUsingPredicate:predicate];
    files                   = [files sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        NSDate* d1 = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@",pathDocuments,obj1] error:nil][NSFileCreationDate];
        NSDate* d2 = [[NSFileManager defaultManager] attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@",pathDocuments,obj2] error:nil][NSFileCreationDate];
        return [d2 compare:d1];
    }];
    
    return files;
}

+(NSString *)sizeInMBForFileAtPath:(NSString *)path{
    
    NSDictionary *dict  = [self attributesOfItemAtPath:path];
    NSNumber *fileSize  = dict[@"NSFileSize"];
    fileSize = @(fileSize.doubleValue / 1000000);
    NSString *fileSizeInMB = [NSString stringWithFormat:@"%.01f",fileSize.floatValue];
    return fileSizeInMB;
}

+ (void)addSkipBackupAttributeToItemAtPath:(NSURL *)URL{
    if([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]){
        NSError *error = nil;
        BOOL success   = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                        forKey:NSURLIsExcludedFromBackupKey
                                         error:&error];
        if(!success){
            NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
    }
}

@end
