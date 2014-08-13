//
//  CustomFlowView.m
//  carGallery
//
//  Created by Joost on 7/4/11.
//  Copyright 2011 Bitauto.com. All rights reserved.
//

#import "JOSlideView.h"
#import <QuartzCore/QuartzCore.h>

@interface JOSlideView(/*PrivateMethod*/)
{
   
    NSRange  _visibleItems;
    NSInteger selectIndex;
    NSInteger _currentIndex;
    NSInteger _maxCountPerScreen;
    
}
@property (nonatomic,readwrite) CGSize itemsSize;
@property (nonatomic) NSInteger numberOfItems;
@property (nonatomic,strong) NSMutableSet * recycledViews;
@property (nonatomic,weak)  UIScrollView * scrollView;
@property (nonatomic,strong)  NSMutableArray * items;
- (void) setUpInitialize;
- (UIView*)loadViewAtIndex:(NSInteger) index;
- (void)caculateVisibleItems;
- (void)endSelection;
@end


#pragma mark 
@implementation JOSlideView
@synthesize selectionChanged;
@synthesize selectIndex;
@synthesize dataSource;
@synthesize willArriveAt;
@synthesize passedItem;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code
        [self setUpInitialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUpInitialize];
}
- (void)setUpInitialize
{  
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _scrollView =self;
    _scrollView.autoresizingMask =UIViewAutoresizingFlexibleWidth| UIViewAutoresizingFlexibleHeight;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    _scrollView.backgroundColor = [UIColor clearColor];
    
    self.clipsToBounds = YES;
    
    //datas
    _recycledViews =[NSMutableSet setWithCapacity:10];
    _itemSpace = 10;
    _visibleItems = NSMakeRange(0, 0);
    _currentIndex = -1;
    selectIndex =0;
    _numberOfItems =1;
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self caculateVisibleItems];
}
- (void)caculateVisibleItems
{
    if (_items.count ==0)
    {
        return;
    }
    

    float _itemRoom =_itemsSize.width+ _itemSpace;
    float leftPoz = _scrollView.contentOffset.x;
    float rightPoz = leftPoz + _scrollView.bounds.size.width;
    int _vbegin = (int)floor((leftPoz - _insets.left-_itemSpace/2 +_itemSpace)/_itemRoom);
    _vbegin = _vbegin<0? 0: _vbegin;
    float tmp = (rightPoz - _insets.left - _itemSpace/2.0f )/_itemRoom;
    int _vEnd =(int) floor(tmp);
    _vEnd = (_vEnd >= _numberOfItems ) ? _numberOfItems-1 : _vEnd;
    NSRange newRange = NSMakeRange(_vbegin, _vEnd-_vbegin+1);
    if (NSEqualRanges(_visibleItems,  newRange)) {
        return;
    }
    //load the  new cells
    NSRange _old = _visibleItems;
    _visibleItems = newRange;
    NSMutableIndexSet * added = [NSMutableIndexSet indexSetWithIndexesInRange:_visibleItems];
    //only add new cells, current displayed cells don't need to be add AGAIN
    [added removeIndexesInRange: _old];
    [added enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self loadViewAtIndex: idx];
    }];
    
    // recycle the off screen cells
    NSMutableIndexSet * oldIndexs = [NSMutableIndexSet indexSetWithIndexesInRange:_old];
    [oldIndexs removeIndexesInRange: _visibleItems];
    [oldIndexs enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self enqueueCellAtIndex: idx];
    }];
}
- (void)updateCurrentIndex
{
    //caculate current pointed cell
    float _tt = _scrollView.contentOffset.x/(_itemsSize.width + _itemSpace);
    int _tCurrent =(int)floorf(_tt);
    _tCurrent = _tt- _tCurrent <=0.5f? _tCurrent : _tCurrent+1;
    _tCurrent = _tCurrent <0 ? 0:_tCurrent;
    _tCurrent = _tCurrent>= _items.count ? _items.count-1 : _tCurrent;
    if(_tCurrent != _currentIndex)
    {
        if (passedItem)
        {
            passedItem(_currentIndex);
        }
        _currentIndex = _tCurrent;
        if (willArriveAt)
        {
            willArriveAt(_currentIndex);
        }
    }
}
- (UIView*)loadViewAtIndex:(NSInteger) index
{

    UIView* _tView = _items[index];
    CGRect _rct = [self rectForItemAtIndex: index];
    if ([_tView isKindOfClass:[NSNull class]])
    {
        _tView = [dataSource viewForIndex: index InView: self];
        @synchronized(_items)
        {
            _items[index] = _tView;
        }
        
    }
    if (nil == _tView.superview)
    {
        [_scrollView addSubview: _tView];
    }
   _tView.frame = _rct;
    
    return _tView;
    
}
- (CGRect)rectForItemAtIndex:(NSInteger) index
{
    CGRect _t= CGRectZero;
    _t.size = _itemsSize;
    _t.origin = CGPointMake( _insets.left + _itemSpace/2.0f + index*(_itemsSize.width+ _itemSpace), (self.bounds.size.height-(_insets.top+_insets.bottom) -_itemsSize.height)/2.0f+_insets.top);
    return _t;
}
- (void)reloadData
{
    
    _numberOfItems = [dataSource numberOfItems: self];
    _itemsSize = [dataSource sizeOfItem:self];
    
    
  
    for (int i = _visibleItems.location ; (i!=_visibleItems.location+_visibleItems.length) && i<_items.count; ++i)
    {
         [self enqueueCellAtIndex: i];
    }
    _visibleItems = NSMakeRange(0, 0);
    _items = [[NSMutableArray alloc] initWithCapacity: _numberOfItems];
    for (int i=0; i!= _numberOfItems; ++i)
    {
        [_items addObject: [NSNull null]];
    }
    [self caculateContentSize];
    [self caculateVisibleItems];
}

- (void)caculateContentSize
{
    self.contentSize = CGSizeMake(_insets.left+ _insets.right +_numberOfItems*(_itemsSize.width+ _itemSpace) , _scrollView.bounds.size.height);
}

#pragma mark
- (void)endSelection
{
    
    float _tt = _scrollView.contentOffset.x/(_itemsSize.width + _itemSpace);
    int _tCurrent =(int)floorf(_tt);
    _tCurrent = _tt- _tCurrent <0.5f? _tCurrent : _tCurrent+1;
    [self setSelectIndex: _tCurrent];
   }
- (void)setSelectIndex:(NSInteger) index
{
    if (index <0 || index>= _items.count)
    {
        return;
    }
    CGFloat _offsetX = index*(_itemsSize.width + _itemSpace);
    if (index != selectIndex || _offsetX != _scrollView.contentOffset.x)
    {
        [_scrollView setContentOffset: CGPointMake(_offsetX, _scrollView.contentOffset.y) animated: YES];
        if(index != selectIndex)
        {
            selectIndex = index;
            if (selectionChanged)
            {
                selectionChanged(selectIndex);
            }
        }

    }
}
- (UIView *) viewAtIndex:(int) index
{
    if (index<0 || index>= _items.count)
    {
        return nil;
    }
    UIView * _v =[self loadViewAtIndex: index];
    return _v;
}

-(void)enqueueCellAtIndex:(NSInteger) index
{
    if (_items.count <7)
    {
        return;
    }
    UIView * cell = _items[index];
    if ([cell isKindOfClass:[UIView class]]) {
        [cell removeFromSuperview];
        _items[index] = [NSNull null];
        [_recycledViews addObject: cell];
    }
   
    
}
- (UIView *) dequeueCell
{
    if (_recycledViews.count>0)
    {
        UIView * cell = [_recycledViews anyObject];
        [_recycledViews removeObject:cell];
        return cell;
    }else
    {
        return nil;
    }
    
}

- (void)updateItemsInIndexSet:(NSIndexSet*) indexset
{
    [indexset enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        UIView * _tView = [self loadViewAtIndex: idx];
//        if ([_tView isKindOfClass:[UIView class]])
//        {
//            CGRect _rct = [self rectForItemAtIndex: idx];
//            CGPoint _pos =CGPointMake(_rct.origin.x+_rct.size.width/2.0f, _rct.origin.y+_rct.size.height/2.0f);
//            if (!CGPointEqualToPoint(_pos, _tView.center)  )
//            {
//                _tView.center = _pos;
//            }
//        }
        
    }];
}
#pragma mark remove & insert

- (void)insertItemAtIndex:(NSInteger) index animated:(BOOL)animated
{
    //add data
    [_items insertObject:[NSNull null] atIndex:index];
    _numberOfItems = _items.count;
    
    [self caculateContentSize];
    //push others out if is visible or ahead of them
    if (index<= _visibleItems.location + _visibleItems.length-1) {
        
        
        NSRange effectedVisible = _visibleItems;
        //indices has shift right by 1, a cell should be pop out , but left in screen
        effectedVisible.length +=1;
        NSMutableIndexSet * indexset = [NSMutableIndexSet indexSetWithIndexesInRange: effectedVisible];
        _visibleItems = NSMakeRange(0, 0);
        [self caculateVisibleItems];
        [self updateItemsInIndexSet:indexset];
    }
    
    
}
- (void)removeItemAtIndex:(NSInteger) index animated:(BOOL)animated
{
    //remove data
    [self enqueueCellAtIndex: index];
    [_items removeObjectAtIndex: index];
    [self caculateContentSize];
    
    //pull others in if it is visible or ahead of them
    if (index<= _visibleItems.location + _visibleItems.length-1) {
        //indices has shift left by 1
        
        NSRange effectedVisible = _visibleItems;
        if (index <= _visibleItems.location) {
            effectedVisible.location -=1;
            effectedVisible.length+=1;
        }else
        {
            effectedVisible.location = index;
            effectedVisible.length += _visibleItems.location + _visibleItems.length;
        }
        
        NSMutableIndexSet * indexset = [NSMutableIndexSet indexSetWithIndexesInRange: effectedVisible];
        [self updateItemsInIndexSet:indexset];
    }

}

#pragma mark accessors
- (void)setFrame:(CGRect) rect
{
    if (!CGRectEqualToRect(self.frame, rect))
    {
        [super setFrame:rect];
        [self caculateVisibleItems];
        [self updateItemsInIndexSet:[NSIndexSet indexSetWithIndexesInRange:_visibleItems]];
         self.selectIndex = selectIndex;
    }
}

@end
