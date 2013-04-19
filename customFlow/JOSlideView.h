//
//  CustomFlowView.h
//  carGallery
//
//  Created by Joost on 7/4/11.
//  Copyright 2011 Bitauto.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JOSlideView;
@protocol CustomFlowDataSource <NSObject>

- (NSInteger)numberOfItems:(JOSlideView*) flowView;
- (CGSize) sizeOfItem:(JOSlideView*) flowView;
- (UIView *) viewForIndex:(NSInteger) index InView:(JOSlideView*) flowView;
@optional
- (CGFloat) spaceBetweenItems:(JOSlideView*) flowView;

@end
#pragma mark
@interface JOSlideView : UIScrollView
{
    
    
}
@property (nonatomic,readwrite) CGSize itemsSize;
@property (nonatomic,readwrite) CGFloat itemSpace;

@property (nonatomic,readonly) NSInteger selectIndex;
@property (nonatomic,weak)IBOutlet  id<CustomFlowDataSource> dataSource;
@property (nonatomic,strong) void (^willArriveAt)(int index);
@property (nonatomic,strong)  void (^passedItem)(int index);
@property (nonatomic,strong) void (^selectionChanged)(int buttonIndex);

- (UIView *) viewAtIndex:(int) index;
- (void) reloadData;
- (CGRect)rectForItemAtIndex:(NSInteger) index;
- (UIView *) dequeueCell;
@end
