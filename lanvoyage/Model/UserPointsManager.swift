//
//  UserPointsManager.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/16/25.
//

import Foundation
import SwiftUI

public class UserPointsManager {
    public func getPoints() -> Int {
        return UserDefaults.standard.integer(forKey: "points")
    }
    
    public func addPoints(_ points: Int) {
        UserDefaults.standard.set(getPoints() + points, forKey: "points")
    }
    
    public func deductPoints(_ points: Int) {
        UserDefaults.standard.set(max(0, getPoints() - points), forKey: "points")
    }

    private func levelThresholds() -> [Int] {
        // Procedural: gaps feel like 10 → 20 → 50 → 100 … (roughly exponential),
        // but not strictly geometric/arithmetic. All thresholds are multiples of 10
        // and the final threshold is exactly 10,000 at level 20.
        let levels = 20
        let maxPoints = 10000
        let growth = 1.22 // tune to control how quickly gaps grow

        // 1) Build increasing weights
        var weights: [Double] = []
        for i in 0..<levels { weights.append(pow(growth, Double(i))) }
        let sumW = weights.reduce(0, +)

        // 2) Map to point increments, rounded to nearest 10, min 10
        var increments: [Int] = weights.map { w in
            var v = Int(round((w / sumW) * Double(maxPoints) / 10.0)) * 10
            if v < 10 { v = 10 }
            return v
        }

        // 3) Enforce non-decreasing increments (visual smoothness)
        for i in 1..<increments.count {
            if increments[i] < increments[i - 1] { increments[i] = increments[i - 1] }
        }

        // 4) Fix total to exactly 10,000 by adjusting the last increment
        var total = increments.reduce(0, +)
        let diff = maxPoints - total
        if diff != 0 {
            increments[increments.count - 1] = max(10, increments.last! + diff)
        }

        // 5) Build cumulative thresholds
        var thresholds: [Int] = []
        var sum = 0
        for inc in increments {
            sum += inc
            thresholds.append(sum)
        }

        // Safety: ensure last threshold is exactly 10,000
        if let last = thresholds.last, last != maxPoints {
            let adjust = maxPoints - last
            thresholds[thresholds.count - 1] += adjust
        }
        return thresholds
    }
    
    public func getLevel() -> Int {
        let points = getPoints()
        let thresholds = levelThresholds()
        for (index, threshold) in thresholds.enumerated() {
            if points < threshold { return max(1, index + 1) }
        }
        return thresholds.count
    }

    /// Points needed to reach the next level. Returns 0 if at max level.
    public func pointsToNextLevel() -> Int {
        let points = getPoints()
        let thresholds = levelThresholds()
        for threshold in thresholds {
            if points < threshold { return max(0, threshold - points) }
        }
        return 0 // already at or above max level
    }

    /// Progress percentage within the current level band based on previous/next thresholds.
    /// Returns a value in [0, 100]. If at max level, returns 100.
    public func levelProgressPercent() -> Double {
        let points = getPoints()
        let thresholds = levelThresholds()
        var prev = 0
        for threshold in thresholds {
            if points < threshold {
                let span = max(1, threshold - prev)
                let progress = Double(points - prev) / Double(span)
                return min(100.0, max(0.0, progress * 100.0))
            }
            prev = threshold
        }
        return 100.0
    }

    /// Returns (prevThreshold, nextThreshold). If at max level, nextThreshold == prevThreshold == 10000.
    public func currentLevelBounds() -> (prev: Int, next: Int) {
        let points = getPoints()
        let thresholds = levelThresholds()
        var prev = 0
        for threshold in thresholds {
            if points < threshold { return (prev, threshold) }
            prev = threshold
        }
        return (thresholds.last ?? 10000, thresholds.last ?? 10000)
    }
}
