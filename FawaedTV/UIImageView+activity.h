//
//  UIImageView+activity.h
//  appe
//
//  Created by Homama on 3/28/14.
//  Copyright (c) 2014 viganium. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface UIImageView (activity)
-(void)addActivityIndicator;
-(void)removeActivityIndicator;
-(void)setImageWithURLRequest:(NSURLRequest *)urlRequest
        withActivityIndicator:(BOOL)withActivityIndicator
                      success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                      failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;
-(void)setImageWithURLRequest:(NSURLRequest *)urlRequest
   withActivityIndicatorColor:(UIActivityIndicatorViewStyle)withActivityIndicatorColor
                      success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                      failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;
@end
