//
//  ShowPickerView.h
//  BaishitongClient
//
//  Created by 高磊 on 15/8/11.
//  Copyright (c) 2015年 高磊. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShowPickerViewDelegate <NSObject>

- (void)showPickerViewDone:(NSString *)chooseTitle chooseId:(NSString *)chooseId;

@end

@interface ShowPickerView : UIView

@property (nonatomic,weak)id <ShowPickerViewDelegate>delegate;


/**
 展示选择器
 */
- (void)showPicker;


/**
 隐藏展示
 */
- (void)hiddenPicker;

@end
