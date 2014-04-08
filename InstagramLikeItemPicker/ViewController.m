//
//  ViewController.m
//  SlideTest
//
//  Created by 能登 要 on 2014/04/06.
//  Copyright (c) 2014年 Irimasu Densan Planning. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UICollectionViewDataSource,UICollectionViewDelegate>
{
    __weak IBOutlet UIView *_toolBarView;
    __weak IBOutlet UICollectionView *_collectionView;
    IBOutlet UIPanGestureRecognizer *_panGestureRecogninzer;
    UIView *_boardView;
    UITapGestureRecognizer *_tapGestureRecogninzer;
    
    NSValue *_contentOffset;
    CGFloat _sliderMinVertical;
    CGFloat _sliderMaxVertical;
}
@property(readonly,nonatomic) UIView *boardView;
@end

@implementation ViewController

- (UIView *) boardView
{
    if( _boardView == nil ){
        _boardView = [[UIView alloc] initWithFrame:CGRectMake(.0f, .0f, self.view.frame.size.width, self.view.frame.size.height)];
        _boardView.backgroundColor = [UIColor colorWithRed:1.0f green:.0f blue:.0f alpha:.5f];
        _boardView.opaque = NO;

        _tapGestureRecogninzer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(firedListClose:)];
        [_boardView addGestureRecognizer:_tapGestureRecogninzer];
    }
    return _boardView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _sliderMinVertical = 26.0f + _toolBarView.frame.size.height;
    _sliderMaxVertical = _collectionView.frame.origin.y;
    
    [_collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 40;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellItem" forIndexPath:indexPath];
    return cell;
}

- (void) startTransitionWithithVelocity:(CGPoint)velocity
{
    if( _collectionView.frame.origin.y <  _sliderMaxVertical && velocity.y <= 100.0f ){
        NSLog(@"Open");
        [self firedListOpen:nil];
    }else{
        [self firedListClose:nil];
    }
}

- (IBAction) firedListOpen:(UITapGestureRecognizer *) tapGestureRecognizer
{
    if( _collectionView.frame.origin.y == _sliderMinVertical ){
        if( tapGestureRecognizer != nil ){
            [self firedListClose:nil];
        }
    }else{
        const CGFloat verticalMax = _sliderMaxVertical - _toolBarView.frame.size.height * .5f;
            // ドラッグできる下限
        [self updateBoard];
        
        CGPoint center = CGPointMake(_toolBarView.center.x , _sliderMinVertical - _toolBarView.frame.size.height * .5f );
        center.y = MAX(center.y, _sliderMinVertical - _toolBarView.frame.size.height * .5f );
        center.y = MIN(center.y, verticalMax );
        
        __block CGFloat diff = .0f;
        [UIView animateWithDuration:.25f delay:.0f options:0 animations:^{
            _toolBarView.center = center;
            diff = CGRectGetMaxY(_toolBarView.frame) - _collectionView.frame.origin.y;
            _collectionView.frame = (CGRect){  CGPointMake(_collectionView.frame.origin.x, _collectionView.frame.origin.y + diff)
                ,CGSizeMake(_collectionView.frame.size.width, _collectionView.frame.size.height - diff)
            };
            
            self.boardView.frame = CGRectMake(.0f, .0f, self.view.frame.size.width, _sliderMinVertical);
            self.boardView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void) firedListClose:(UITapGestureRecognizer *) tapGestureRecognizer
{
    const CGFloat verticalMax = _sliderMaxVertical - _toolBarView.frame.size.height * .5f;
        // ドラッグできる下限
    
    CGPoint center = CGPointMake(_toolBarView.center.x , _sliderMaxVertical - _toolBarView.frame.size.height * .5f );
    center.y = MAX(center.y, _sliderMinVertical - _toolBarView.frame.size.height * .5f );
    center.y = MIN(center.y, verticalMax );
    
    __block CGFloat diff = .0f;
    [UIView animateWithDuration:.25f delay:.0f options:0 animations:^{
        _toolBarView.center = center;
        diff = CGRectGetMaxY(_toolBarView.frame) - _collectionView.frame.origin.y;
        
        _collectionView.frame = (CGRect){  CGPointMake(_collectionView.frame.origin.x, _collectionView.frame.origin.y + diff)
            ,CGSizeMake(_collectionView.frame.size.width, _collectionView.frame.size.height /*- diff*/)
        };
        
        self.boardView.frame = CGRectMake(.0f, .0f, self.view.frame.size.width, _sliderMaxVertical);
        self.boardView.alpha = .0f;
    } completion:^(BOOL finished) {
        _collectionView.frame = (CGRect){  CGPointMake(_collectionView.frame.origin.x, _collectionView.frame.origin.y)
            ,CGSizeMake(_collectionView.frame.size.width, _collectionView.frame.size.height - diff)
        };
        [self.boardView removeFromSuperview];
    }];
}

- (void) updateBoard
{
    self.boardView.frame = CGRectMake(.0f, .0f, self.view.frame.size.width, _collectionView.frame.origin.y /*- _toolBarView.frame.size.height*/ );
    self.boardView.alpha = 1.0f - self.boardView.frame.size.height / (_sliderMaxVertical /*- _toolBarView.frame.size.height*/);
    
    NSLog(@"self.boardView.alpha=%@",@(self.boardView.alpha));
    
    if (self.boardView.superview != self.view) {
        [self.view insertSubview:self.boardView belowSubview:_toolBarView];
    }
}

- (IBAction)firedPan:(UIPanGestureRecognizer *)panGestureRecogninzer
{
    NSLog(@"firedPanidsender: call");

    CGPoint translation = [panGestureRecogninzer translationInView:self.view];
    
    const CGFloat verticalMax = _sliderMaxVertical - _toolBarView.frame.size.height * .5f;
        // ドラッグできる下限
    
    CGPoint center = CGPointMake(_toolBarView.center.x , _toolBarView.center.y + translation.y);
    center.y = MAX(center.y, _sliderMinVertical - _toolBarView.frame.size.height * .5f );
    center.y = MIN(center.y, verticalMax );
    
    
    _toolBarView.center = center;

    // ドラッグ位置リセットを判断する
    if( center.y < verticalMax ){
        [panGestureRecogninzer setTranslation:CGPointZero inView:self.view];
    }
    
    CGFloat diff = CGRectGetMaxY(_toolBarView.frame) - _collectionView.frame.origin.y;
    _collectionView.frame = (CGRect){  CGPointMake(_collectionView.frame.origin.x, _collectionView.frame.origin.y + diff)
                                      ,CGSizeMake(_collectionView.frame.size.width, _collectionView.frame.size.height - diff)
                                    };
    
    [self updateBoard];
        // boardの更新
    
    switch (panGestureRecogninzer.state) {
        case UIGestureRecognizerStateEnded:
            [self startTransitionWithithVelocity:[panGestureRecogninzer velocityInView:self.view]];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self startTransitionWithithVelocity:CGPointZero];
            break;
        default:
            break;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if( _contentOffset != nil ){
        *targetContentOffset = scrollView.contentOffset;
        [self startTransitionWithithVelocity:CGPointMake(velocity.x, -velocity.y)];
    }
    _contentOffset = nil;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"location=%@",[NSValue valueWithCGPoint:location ]);
    if( scrollView.decelerating != YES ){
        CGPoint location = [scrollView.panGestureRecognizer locationInView:self.view];
        static BOOL _skipUpdate = NO;
        if( location.y < _collectionView.frame.origin.y ){
    //        NSLog(@"画面外に移動");
            
            if( _contentOffset == nil ){
                _contentOffset = [NSValue valueWithCGPoint:scrollView.contentOffset];
            }

    //        NSLog(@"1) _collectionView.frame=%@",[NSValue valueWithCGRect:_collectionView.frame]);
            
            location.y = MAX(location.y, _sliderMinVertical);
            location.y = MIN(location.y, _sliderMaxVertical);

//            NSLog(@"location=%@",[NSValue valueWithCGPoint:location] );
            
            
            CGFloat diff = location.y - _collectionView.frame.origin.y;
            
            _collectionView.frame = (CGRect){ CGPointMake(_collectionView.frame.origin.x, _collectionView.frame.origin.y + diff)
                                             ,CGSizeMake(_collectionView.frame.size.width, _collectionView.frame.size.height - diff)
                                            };
            
            _toolBarView.frame = (CGRect){CGPointMake(_toolBarView.frame.origin.x , _collectionView.frame.origin.y - _toolBarView.frame.size.height )  ,_toolBarView.frame.size};
            
            [self updateBoard];
                // boardの更新
            
            _skipUpdate = YES;
            [scrollView setContentOffset:[_contentOffset CGPointValue] animated:NO];
            _skipUpdate = NO;
        }
    }
}

@end
