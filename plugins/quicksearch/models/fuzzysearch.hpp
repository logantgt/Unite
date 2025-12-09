#pragma once

#include <QString>
#include <QVector>

namespace quicksearch::models {

    struct FuzzyMatch {
        double score;        // Relevance score (0.0 to 1.0, higher is better)
        bool isMatch;        // Whether this is a match at all
        QVector<int> positions; // Character positions that matched

        FuzzyMatch() : score(0.0), isMatch(false) {}
        FuzzyMatch(double s, const QVector<int>& pos)
            : score(s), isMatch(s > 0.0), positions(pos) {}
    };

    class FuzzySearch {
    public:
        // Perform fuzzy matching between query and target string
        // Returns a FuzzyMatch with score and match positions
        static FuzzyMatch match(const QString& query, const QString& target);

        // Calculate score for a query against a target string
        // Considers:
        // - Case-insensitive substring matching
        // - Prefix matching bonus
        // - Consecutive character bonus
        // - Match position (earlier matches score higher)
        static double calculateScore(const QString& query, const QString& target);

    private:
        // Helper to find all matching positions
        static QVector<int> findMatchPositions(const QString& query, const QString& target);

        // Calculate bonus for consecutive matches
        static double calculateConsecutiveBonus(const QVector<int>& positions);

        // Calculate bonus for prefix matching
        static double calculatePrefixBonus(const QString& query, const QString& target);
    };

} // namespace quicksearch::models
