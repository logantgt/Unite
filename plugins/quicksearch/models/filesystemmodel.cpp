// https://raw.githubusercontent.com/caelestia-dots/shell/refs/heads/main/plugin/src/Caelestia/Models/filesystemmodel.cpp
// Original work by soramane, caelestia-dots/shell, licensed under GPL-3.0, thank you for your hard work!

#include "filesystemmodel.hpp"
#include "fuzzysearch.hpp"

#include <qdiriterator.h>
#include <qfuturewatcher.h>
#include <qprocess.h>
#include <qtconcurrentrun.h>

namespace quicksearch::models {

    FileSystemEntry::FileSystemEntry(const QString& path, const QString& relativePath, QObject* parent)
    : QObject(parent)
    , m_fileInfo(path)
    , m_path(path)
    , m_relativePath(relativePath)
    , m_isImageInitialised(false)
    , m_mimeTypeInitialised(false)
    , m_desktopDataInitialised(false) {}

    QString FileSystemEntry::path() const {
        return m_path;
    };

    QString FileSystemEntry::relativePath() const {
        return m_relativePath;
    };

    QString FileSystemEntry::fileName() const {
        return m_fileInfo.fileName();
    };

    QString FileSystemEntry::baseName() const {
        return m_fileInfo.baseName();
    };

    QString FileSystemEntry::parentDir() const {
        return m_fileInfo.absolutePath();
    };

    QString FileSystemEntry::suffix() const {
        return m_fileInfo.completeSuffix();
    };

    qint64 FileSystemEntry::size() const {
        return m_fileInfo.size();
    };

    bool FileSystemEntry::isDir() const {
        return m_fileInfo.isDir();
    };

    bool FileSystemEntry::isImage() const {
        if (!m_isImageInitialised) {
            QImageReader reader(m_path);
            m_isImage = reader.canRead();
            m_isImageInitialised = true;
        }
        return m_isImage;
    }

    QString FileSystemEntry::mimeType() const {
        if (!m_mimeTypeInitialised) {
            const QMimeDatabase db;
            m_mimeType = db.mimeTypeForFile(m_path).name();
            m_mimeTypeInitialised = true;
        }
        return m_mimeType;
    }

    void FileSystemEntry::ensureDesktopDataLoaded() const {
        if (m_desktopDataInitialised) {
            return;
        }

        m_desktopDataInitialised = true;

        if (m_fileInfo.suffix() == "desktop") {
            m_desktopData = DesktopEntryParser::parse(m_path);
        }
    }

    bool FileSystemEntry::isDesktopEntry() const {
        ensureDesktopDataLoaded();
        return m_desktopData.has_value();
    }

    QString FileSystemEntry::name() const {
        ensureDesktopDataLoaded();
        return m_desktopData.has_value() ? m_desktopData->name : QString();
    }

    QString FileSystemEntry::genericName() const {
        ensureDesktopDataLoaded();
        return m_desktopData.has_value() ? m_desktopData->genericName : QString();
    }

    QString FileSystemEntry::comment() const {
        ensureDesktopDataLoaded();
        return m_desktopData.has_value() ? m_desktopData->comment : QString();
    }

    QString FileSystemEntry::icon() const {
        ensureDesktopDataLoaded();
        return m_desktopData.has_value() ? m_desktopData->icon : QString();
    }

    QStringList FileSystemEntry::command() const {
        ensureDesktopDataLoaded();
        return m_desktopData.has_value() ? m_desktopData->command : QStringList();
    }

    QString FileSystemEntry::execString() const {
        ensureDesktopDataLoaded();
        return m_desktopData.has_value() ? m_desktopData->execString : QString();
    }

    QStringList FileSystemEntry::categories() const {
        ensureDesktopDataLoaded();
        return m_desktopData.has_value() ? m_desktopData->categories : QStringList();
    }

    QStringList FileSystemEntry::keywords() const {
        ensureDesktopDataLoaded();
        return m_desktopData.has_value() ? m_desktopData->keywords : QStringList();
    }

    QQmlListProperty<DesktopAction> FileSystemEntry::actions() const {
        ensureDesktopDataLoaded();
        if (m_desktopData.has_value()) {
            return QQmlListProperty<DesktopAction>(
                const_cast<FileSystemEntry*>(this),
                const_cast<QList<DesktopAction*>*>(&m_desktopData->actions)
            );
        }
        static QList<DesktopAction*> empty;
        return QQmlListProperty<DesktopAction>(
            const_cast<FileSystemEntry*>(this),
            &empty
        );
    }

    QString FileSystemEntry::desktopId() const {
        ensureDesktopDataLoaded();
        return m_desktopData.has_value() ? m_desktopData->id : QString();
    }

    bool FileSystemEntry::noDisplay() const {
        ensureDesktopDataLoaded();
        return m_desktopData.has_value() ? m_desktopData->noDisplay : false;
    }

    bool FileSystemEntry::runInTerminal() const {
        ensureDesktopDataLoaded();
        return m_desktopData.has_value() ? m_desktopData->runInTerminal : false;
    }

    QString FileSystemEntry::workingDirectory() const {
        ensureDesktopDataLoaded();
        return m_desktopData.has_value() ? m_desktopData->workingDirectory : QString();
    }

    QString FileSystemEntry::startupClass() const {
        ensureDesktopDataLoaded();
        return m_desktopData.has_value() ? m_desktopData->startupClass : QString();
    }

    void FileSystemEntry::execute() {
        ensureDesktopDataLoaded();

        if (!m_desktopData.has_value()) {
            qWarning() << "Cannot execute: not a desktop entry:" << m_path;
            return;
        }

        const QStringList& cmd = m_desktopData->command;
        if (cmd.isEmpty()) {
            qWarning() << "Cannot execute: empty command:" << m_path;
            return;
        }

        const QString& workDir = m_desktopData->workingDirectory;

        // Execute the command detached (like Quickshell.execDetached)
        if (!QProcess::startDetached(cmd[0], cmd.mid(1), workDir.isEmpty() ? QDir::homePath() : workDir)) {
            qWarning() << "Failed to execute:" << cmd.join(" ");
        }
    }

    void FileSystemEntry::updateRelativePath(const QDir& dir) {
        const auto relPath = dir.relativeFilePath(m_path);
        if (m_relativePath != relPath) {
            m_relativePath = relPath;
            emit relativePathChanged();
        }
    }

    FileSystemModel::FileSystemModel(QObject* parent)
    : QAbstractListModel(parent)
    , m_recursive(false)
    , m_watchChanges(true)
    , m_showHidden(false)
    , m_sort(true)
    , m_sortProperty("relativePath")
    , m_filter(NoFilter)
    , m_minScore(0.3)
    , m_maxDepth(-1)
    , m_maxResults(-1) {
        connect(&m_watcher, &QFileSystemWatcher::directoryChanged, this, &FileSystemModel::watchDirIfRecursive);
        connect(&m_watcher, &QFileSystemWatcher::directoryChanged, this, &FileSystemModel::updateEntriesForDir);
    }

    int FileSystemModel::rowCount(const QModelIndex& parent) const {
        if (parent != QModelIndex()) {
            return 0;
        }
        return static_cast<int>(m_entries.size());
    }

    QVariant FileSystemModel::data(const QModelIndex& index, int role) const {
        if (role != Qt::UserRole || !index.isValid() || index.row() >= m_entries.size()) {
            return QVariant();
        }
        return QVariant::fromValue(m_entries.at(index.row()));
    }

    QHash<int, QByteArray> FileSystemModel::roleNames() const {
        return { { Qt::UserRole, "modelData" } };
    }

    QString FileSystemModel::path() const {
        return m_path;
    }

    void FileSystemModel::setPath(const QString& path) {
        if (m_path == path) {
            return;
        }

        m_path = path;
        emit pathChanged();

        m_dir.setPath(m_path);

        for (const auto& entry : std::as_const(m_entries)) {
            entry->updateRelativePath(m_dir);
        }

        update();
    }

    bool FileSystemModel::recursive() const {
        return m_recursive;
    }

    void FileSystemModel::setRecursive(bool recursive) {
        if (m_recursive == recursive) {
            return;
        }

        m_recursive = recursive;
        emit recursiveChanged();

        update();
    }

    bool FileSystemModel::watchChanges() const {
        return m_watchChanges;
    }

    void FileSystemModel::setWatchChanges(bool watchChanges) {
        if (m_watchChanges == watchChanges) {
            return;
        }

        m_watchChanges = watchChanges;
        emit watchChangesChanged();

        update();
    }

    bool FileSystemModel::showHidden() const {
        return m_showHidden;
    }

    void FileSystemModel::setShowHidden(bool showHidden) {
        if (m_showHidden == showHidden) {
            return;
        }

        m_showHidden = showHidden;
        emit showHiddenChanged();

        update();
    }

    bool FileSystemModel::sort() const {
        return m_sort;
    }

    void FileSystemModel::setSort(bool sort) {
        if (m_sort == sort) {
            return;
        }

        m_sort = sort;
        emit sortChanged();

        // Re-sort existing entries when enabling sort
        if (m_sort) {
            resortEntries();
        }

        update();
    }

    QString FileSystemModel::sortProperty() const {
        return m_sortProperty;
    }

    void FileSystemModel::setSortProperty(const QString& sortProperty) {
        if (m_sortProperty == sortProperty) {
            return;
        }

        m_sortProperty = sortProperty;
        emit sortPropertyChanged();

        // Re-sort existing entries if sorting is enabled
        if (m_sort) {
            resortEntries();
        }

        update();
    }

    bool FileSystemModel::sortReverse() const {
        return m_sortReverse;
    }

    void FileSystemModel::setSortReverse(bool sortReverse) {
        if (m_sortReverse == sortReverse) {
            return;
        }

        m_sortReverse = sortReverse;
        emit sortReverseChanged();

        // Re-sort existing entries if sorting is enabled
        if (m_sort) {
            resortEntries();
        }

        update();
    }

    FileSystemModel::Filter FileSystemModel::filter() const {
        return m_filter;
    }

    void FileSystemModel::setFilter(Filter filter) {
        if (m_filter == filter) {
            return;
        }

        m_filter = filter;
        emit filterChanged();

        update();
    }

    QStringList FileSystemModel::nameFilters() const {
        return m_nameFilters;
    }

    void FileSystemModel::setNameFilters(const QStringList& nameFilters) {
        if (m_nameFilters == nameFilters) {
            return;
        }

        m_nameFilters = nameFilters;
        emit nameFiltersChanged();

        update();
    }

    QString FileSystemModel::query() const {
        return m_query;
    }

    void FileSystemModel::setQuery(const QString& query) {
        if (m_query == query) {
            return;
        }

        m_query = query;
        m_scoreCache.clear();
        emit queryChanged();

        // Clear existing entries to force a full refresh
        // This ensures proper sorting after query changes
        if (!m_entries.isEmpty()) {
            beginResetModel();
            qDeleteAll(m_entries);
            m_entries.clear();
            endResetModel();
        }

        update();
    }

    double FileSystemModel::minScore() const {
        return m_minScore;
    }

    void FileSystemModel::setMinScore(double minScore) {
        if (qFuzzyCompare(m_minScore, minScore)) {
            return;
        }

        m_minScore = minScore;
        emit minScoreChanged();

        update();
    }

    int FileSystemModel::maxDepth() const {
        return m_maxDepth;
    }

    void FileSystemModel::setMaxDepth(int maxDepth) {
        if (m_maxDepth == maxDepth) {
            return;
        }

        m_maxDepth = maxDepth;
        emit maxDepthChanged();

        update();
    }

    int FileSystemModel::maxResults() const {
        return m_maxResults;
    }

    void FileSystemModel::setMaxResults(int maxResults) {
        if (m_maxResults == maxResults) {
            return;
        }

        m_maxResults = maxResults;
        emit maxResultsChanged();

        update();
    }

    QQmlListProperty<FileSystemEntry> FileSystemModel::entries() {
        return QQmlListProperty<FileSystemEntry>(this, &m_entries);
    }

    void FileSystemModel::watchDirIfRecursive(const QString& path) {
        if (m_recursive && m_watchChanges) {
            const auto currentDir = m_dir;
            const bool showHidden = m_showHidden;
            const auto future = QtConcurrent::run([showHidden, path]() {
                QDir::Filters filters = QDir::Dirs | QDir::NoDotAndDotDot;
                if (showHidden) {
                    filters |= QDir::Hidden;
                }

                QDirIterator iter(path, filters, QDirIterator::Subdirectories);
                QStringList dirs;
                while (iter.hasNext()) {
                    dirs << iter.next();
                }
                return dirs;
            });
            const auto watcher = new QFutureWatcher<QStringList>(this);
            connect(watcher, &QFutureWatcher<QStringList>::finished, this, [currentDir, showHidden, watcher, this]() {
                const auto paths = watcher->result();
                if (currentDir == m_dir && showHidden == m_showHidden && !paths.isEmpty()) {
                    // Ignore if dir or showHidden has changed
                    m_watcher.addPaths(paths);
                }
                watcher->deleteLater();
            });
            watcher->setFuture(future);
        }
    }

    void FileSystemModel::update() {
        updateWatcher();
        updateEntries();
    }

    void FileSystemModel::updateWatcher() {
        if (!m_watcher.directories().isEmpty()) {
            m_watcher.removePaths(m_watcher.directories());
        }

        if (!m_watchChanges || m_path.isEmpty()) {
            return;
        }

        m_watcher.addPath(m_path);
        watchDirIfRecursive(m_path);
    }

    void FileSystemModel::updateEntries() {
        if (m_path.isEmpty() && m_filter != Applications) {
            if (!m_entries.isEmpty()) {
                beginResetModel();
                qDeleteAll(m_entries);
                m_entries.clear();
                endResetModel();
                emit entriesChanged();
            }

            return;
        }

        for (auto& future : m_futures) {
            future.cancel();
        }
        m_futures.clear();

        // For Applications filter, use empty string as dir (will be ignored anyway)
        updateEntriesForDir(m_filter == Applications ? QString() : m_path);
    }

    void FileSystemModel::updateEntriesForDir(const QString& dir) {
        const auto recursive = m_recursive;
        const auto showHidden = m_showHidden;
        const auto filter = m_filter;
        const auto nameFilters = m_nameFilters;
        const auto query = m_query;
        const auto minScore = m_minScore;
        const auto maxDepth = m_maxDepth;
        const auto maxResults = m_maxResults;

        QSet<QString> oldPaths;
        for (const auto& entry : std::as_const(m_entries)) {
            oldPaths << entry->path();
        }

        const auto future = QtConcurrent::run([=](QPromise<QPair<QSet<QString>, QSet<QString>>>& promise) {
            // Handle Applications filter separately
            if (filter == Applications) {
                // Get XDG directories
                QStringList xdgDirs = DesktopEntryParser::resolveXdgDataDirs();
                QSet<QString> newPaths;
                QMap<QString, QString> seenApps; // basename -> path (deduplication)

                // Iterate through each XDG directory
                for (const QString& xdgDir : xdgDirs) {
                    QDirIterator appIter(xdgDir, QStringList() << "*.desktop", QDir::Files);

                    while (appIter.hasNext()) {
                        if (promise.isCanceled()) {
                            return;
                        }

                        QString path = appIter.next();
                        QString basename = QFileInfo(path).fileName();

                        // Deduplication: prefer first (higher priority)
                        if (seenApps.contains(basename)) {
                            continue;
                        }
                        seenApps[basename] = path;

                        // Parse desktop file
                        auto desktopData = DesktopEntryParser::parse(path);
                        if (!desktopData.has_value()) {
                            continue;
                        }

                        // Honor NoDisplay (unless showHidden)
                        if (desktopData->noDisplay && !showHidden) {
                            continue;
                        }

                        // Fuzzy search across multiple fields
                        if (!query.isEmpty()) {
                            QString searchText = desktopData->name + " " +
                                               desktopData->genericName + " " +
                                               desktopData->comment + " " +
                                               desktopData->keywords.join(' ');
                            FuzzyMatch match = FuzzySearch::match(query, searchText);
                            if (!match.isMatch || match.score < minScore) {
                                continue;
                            }
                        }

                        newPaths.insert(path);

                        // Check maxResults
                        if (maxResults > 0 && newPaths.size() >= maxResults) {
                            break;
                        }
                    }
                    if (maxResults > 0 && newPaths.size() >= maxResults) {
                        break;
                    }
                }

                if (promise.isCanceled() || newPaths == oldPaths) {
                    return;
                }

                promise.addResult(qMakePair(oldPaths - newPaths, newPaths - oldPaths));
                return;
            }

            const auto flags = recursive ? QDirIterator::Subdirectories : QDirIterator::NoIteratorFlags;

            std::optional<QDirIterator> iter;

            if (filter == Images) {
                QStringList extraNameFilters = nameFilters;
                const auto formats = QImageReader::supportedImageFormats();
                for (const auto& format : formats) {
                    extraNameFilters << "*." + format;
                }

                QDir::Filters filters = QDir::Files;
                if (showHidden) {
                    filters |= QDir::Hidden;
                }

                iter.emplace(dir, extraNameFilters, filters, flags);
            } else {
                QDir::Filters filters;

                if (filter == Files) {
                    filters = QDir::Files;
                } else if (filter == Dirs) {
                    filters = QDir::Dirs | QDir::NoDotAndDotDot;
                } else {
                    filters = QDir::Dirs | QDir::Files | QDir::NoDotAndDotDot;
                }

                if (showHidden) {
                    filters |= QDir::Hidden;
                }

                if (nameFilters.isEmpty()) {
                    iter.emplace(dir, filters, flags);
                } else {
                    iter.emplace(dir, nameFilters, filters, flags);
                }
            }

            QSet<QString> newPaths;

            // For efficient depth checking
            const QString baseDir = dir.endsWith('/') ? dir : dir + '/';
            const int baseDirDepth = baseDir.count('/');

            while (iter->hasNext()) {
                if (promise.isCanceled()) {
                    return;
                }

                // Check if we've reached max results
                if (maxResults > 0 && newPaths.size() >= maxResults) {
                    break;
                }

                QString path = iter->next();

                // Check depth limit if recursive and maxDepth is set
                if (recursive && maxDepth >= 0) {
                    int currentDepth = path.count('/') - baseDirDepth;
                    if (currentDepth > maxDepth) {
                        continue;
                    }
                }

                if (filter == Images) {
                    QImageReader reader(path);
                    if (!reader.canRead()) {
                        continue;
                    }
                }

                // Apply fuzzy search filter if query is set
                if (!query.isEmpty()) {
                    QFileInfo fileInfo(path);
                    QString fileName = fileInfo.fileName();
                    FuzzyMatch match = FuzzySearch::match(query, fileName);

                    if (!match.isMatch || match.score < minScore) {
                        continue; // Skip files that don't match the query
                    }
                }

                newPaths.insert(path);
            }

            if (promise.isCanceled() || newPaths == oldPaths) {
                return;
            }

            promise.addResult(qMakePair(oldPaths - newPaths, newPaths - oldPaths));
        });

        if (m_futures.contains(dir)) {
            m_futures[dir].cancel();
        }
        m_futures.insert(dir, future);

        const auto watcher = new QFutureWatcher<QPair<QSet<QString>, QSet<QString>>>(this);

        connect(watcher, &QFutureWatcher<QPair<QSet<QString>, QSet<QString>>>::finished, this, [dir, watcher, this]() {
            m_futures.remove(dir);

            if (!watcher->future().isResultReadyAt(0)) {
                watcher->deleteLater();
                return;
            }

            const auto result = watcher->result();
            applyChanges(result.first, result.second);

            watcher->deleteLater();
        });

        watcher->setFuture(future);
    }

    void FileSystemModel::applyChanges(const QSet<QString>& removedPaths, const QSet<QString>& addedPaths) {
        QList<int> removedIndices;
        for (int i = 0; i < m_entries.size(); ++i) {
            if (removedPaths.contains(m_entries[i]->path())) {
                removedIndices << i;
            }
        }
        std::sort(removedIndices.begin(), removedIndices.end(), std::greater<int>());

        // Batch remove old entries
        int start = -1;
        int end = -1;
        for (int idx : std::as_const(removedIndices)) {
            if (start == -1) {
                start = idx;
                end = idx;
            } else if (idx == end - 1) {
                end = idx;
            } else {
                beginRemoveRows(QModelIndex(), end, start);
                for (int i = start; i >= end; --i) {
                    m_entries.takeAt(i)->deleteLater();
                }
                endRemoveRows();

                start = idx;
                end = idx;
            }
        }
        if (start != -1) {
            beginRemoveRows(QModelIndex(), end, start);
            for (int i = start; i >= end; --i) {
                m_entries.takeAt(i)->deleteLater();
            }
            endRemoveRows();
        }

        // Create new entries
        QList<FileSystemEntry*> newEntries;
        for (const auto& path : addedPaths) {
            newEntries << new FileSystemEntry(path, m_dir.relativeFilePath(path), this);
        }

        // Only sort if sorting is enabled
        if (m_sort) {
            std::sort(newEntries.begin(), newEntries.end(), [this](const FileSystemEntry* a, const FileSystemEntry* b) {
                return compareEntries(a, b);
            });
        }

        // Batch insert new entries
        if (m_sort) {
            // Insert entries in sorted order using binary search
            int insertStart = -1;
            QList<FileSystemEntry*> batchItems;
            for (const auto& entry : std::as_const(newEntries)) {
                const auto it = std::lower_bound(
                    m_entries.begin(), m_entries.end(), entry, [this](const FileSystemEntry* a, const FileSystemEntry* b) {
                        return compareEntries(a, b);
                    });
                const auto row = static_cast<int>(it - m_entries.begin());

                if (insertStart == -1) {
                    insertStart = row;
                    batchItems << entry;
                } else if (row == insertStart + batchItems.size()) {
                    batchItems << entry;
                } else {
                    beginInsertRows(QModelIndex(), insertStart, insertStart + static_cast<int>(batchItems.size()) - 1);
                    for (int i = 0; i < batchItems.size(); ++i) {
                        m_entries.insert(insertStart + i, batchItems[i]);
                    }
                    endInsertRows();

                    insertStart = row;
                    batchItems.clear();
                    batchItems << entry;
                }
            }
            if (!batchItems.isEmpty()) {
                beginInsertRows(QModelIndex(), insertStart, insertStart + static_cast<int>(batchItems.size()) - 1);
                for (int i = 0; i < batchItems.size(); ++i) {
                    m_entries.insert(insertStart + i, batchItems[i]);
                }
                endInsertRows();
            }
        } else {
            // Just append entries to the end without sorting
            if (!newEntries.isEmpty()) {
                const int startRow = m_entries.size();
                beginInsertRows(QModelIndex(), startRow, startRow + newEntries.size() - 1);
                m_entries.append(newEntries);
                endInsertRows();
            }
        }

        emit entriesChanged();
    }

    void FileSystemModel::resortEntries() {
        if (!m_entries.isEmpty() && m_sort) {
            beginResetModel();
            std::sort(m_entries.begin(), m_entries.end(), [this](const FileSystemEntry* a, const FileSystemEntry* b) {
                return compareEntries(a, b);
            });
            endResetModel();
            emit entriesChanged();
        }
    }

    bool FileSystemModel::compareEntries(const FileSystemEntry* a, const FileSystemEntry* b) const {
        // If sorting is disabled, maintain insertion order
        if (!m_sort) {
            return false;
        }

        // If query is set, sort by fuzzy match score first
        if (!m_query.isEmpty()) {
            double scoreA;
            double scoreB;

            // For Applications filter, search across multiple fields
            if (m_filter == Applications) {
                QString keyA = a->path();
                QString keyB = b->path();

                if (m_scoreCache.contains(keyA)) {
                    scoreA = m_scoreCache[keyA];
                } else {
                    // Build composite search text
                    QString textA = a->name() + " " +
                                   a->genericName() + " " +
                                   a->comment() + " " +
                                   a->keywords().join(' ');
                    scoreA = FuzzySearch::calculateScore(m_query, textA);
                    m_scoreCache[keyA] = scoreA;
                }

                if (m_scoreCache.contains(keyB)) {
                    scoreB = m_scoreCache[keyB];
                } else {
                    QString textB = b->name() + " " +
                                   b->genericName() + " " +
                                   b->comment() + " " +
                                   b->keywords().join(' ');
                    scoreB = FuzzySearch::calculateScore(m_query, textB);
                    m_scoreCache[keyB] = scoreB;
                }
            } else {
                // For other filters, use file name
                if (m_scoreCache.contains(a->fileName())) {
                    scoreA = m_scoreCache[a->fileName()];
                } else {
                    scoreA = FuzzySearch::calculateScore(m_query, a->fileName());
                    m_scoreCache[a->fileName()] = scoreA;
                }

                if (m_scoreCache.contains(b->fileName())) {
                    scoreB = m_scoreCache[b->fileName()];
                } else {
                    scoreB = FuzzySearch::calculateScore(m_query, b->fileName());
                    m_scoreCache[b->fileName()] = scoreB;
                }
            }

            if (!qFuzzyCompare(scoreA, scoreB)) {
                return m_sortReverse ? scoreA < scoreB : scoreA > scoreB;
            }
        }

        // Fall back to directory/name sorting
        if (a->isDir() != b->isDir()) {
            return m_sortReverse ^ a->isDir();
        }

        // Use the specified sort property for comparison
        QVariant valueA = a->property(m_sortProperty.toUtf8().constData());
        QVariant valueB = b->property(m_sortProperty.toUtf8().constData());

        // Convert to strings for comparison
        QString strA = valueA.toString();
        QString strB = valueB.toString();

        const auto cmp = strA.localeAwareCompare(strB);
        return m_sortReverse ? cmp > 0 : cmp < 0;
    }

    bool FileSystemModel::matchesQuery(const QString& path) const {
        if (m_query.isEmpty()) {
            return true;
        }

        QFileInfo fileInfo(path);
        QString fileName = fileInfo.fileName();
        FuzzyMatch match = FuzzySearch::match(m_query, fileName);

        return match.isMatch && match.score >= m_minScore;
    }

} // namespace quicksearch::models
