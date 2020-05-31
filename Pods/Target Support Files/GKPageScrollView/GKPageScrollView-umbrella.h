#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "GKPageDefine.h"
#import "GKPageListContainerView.h"
#import "GKPageScrollView.h"
#import "GKPageSmoothView.h"
#import "GKPageTableView.h"

FOUNDATION_EXPORT double GKPageScrollViewVersionNumber;
FOUNDATION_EXPORT const unsigned char GKPageScrollViewVersionString[];

