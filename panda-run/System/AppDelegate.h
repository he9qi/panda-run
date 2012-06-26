//
//  AppDelegate.h
//  htest1
//
//  Created by Qi He on 12-6-21.
//  Copyright (c) 2012年 Heyook. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate>{
	UIWindow *window;
	ViewController *viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
