//
//  Vectors.m
//  GigRadio
//
//  Created by Michael Forrest on 17/07/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

#import "Vectors.h"

@implementation Vectors
+(void)drawGigRadioLogo{
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
    //// Group
    {
        //// Bezier 2 Drawing
        UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
        [bezier2Path moveToPoint: CGPointMake(59.11, 20.44)];
        [bezier2Path addCurveToPoint: CGPointMake(59.11, 48.48) controlPoint1: CGPointMake(51.3, 28.19) controlPoint2: CGPointMake(51.3, 40.74)];
        [bezier2Path addCurveToPoint: CGPointMake(87.39, 48.48) controlPoint1: CGPointMake(66.92, 56.23) controlPoint2: CGPointMake(79.58, 56.23)];
        [bezier2Path addCurveToPoint: CGPointMake(87.39, 20.44) controlPoint1: CGPointMake(95.2, 40.74) controlPoint2: CGPointMake(95.2, 28.19)];
        [bezier2Path addCurveToPoint: CGPointMake(59.11, 20.44) controlPoint1: CGPointMake(79.58, 12.7) controlPoint2: CGPointMake(66.92, 12.7)];
        [bezier2Path closePath];
        [bezier2Path moveToPoint: CGPointMake(74.25, 1)];
        [bezier2Path addCurveToPoint: CGPointMake(106.75, 32.23) controlPoint1: CGPointMake(91.55, 1.39) controlPoint2: CGPointMake(104.52, 9.75)];
        [bezier2Path addCurveToPoint: CGPointMake(74.25, 115.51) controlPoint1: CGPointMake(108.98, 54.72) controlPoint2: CGPointMake(74.25, 115.51)];
        [bezier2Path addCurveToPoint: CGPointMake(40.25, 32.23) controlPoint1: CGPointMake(74.25, 115.51) controlPoint2: CGPointMake(37.27, 53.91)];
        [bezier2Path addCurveToPoint: CGPointMake(74.25, 1) controlPoint1: CGPointMake(43.23, 10.55) controlPoint2: CGPointMake(56.95, 0.62)];
        [bezier2Path closePath];
        [color setFill];
        [bezier2Path fill];
        
        
        //// Bezier Drawing
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint: CGPointMake(50.75, 88.49)];
        [bezierPath addLineToPoint: CGPointMake(45.25, 88.49)];
        [bezierPath addLineToPoint: CGPointMake(42.25, 92.95)];
        [bezierPath addLineToPoint: CGPointMake(35, 76.34)];
        [bezierPath addLineToPoint: CGPointMake(28.25, 92.95)];
        [bezierPath addLineToPoint: CGPointMake(23, 82.79)];
        [bezierPath addLineToPoint: CGPointMake(20, 87.74)];
        [bezierPath addLineToPoint: CGPointMake(9, 87.74)];
        bezierPath.miterLimit = 5;
        
        bezierPath.lineCapStyle = kCGLineCapRound;
        
        [color setStroke];
        bezierPath.lineWidth = 4.5;
        [bezierPath stroke];
        
        
        //// Bezier 3 Drawing
        UIBezierPath* bezier3Path = [UIBezierPath bezierPath];
        [bezier3Path moveToPoint: CGPointMake(96.25, 88.49)];
        [bezier3Path addLineToPoint: CGPointMake(101.75, 88.49)];
        [bezier3Path addLineToPoint: CGPointMake(104.25, 92.95)];
        [bezier3Path addLineToPoint: CGPointMake(112, 76.34)];
        [bezier3Path addLineToPoint: CGPointMake(118.75, 92.95)];
        [bezier3Path addLineToPoint: CGPointMake(124, 82.79)];
        [bezier3Path addLineToPoint: CGPointMake(127, 87.74)];
        [bezier3Path addLineToPoint: CGPointMake(138, 87.74)];
        bezier3Path.lineCapStyle = kCGLineCapRound;
        
        [color setStroke];
        bezier3Path.lineWidth = 4.5;
        [bezier3Path stroke];
    }

}
@end
