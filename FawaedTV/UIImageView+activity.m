//
//  UIImageView+activity.m
//  appe
//
//  Created by Homama on 3/28/14.
//  Copyright (c) 2014 viganium. All rights reserved.
//
const int tagOfUIActivityIndicatorView  = 20140328;
#import "UIImageView+activity.h"

@implementation UIImageView (activity)
-(void)addActivityIndicatorWithStyle:(UIActivityIndicatorViewStyle)activityIndicatorColor{
    if (![self viewWithTag:tagOfUIActivityIndicatorView]) {
        UIActivityIndicatorView *aiview     = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        aiview.activityIndicatorViewStyle   = activityIndicatorColor;
        aiview.alpha                        = 0;
        aiview.tag                          = tagOfUIActivityIndicatorView;
        aiview.center                       = CGPointMake((self.frame.size.width / 2) , (self.frame.size.height / 2) );
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addSubview:aiview];
            [aiview startAnimating];
            [UIView animateWithDuration:0.2 animations:^{
                aiview.alpha = 1;
            }];
        });
    }
}
-(void)addActivityIndicator{
    if (![self viewWithTag:tagOfUIActivityIndicatorView]) {
        UIActivityIndicatorView *aiview     = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
        aiview.activityIndicatorViewStyle   = UIActivityIndicatorViewStyleGray;
        aiview.alpha                        = 0;
        aiview.tag                          = tagOfUIActivityIndicatorView;
        aiview.center                       = CGPointMake((self.frame.size.width / 2) , (self.frame.size.height / 2) );

        dispatch_async(dispatch_get_main_queue(), ^{
            [self addSubview:aiview];
            [aiview startAnimating];
            [UIView animateWithDuration:0.2 animations:^{
                aiview.alpha = 1;
            }];
        });
    }
}
-(void)layoutSubviews{
    [super layoutSubviews];
    UIView *aiview  = [self viewWithTag:tagOfUIActivityIndicatorView];
    aiview.center   = CGPointMake((self.frame.size.width / 2) , (self.frame.size.height / 2) );
}
-(void)removeActivityIndicator{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *aiview = [self viewWithTag:tagOfUIActivityIndicatorView];
        [UIView animateWithDuration:0.2 animations:^{
            aiview.alpha = 0;
        }completion:^(BOOL finished) {
            [aiview removeFromSuperview];
        }];
    });
}
- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
         withActivityIndicator:(BOOL)withActivityIndicator
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure{
    __weak typeof (self) weakSelf = self;
    [self addActivityIndicator];
    [self setImageWithURLRequest:urlRequest
                placeholderImage:Nil
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                             [weakSelf removeActivityIndicator];
                             success(request,response,image);
                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                             if(failure){
                                 failure(request,response,error);
                             }
                         }];
}
-(void)setImageWithURLRequest:(NSURLRequest *)urlRequest
   withActivityIndicatorColor:(UIActivityIndicatorViewStyle)activityIndicatorColor
                      success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                      failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure{
    __weak typeof (self) weakSelf = self;
    [self addActivityIndicatorWithStyle:activityIndicatorColor];
    [self setImageWithURLRequest:urlRequest
                placeholderImage:Nil
                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                             [weakSelf removeActivityIndicator];
                             success(request,response,image);
                         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                             if(failure){
                                 failure(request,response,error);
                             }
                         }];
}

@end