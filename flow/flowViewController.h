//
//  flowViewController.h
//  flow
//
//  Created by Joost on 7/15/11.
//  Copyright 2011 Bitauto.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomFlowView.h"
@interface flowViewController : UIViewController <CustomFlowDataSource>
{
    CustomFlowView *flow;
    UILabel *current;
    UILabel *passed;
    UILabel *arrival;
}
@property (nonatomic, strong) IBOutlet CustomFlowView *flow;
@property (nonatomic, strong) IBOutlet UILabel *current;
@property (nonatomic, strong) IBOutlet UILabel *passed;
@property (nonatomic, strong) IBOutlet UILabel *arrival;

@end
