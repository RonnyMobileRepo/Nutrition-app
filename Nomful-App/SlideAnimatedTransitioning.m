//
//  SlideAnimatedTransitioning.m
//  RealDietitian
//
//  Created by Sean Crowe on 4/12/15.
//  Copyright (c) 2015 Real Dietitian, inc. All rights reserved.
//

#import "SlideAnimatedTransitioning.h"

@implementation SlideAnimatedTransitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView],
    *fromView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view,
    *toView   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;
    
    CGFloat width = containerView.frame.size.width;
    
    CGRect offsetLeft = fromView.frame; offsetLeft.origin.x = -width/3;
    
    CGRect offscreenRight = toView.frame; offscreenRight.origin.x = width;
    toView.frame = offscreenRight;
    toView.layer.shadowRadius = 5;
    toView.layer.shadowOpacity = 0.4;
    
    [containerView addSubview:toView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        toView.frame = fromView.frame;
        
        fromView.frame = offsetLeft;
        fromView.layer.opacity = 0.9;
    } completion:^(BOOL finished) {
        fromView.layer.opacity = 1;
        toView.layer.shadowOpacity = 0;
        // when cancelling or completing the animation, ios simulator seems to sometimes flash black backgrounds during the animation. on devices, this doesn't seem to happen though.
        // containerView.backgroundColor = [UIColor whiteColor];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.2;
}

@end
