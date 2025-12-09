#include "fuzzysearch.hpp"
#include <QRegularExpression>
#include <QtMath>

namespace quicksearch::models {

    FuzzyMatch FuzzySearch::match(const QString& query, const QString& target) {
        if (query.isEmpty()) {
            return FuzzyMatch(1.0, QVector<int>()); // Empty query matches everything
        }

        if (target.isEmpty()) {
            return FuzzyMatch(); // No match on empty target
        }

        const QString lowerQuery = query.toLower();
        const QString lowerTarget = target.toLower();

        // Find all matching positions
        QVector<int> positions = findMatchPositions(lowerQuery, lowerTarget);

        if (positions.isEmpty()) {
            return FuzzyMatch(); // No match
        }

        // Calculate base score from matching ratio
        double baseScore = static_cast<double>(positions.size()) / lowerQuery.length();

        // Apply bonuses
        double prefixBonus = calculatePrefixBonus(lowerQuery, lowerTarget);
        double consecutiveBonus = calculateConsecutiveBonus(positions);

        // Position bonus (earlier matches are better)
        double positionBonus = 0.0;
        if (!positions.isEmpty()) {
            double avgPosition = 0.0;
            for (int pos : positions) {
                avgPosition += pos;
            }
            avgPosition /= positions.size();
            positionBonus = 1.0 - (avgPosition / lowerTarget.length());
        }

        // Weight the bonuses
        double finalScore = baseScore * 0.4 +
                           prefixBonus * 0.3 +
                           consecutiveBonus * 0.2 +
                           positionBonus * 0.1;

        // Exact match bonus
        if (lowerQuery == lowerTarget) {
            finalScore = 1.0;
        }

        // Clamp to [0, 1]
        finalScore = qMax(0.0, qMin(1.0, finalScore));

        return FuzzyMatch(finalScore, positions);
    }

    double FuzzySearch::calculateScore(const QString& query, const QString& target) {
        return match(query, target).score;
    }

    QVector<int> FuzzySearch::findMatchPositions(const QString& query, const QString& target) {
        QVector<int> positions;

        if (query.isEmpty() || target.isEmpty()) {
            return positions;
        }

        int queryIdx = 0;
        int targetIdx = 0;

        // Greedy matching: find first occurrence of each query character
        while (queryIdx < query.length() && targetIdx < target.length()) {
            if (query[queryIdx] == target[targetIdx]) {
                positions.append(targetIdx);
                queryIdx++;
            }
            targetIdx++;
        }

        // If we didn't match all query characters, it's not a valid match
        if (queryIdx < query.length()) {
            positions.clear();
        }

        return positions;
    }

    double FuzzySearch::calculateConsecutiveBonus(const QVector<int>& positions) {
        if (positions.size() <= 1) {
            return 0.0;
        }

        int consecutiveCount = 0;
        int totalGaps = 0;

        for (int i = 1; i < positions.size(); ++i) {
            int gap = positions[i] - positions[i - 1];
            if (gap == 1) {
                consecutiveCount++;
            }
            totalGaps += gap - 1;
        }

        // More consecutive matches = higher score
        double consecutiveRatio = static_cast<double>(consecutiveCount) / (positions.size() - 1);

        // Fewer gaps = higher score
        double gapPenalty = totalGaps > 0 ? 1.0 / (1.0 + totalGaps) : 1.0;

        return consecutiveRatio * 0.7 + gapPenalty * 0.3;
    }

    double FuzzySearch::calculatePrefixBonus(const QString& query, const QString& target) {
        if (target.startsWith(query)) {
            return 1.0; // Perfect prefix match
        }

        // Check for prefix match with some tolerance
        int matchCount = 0;
        int checkLength = qMin(query.length(), target.length());

        for (int i = 0; i < checkLength; ++i) {
            if (query[i] == target[i]) {
                matchCount++;
            } else {
                break; // Stop at first mismatch
            }
        }

        return static_cast<double>(matchCount) / query.length();
    }

} // namespace quicksearch::models
