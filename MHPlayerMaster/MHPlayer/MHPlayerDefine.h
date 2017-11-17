//
//  MHPlayerDefine.h
//  MHPlayerMaster
//
//  Created by 马浩 on 2017/11/17.
//  Copyright © 2017年 HuZhang. All rights reserved.
//

#ifndef MHPlayerDefine_h
#define MHPlayerDefine_h

#define Screen_WIDTH [UIScreen mainScreen].bounds.size.width
#define Screen_HEIGTH [UIScreen mainScreen].bounds.size.height
#define Width(i) i*(Screen_WIDTH/375)
#define FONT(x)        [UIFont systemFontOfSize:Width(x)]
#define kControllTimerTime 2.5


#import "UINavigationController+ZFPlayerRotation.h"
#import "UITabBarController+ZFPlayerRotation.h"
#import "UIViewController+ZFPlayerRotation.h"
#import "UIView+SDAutoLayout.h"


#endif /* MHPlayerDefine_h */
