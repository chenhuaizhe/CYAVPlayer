//
//  ControlView.h
//  CCYYAVPlayer
//
//  Created by CY on 15/11/26.
//  Copyright © 2015年 chenyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
//----------------------------- 控制控件视图 -----------------------------------

@interface ControlView : UIView

@property (nonatomic,assign) CGFloat videoDuration;
@property (nonatomic,assign) BOOL isPlaying;
@property (nonatomic,assign) BOOL isControlEnable;

-(void)showWithClickHandle:(void (^)(NSInteger tag))clickHandle slideHandle:(void (^)(CGFloat interval,BOOL isFinished))slideHandle;

-(void)setSlideValue:(CGFloat)value;

@end
