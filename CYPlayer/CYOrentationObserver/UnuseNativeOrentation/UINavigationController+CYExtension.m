//
//  UINavigationController+CYExtension.m
//  CYVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/8.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "UINavigationController+CYExtension.h"

#import <objc/message.h>

@implementation UINavigationController (CYExtension)

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

@end
