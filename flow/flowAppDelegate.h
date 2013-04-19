//
//  flowAppDelegate.h
//  flow
//
//  Created by Joost on 7/15/11.
//  Copyright 2011 Bitauto.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class flowViewController;

@interface flowAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, strong) IBOutlet UIWindow *window;

@property (nonatomic, strong) IBOutlet flowViewController *viewController;

@end
