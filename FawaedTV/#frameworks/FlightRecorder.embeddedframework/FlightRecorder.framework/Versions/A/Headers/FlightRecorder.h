//
//  FlightRecorder.h
//  FlightRecorder
//
//  Created by Davut Can Abacigil on 9/11/13.
//  Copyright (c) 2014 FlightRecorder, Inc. All rights reserved.
//  Version : 1.7.6

#import <Foundation/Foundation.h>

typedef enum FE_LOG_LEVEL
{
    FE_LOG_LEVEL_NONE,
    FE_LOG_LEVEL_WARNING,
    FE_LOG_LEVEL_INFO,
    FE_LOG_LEVEL_ALL,
    FE_LOG_LEVEL_REQUIRED
}FE_LOG_LEVEL;


typedef enum FE_QUALITY
{
    FE_QUALITY_LOW,
    FE_QUALITY_LOW_PLUS,
    FE_QUALITY_MEDIUM,
    FE_QUALITY_MEDIUM_PLUS,
    FE_QUALITY_HIGH,
    FE_QUALITY_HIGH_PLUS,
    FE_QUALITY_HD
}FE_QUALITY;

@interface FlightRecorder : NSObject


@property(nonatomic, assign) BOOL shouldWaitForLocation;
@property(nonatomic, assign) BOOL shouldStartLocationManager;

@property (nonatomic, strong) NSString *accessKey;
@property (nonatomic, strong) NSString *secretKey;
@property(nonatomic, strong) NSDictionary *userDefinedDictionary;
@property(nonatomic, strong) NSString *userID;
@property(nonatomic, assign) float recordingFPS;
@property(nonatomic, readonly) NSString *SDKVersion;
@property(nonatomic, assign) FE_LOG_LEVEL logLevel;
@property(nonatomic, assign) FE_QUALITY quality;
@property(nonatomic, assign) float maxSessionTime;
@property(nonatomic, assign) BOOL isMaxSessionTimeEnabled;
@property(nonatomic, assign) BOOL disableCaptureOnUserActions;
@property(nonatomic, assign) int dispatchInterval;
@property(nonatomic, assign) id delegate;
/* Returns the default singleton instance.
 */
+ (FlightRecorder *) sharedInstance;

/* Sets FlightRecorder Access Key and Secret Key
 */
-(void)setAccessKey:(NSString *)access_key secretKey:(NSString *)secretKey;

/* Check for are access keys set.
 */
-(BOOL)isAccessKeysSet;

/* Sets a UserID, so you can easily find sessions
 */

-(void)setSessionUserID:(NSString *)userID;

/* Sets a user defined dictionary for every session.
 */

-(void)setPreDefinedDictionaryForSession:(NSDictionary *)dict;

/* Starts SDK to record and track all events.
 */
-(void)startFlight;

/* A simple log method. Logs key and value at current time.
 For example; Name : "UserProfileViewController"
              Value : "UserProfileViewController view did load.
 
 You may set name and value as you want.
 */

-(void)logWithName:(NSString *)name value:(NSString *)value;

/* A simple log method with NSDictionary or NSArray as value. Logs key and value at current time.
 For example; Name : "User Profile Loaded"
 Value : A NSDictionary or NSArray object.
 SDK serializes value object.
 
 You may set name and value as you want.
 */

-(void)logWithName:(NSString *)name object:(id)obj;

/* A simple log method for API Requests. Logs key and value at current time.

 */

-(void)logAPIRequestWithName:(NSString *)name url:(NSString *)url httpMethod:(NSString *)method requestBody:(NSString *)body requestHeaders:(NSDictionary *)requestHeaders responseStatusCode:(int)responseStatusCode responseString:(NSString *)responseString responseHeaders:(NSDictionary *)responseHeaders;

/* Same with log method. Logs key and value at current time.
 Only difference is you may want to filter these logs with their types on our web site.
Show only logs, Show only warnings, etc.
 */

-(void)warningWithName:(NSString *)name value:(NSString *)value;

/* Same with log method with NSDictionary or NSArray as value. Logs key and value at current time.
 
 Only difference is you may want to filter these logs with their types on our web site.
 Show only logs, Show only warnings, etc.
 
 SDK serializes value object.
 */
-(void)warningWithName:(NSString *)name object:(id)obj;

/* A simple log method. Logs application's page views.
 
 You may set name and value as you want.
 */

-(void)trackPageView:(NSString *)name;

/* A simple track event method. Log your custom events with this function
 
 */
-(void)trackEventWithCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSString *)value;

/* Save the device token to send push messages from FlightRecorder
 
 */

-(void)setDeviceTokenFromData:(NSData *)deviceToken;


/* SDK has a stopwatch, so it returns current seconds for current session.
 If a session ends, stopwatch will be reset.
 */

-(NSTimeInterval)getRunTime;

/* Start hiding UITextField collection */

-(void)startPrivacyForTextFields:(NSArray *)controls;

/* Stop hiding UITextField collection */
-(void)stopPrivacyForTextField;


-(void)startPrivacyForViews:(NSArray *)views;

-(void)stopPrivacyForViews;


@end

@protocol FlightRecorderDelegate <NSObject>
- (void) flightrecorderDidStart;
- (void) flightrecorderDidFail;
@end
