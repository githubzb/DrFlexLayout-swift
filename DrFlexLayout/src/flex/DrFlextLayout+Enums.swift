//
//  DrFlextLayout+Enums.swift
//  DrFlexLayout
//
//  Created by dr.box on 2021/10/18.
//

import Foundation

extension DrFlex.Direction {
    var yogaValue: YGFlexDirection {
        switch self {
        case .column:        return YGFlexDirection.column
        case .columnReverse: return YGFlexDirection.columnReverse
        case .row:           return YGFlexDirection.row
        case .rowReverse:    return YGFlexDirection.rowReverse
        }
    }
}

extension DrFlex.JustifyContent {
    var yogaValue: YGJustify {
        switch self {
        case .start:        return YGJustify.flexStart
        case .center:       return YGJustify.center
        case .end:          return YGJustify.flexEnd
        case .spaceBetween: return YGJustify.spaceBetween
        case .spaceAround:  return YGJustify.spaceAround
        case .spaceEvenly:  return YGJustify.spaceEvenly
        }
    }
}

extension DrFlex.AlignContent {
    var yogaValue: YGAlign {
        switch self {
        case .stretch:      return YGAlign.stretch
        case .start:        return YGAlign.flexStart
        case .center:       return YGAlign.center
        case .end:          return YGAlign.flexEnd
        case .spaceBetween: return YGAlign.spaceBetween
        case .spaceAround:  return YGAlign.spaceAround
        }
    }
}

extension DrFlex.AlignItems {
    var yogaValue: YGAlign {
        switch self {
        case .stretch:      return YGAlign.stretch
        case .start:        return YGAlign.flexStart
        case .center:       return YGAlign.center
        case .end:          return YGAlign.flexEnd
        case .baseline:     return YGAlign.baseline
        }
    }
}

extension DrFlex.AlignSelf {
    var yogaValue: YGAlign {
        switch self {
        case .auto:         return YGAlign.auto
        case .stretch:      return YGAlign.stretch
        case .start:        return YGAlign.flexStart
        case .center:       return YGAlign.center
        case .end:          return YGAlign.flexEnd
        case .baseline:     return YGAlign.baseline
        }
    }
}

extension DrFlex.Wrap {
    var yogaValue: YGWrap {
        switch self {
        case .noWrap:      return YGWrap.noWrap
        case .wrap:        return YGWrap.wrap
        case .wrapReverse: return YGWrap.wrapReverse
        }
    }
}

extension DrFlex.Position {
    var yogaValue: YGPositionType {
        switch self {
        case .relative: return YGPositionType.relative
        case .absolute: return YGPositionType.absolute
        }
    }
}

extension DrFlex.LayoutDirection {
    var yogaValue: YGDirection {
        switch self {
        case .ltr: return YGDirection.LTR
        case .rtl: return YGDirection.RTL
        default:   return YGDirection.inherit
        }
    }
}

extension DrFlex.Display {
    var yogaValue: YGDisplay {
        switch self {
        case .flex: return YGDisplay.flex
        case .none: return YGDisplay.none
        }
    }
}
