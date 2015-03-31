//
//  fileObject.h
//  FawaedTV
//
//  Created by Homam on 2015-03-30.
//  Copyright (c) 2015 Homam. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, fileType) {
    fileTypeAudio,
    fileTypeVideo,
};

@interface fileObject : NSObject
@property (nonatomic)        int      fileID;
@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) NSString *fileSize;
@property (nonatomic)        fileType fileType;
@property (nonatomic)        int      fileEpisodeID;
@property (nonatomic,strong) NSString *fileEpisodeTitle;
@property (nonatomic,strong) NSString *fileEpisodeLecturer;

+(NSArray *)getFilesFromDatabase;
-(void)addToDataBase;
-(void)removeFromDataBase;
-(BOOL)isAlreadyAvailableInDB;
+(fileObject *)getFileObjForFileName:(NSString *)fileName fromList:(NSArray *)listOfObjs;
-(NSString *)getDescription;
@end