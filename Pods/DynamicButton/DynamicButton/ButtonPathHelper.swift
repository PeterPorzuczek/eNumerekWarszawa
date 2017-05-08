/*
 * DynamicButton
 *
 * Copyright 2015-present Yannick Loriot.
 * http://yannickloriot.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import UIKit

/// Manage the line paths for each button styles.
internal class ButtonPathHelper {
  private static let F_PI_2 = CGFloat(M_PI_2)
  private static let F_PI_4 = CGFloat(M_PI_4)

  // MARK: - Representing the Button as Drawing Lines

  private class func createCircleWithRadius(center: CGPoint, radius: CGFloat) -> CGPathRef {
    let path = CGPathCreateMutable()

    CGPathMoveToPoint(path, nil, center.x + radius, center.y)
    CGPathAddArc(path, nil, center.x, center.y, radius, 0, 2 * CGFloat(M_PI), false)

    return path
  }

  private class func createLineWithRadius(center: CGPoint, radius: CGFloat, angle: CGFloat, offset: CGPoint = CGPointZero) -> CGPathRef {
    let path = CGPathCreateMutable()

    let c = cos(angle)
    let s = sin(angle)

    CGPathMoveToPoint(path, nil, center.x + offset.x + radius * c, center.y + offset.y + radius * s)
    CGPathAddLineToPoint(path, nil, center.x + offset.x - radius * c, center.y + offset.y - radius * s)

    return path
  }

  private class func createLineFromPoint(start: CGPoint, end: CGPoint, offset: CGPoint = CGPointZero) -> CGPathRef {
    let path = CGPathCreateMutable()

    CGPathMoveToPoint(path, nil, offset.x + start.x, offset.y + start.y)
    CGPathAddLineToPoint(path, nil, offset.x + end.x, offset.y + end.y)

    return path
  }

  private class func gravityPointOffsetFromCenter(center: CGPoint, a: CGPoint, b: CGPoint, c: CGPoint) -> CGPoint {
    let gravityCenter  = CGPoint(x: (a.x + b.x + c.x) / 3, y: (a.y + b.y + c.y) / 3)

    return CGPoint(x: center.x - gravityCenter.x, y: center.y - gravityCenter.y)
  }

  /**
  Creates and returns the paths corresponding to the given style with its space constraints.
  
  - parameter style: The style to draw.
  - parameter size: The size in which the path have to be drawn.
  - parameter offset: The offset (x, y) where the drawing whould start.
  - parameter lineWidth: The stroke's line width.
  - returns The path for each available line layer.
  */
  class func pathForButtonWithStyle(style: DynamicButton.Style, withSize size: CGFloat, offset: CGPoint, lineWidth: CGFloat) -> (line1: CGPathRef, line2: CGPathRef, line3: CGPathRef, line4: CGPathRef) {
    let center = CGPoint(x: offset.x + size / 2, y: offset.y + size / 2)

    let halfSize  = size / 2
    let thirdSize = size / 3
    let sixthSize = size / 6

    let line1Path: CGPathRef
    let line2Path: CGPathRef
    let line3Path: CGPathRef
    let line4Path: CGPathRef

    switch style {
    case .ArrowDown:
      line1Path = ButtonPathHelper.createLineFromPoint(CGPointMake(center.x, offset.y), end: CGPointMake(center.x, offset.y + size - lineWidth))
      line2Path = ButtonPathHelper.createLineFromPoint(CGPointMake(center.x, offset.y + size - lineWidth), end: CGPoint(x: center.x - size / 3.2, y: offset.y + size - size / 3.2))
      line3Path = ButtonPathHelper.createLineFromPoint(CGPointMake(center.x, offset.y + size - lineWidth), end: CGPoint(x: center.x + size / 3.2, y: offset.y + size - size / 3.2))
      line4Path = line1Path
    case .ArrowLeft:
      line1Path = ButtonPathHelper.createLineFromPoint(CGPointMake(offset.x + lineWidth, center.y), end: CGPointMake(offset.x + size, center.y))
      line2Path = ButtonPathHelper.createLineFromPoint(CGPointMake(offset.x + lineWidth, center.y), end: CGPoint(x: offset.x + size / 3.2, y: center.y + size / 3.2))
      line3Path = ButtonPathHelper.createLineFromPoint(CGPointMake(offset.x + lineWidth, center.y), end: CGPoint(x: offset.x + size / 3.2, y: center.y - size / 3.2))
      line4Path = line1Path
    case .ArrowRight:
      line1Path = ButtonPathHelper.createLineFromPoint(CGPointMake(offset.x, center.y), end: CGPointMake(offset.x + size - lineWidth, center.y))
      line2Path = ButtonPathHelper.createLineFromPoint(CGPointMake(offset.x + size - lineWidth, center.y), end: CGPoint(x: offset.x + size - size / 3.2, y: center.y + size / 3.2))
      line3Path = ButtonPathHelper.createLineFromPoint(CGPointMake(offset.x + size - lineWidth, center.y), end: CGPoint(x: offset.x + size - size / 3.2, y: center.y - size / 3.2))
      line4Path = line1Path
    case .ArrowUp:
      line1Path = ButtonPathHelper.createLineFromPoint(CGPointMake(center.x, offset.y + lineWidth), end: CGPointMake(center.x, offset.y + size))
      line2Path = ButtonPathHelper.createLineFromPoint(CGPointMake(center.x, offset.y + lineWidth), end: CGPoint(x: center.x - size / 3.2, y: offset.y + size / 3.2))
      line3Path = ButtonPathHelper.createLineFromPoint(CGPointMake(center.x, offset.y + lineWidth), end: CGPoint(x: center.x + size / 3.2, y: offset.y + size / 3.2))
      line4Path = line1Path
    case .CaretDown:
      let a = CGPoint(x: center.x, y: center.y + sixthSize)
      let b = CGPoint(x: center.x - thirdSize, y: center.y - sixthSize)
      let c = CGPoint(x: center.x + thirdSize, y: center.y - sixthSize)

      let offsetFromCenter = gravityPointOffsetFromCenter(center, a: a, b: b, c: c)

      line1Path = ButtonPathHelper.createLineFromPoint(a, end: b, offset: offsetFromCenter)
      line2Path = line1Path
      line3Path = ButtonPathHelper.createLineFromPoint(a, end: c, offset: offsetFromCenter)
      line4Path = line3Path
    case .CaretLeft:
      let a = CGPoint(x: center.x - sixthSize, y: center.y)
      let b = CGPoint(x: center.x + sixthSize, y: center.y + thirdSize)
      let c = CGPoint(x: center.x + sixthSize, y: center.y - thirdSize)

      let offsetFromCenter = gravityPointOffsetFromCenter(center, a: a, b: b, c: c)

      line1Path = ButtonPathHelper.createLineFromPoint(a, end: b, offset: offsetFromCenter)
      line2Path = line1Path
      line3Path = ButtonPathHelper.createLineFromPoint(a, end: c, offset: offsetFromCenter)
      line4Path = line3Path
    case .CaretRight:
      let a = CGPoint(x: center.x + sixthSize, y: center.y)
      let b = CGPoint(x: center.x - sixthSize, y: center.y + thirdSize)
      let c = CGPoint(x: center.x - sixthSize, y: center.y - thirdSize)

      let offsetFromCenter = gravityPointOffsetFromCenter(center, a: a, b: b, c: c)

      line1Path = ButtonPathHelper.createLineFromPoint(a, end: b, offset: offsetFromCenter)
      line2Path = line1Path
      line3Path = ButtonPathHelper.createLineFromPoint(a, end: c, offset: offsetFromCenter)
      line4Path = line3Path
    case .CaretUp:
      let a = CGPoint(x: center.x, y: center.y - sixthSize)
      let b = CGPoint(x: center.x - thirdSize, y: center.y + sixthSize)
      let c = CGPoint(x: center.x + thirdSize, y: center.y + sixthSize)

      let offsetFromCenter = gravityPointOffsetFromCenter(center, a: a, b: b, c: c)

      line1Path = ButtonPathHelper.createLineFromPoint(a, end: b, offset: offsetFromCenter)
      line2Path = line1Path
      line3Path = ButtonPathHelper.createLineFromPoint(a, end: c, offset: offsetFromCenter)
      line4Path = line3Path
    case .CheckMark:
      line1Path = ButtonPathHelper.createLineFromPoint(CGPoint(x: offset.x + size / 4, y: offset.y + size / 4), end: CGPoint(x: center.x, y: center.y), offset: CGPointMake(-size / 8, size / 4))
      line2Path = line1Path
      line3Path = ButtonPathHelper.createLineFromPoint(CGPoint(x: center.x, y: center.y), end: CGPoint(x: offset.x + size, y: offset.y), offset: CGPointMake(-size / 8, size / 4))
      line4Path = line3Path
    case .CircleClose:
      line1Path = ButtonPathHelper.createLineWithRadius(center, radius: size / 3.2, angle: F_PI_4)
      line2Path = line1Path
      line3Path = ButtonPathHelper.createLineWithRadius(center, radius: size / 3.2, angle: -F_PI_4)
      line4Path = ButtonPathHelper.createCircleWithRadius(center, radius: halfSize - lineWidth)
    case .CirclePlus:
      line1Path = ButtonPathHelper.createLineWithRadius(center, radius: size / 3.2, angle: F_PI_2)
      line2Path = line1Path
      line3Path = ButtonPathHelper.createLineWithRadius(center, radius: size / 3.2, angle: 0)
      line4Path = ButtonPathHelper.createCircleWithRadius(center, radius: halfSize - lineWidth)
    case .Close:
      line1Path = ButtonPathHelper.createLineWithRadius(center, radius: halfSize, angle: F_PI_4)
      line2Path = line1Path
      line3Path = ButtonPathHelper.createLineWithRadius(center, radius: halfSize, angle: -F_PI_4)
      line4Path = line3Path
    case .Dot:
      line1Path = UIBezierPath(roundedRect: CGRect(x: center.x, y: center.y, width: 1, height: 1), cornerRadius: halfSize).CGPath
      line2Path = line1Path
      line3Path = line1Path
      line4Path = line1Path
    case .Download:
      line1Path = ButtonPathHelper.createLineFromPoint(CGPointMake(center.x, offset.y), end: CGPointMake(center.x, offset.y + size - lineWidth))
      line2Path = ButtonPathHelper.createLineFromPoint(CGPointMake(center.x, offset.y + size - lineWidth), end: CGPoint(x: center.x - size / 3.2, y: offset.y + size - size / 3.2))
      line3Path = ButtonPathHelper.createLineFromPoint(CGPointMake(center.x, offset.y + size - lineWidth), end: CGPoint(x: center.x + size / 3.2, y: offset.y + size - size / 3.2))
      line4Path = ButtonPathHelper.createLineFromPoint(CGPointMake(center.x - size / 3.2, offset.y + size - lineWidth), end: CGPoint(x: center.x + size / 3.2, y: offset.y + size - lineWidth))
    case .FastForward:
      let a = CGPoint(x: center.x + sixthSize, y: center.y)
      let b = CGPoint(x: center.x - sixthSize, y: center.y + thirdSize)
      let c = CGPoint(x: center.x - sixthSize, y: center.y - thirdSize)

      let ofc = gravityPointOffsetFromCenter(center, a: a, b: b, c: c)

      line1Path = ButtonPathHelper.createLineFromPoint(a, end: b, offset: CGPoint(x: ofc.x + sixthSize, y: ofc.y))
      line2Path = ButtonPathHelper.createLineFromPoint(a, end: b, offset: CGPoint(x: ofc.x - sixthSize, y: ofc.y))
      line3Path = ButtonPathHelper.createLineFromPoint(a, end: c, offset: CGPoint(x: ofc.x + sixthSize, y: ofc.y))
      line4Path = ButtonPathHelper.createLineFromPoint(a, end: c, offset: CGPoint(x: ofc.x - sixthSize, y: ofc.y))
    case .Hamburger:
      line1Path = ButtonPathHelper.createLineWithRadius(center, radius: halfSize, angle: 0)
      line2Path = ButtonPathHelper.createLineWithRadius(center, radius: halfSize, angle: 0, offset: CGPointMake(0, size / -3.2))
      line3Path = ButtonPathHelper.createLineWithRadius(center, radius: halfSize, angle: 0, offset: CGPointMake(0, size / 3.2))
      line4Path = line1Path
    case .HorizontalLine:
      line1Path = ButtonPathHelper.createLineWithRadius(center, radius: halfSize, angle: 0)
      line2Path = line1Path
      line3Path = line1Path
      line4Path = line1Path
    case .None:
      line1Path = UIBezierPath(rect: CGRect(x: center.x - size, y: center.y - size, width: 0, height: 0)).CGPath
      line2Path = UIBezierPath(rect: CGRect(x: center.x + size, y: center.y - size, width: 0, height: 0)).CGPath
      line3Path = UIBezierPath(rect: CGRect(x: center.x - size, y: center.y + size, width: 0, height: 0)).CGPath
      line4Path = UIBezierPath(rect: CGRect(x: center.x + size, y: center.y + size, width: 0, height: 0)).CGPath
    case .Pause:
      line1Path = ButtonPathHelper.createLineWithRadius(center, radius: halfSize, angle: F_PI_2, offset: CGPoint(x: size / -4, y: 0))
      line2Path = line1Path
      line3Path = ButtonPathHelper.createLineWithRadius(center, radius: halfSize, angle: F_PI_2, offset: CGPoint(x: size / 4, y: 0))
      line4Path = line3Path
    case .Play:
      let a = CGPoint(x: center.x - thirdSize, y: center.y - thirdSize)
      let b = CGPoint(x: center.x - thirdSize, y: center.y + thirdSize)
      let c = CGPoint(x: center.x + sixthSize, y: center.y)

      let ofc = gravityPointOffsetFromCenter(center, a: a, b: b, c: c)

      line1Path = ButtonPathHelper.createLineFromPoint(a, end: b, offset: ofc)
      line2Path = ButtonPathHelper.createLineFromPoint(b, end: c, offset: ofc)
      line3Path = ButtonPathHelper.createLineFromPoint(a, end: c, offset: ofc)
      line4Path = line1Path
    case .Plus:
      line1Path = ButtonPathHelper.createLineWithRadius(center, radius: halfSize, angle: F_PI_2)
      line2Path = line1Path
      line3Path = ButtonPathHelper.createLineWithRadius(center, radius: halfSize, angle: 0)
      line4Path = line3Path
    case .Rewind:
      let a = CGPoint(x: center.x - sixthSize, y: center.y)
      let b = CGPoint(x: center.x + sixthSize, y: center.y + thirdSize)
      let c = CGPoint(x: center.x + sixthSize, y: center.y - thirdSize)

      let ofc = gravityPointOffsetFromCenter(center, a: a, b: b, c: c)

      line1Path = ButtonPathHelper.createLineFromPoint(a, end: b, offset: CGPoint(x: ofc.x - sixthSize, y: ofc.y))
      line2Path = ButtonPathHelper.createLineFromPoint(a, end: b, offset: CGPoint(x: ofc.x + sixthSize, y: ofc.y))
      line3Path = ButtonPathHelper.createLineFromPoint(a, end: c, offset: CGPoint(x: ofc.x - sixthSize, y: ofc.y))
      line4Path = ButtonPathHelper.createLineFromPoint(a, end: c, offset: CGPoint(x: ofc.x + sixthSize, y: ofc.y))
    case .Stop:
      let a = CGPoint(x: center.x - thirdSize, y: center.y - thirdSize)
      let b = CGPoint(x: center.x - thirdSize, y: center.y + thirdSize)
      let c = CGPoint(x: center.x + thirdSize, y: center.y + thirdSize)
      let d = CGPoint(x: center.x + thirdSize, y: center.y - thirdSize)

      line1Path = ButtonPathHelper.createLineFromPoint(a, end: b)
      line2Path = ButtonPathHelper.createLineFromPoint(b, end: c)
      line3Path = ButtonPathHelper.createLineFromPoint(c, end: d)
      line4Path = ButtonPathHelper.createLineFromPoint(d, end: a)
    case .VerticalLine:
      line1Path = ButtonPathHelper.createLineWithRadius(center, radius: halfSize, angle: F_PI_2)
      line2Path = line1Path
      line3Path = line1Path
      line4Path = line1Path
    }

    return (line1Path, line2Path, line3Path, line4Path)
  }
}