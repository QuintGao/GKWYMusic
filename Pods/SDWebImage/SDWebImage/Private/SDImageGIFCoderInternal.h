/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

<<<<<<< HEAD:Pods/SDWebImage/SDWebImage/Core/SDWebImageOperation.m
#import "SDWebImageOperation.h"

/// NSOperation conform to `SDWebImageOperation`.
@implementation NSOperation (SDWebImageOperation)
=======
#import "SDWebImageCompat.h"
#import "SDImageGIFCoder.h"

@interface SDImageGIFCoder ()

- (float)sd_frameDurationAtIndex:(NSUInteger)index source:(nonnull CGImageSourceRef)source;
>>>>>>> 07b7186c5d82c1df0c14d5b997343580b444b236:Pods/SDWebImage/SDWebImage/Private/SDImageGIFCoderInternal.h

@end
