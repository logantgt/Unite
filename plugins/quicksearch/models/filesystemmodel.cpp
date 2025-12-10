// https://raw.githubusercontent.com/caelestia-dots/shell/refs/heads/main/plugin/src/Caelestia/Models/filesystemmodel.cpp
// Original work by soramane, caelestia-dots/shell, licensed under GPL-3.0, thank you for your hard work!

#include "filesystemmodel.hpp"
#include "fuzzysearch.hpp"

#include <qcryptographichash.h>
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
    , m_imageThumbnailInitialised(false)
    , m_isVideoInitialised(false)
    , m_videoThumbnailInitialised(false)
    , m_isMusicInitialised(false)
    , m_musicThumbnailInitialised(false)
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

    QString FileSystemEntry::imageThumbnail() const {
        if (!m_imageThumbnailInitialised) {
            m_imageThumbnailInitialised = true;

            // Only generate thumbnails for image files
            if (!isImage()) {
                m_imageThumbnail = QString();
                return m_imageThumbnail;
            }

            // Generate cache directory path
            const QString cacheDir = QDir::homePath() + "/.cache/unite/image-thumbnails";
            QDir().mkpath(cacheDir);

            // Generate unique filename based on image path and modification time
            QCryptographicHash hash(QCryptographicHash::Sha256);
            hash.addData(m_path.toUtf8());
            hash.addData(QString::number(m_fileInfo.lastModified().toMSecsSinceEpoch()).toUtf8());
            const QString hashStr = QString(hash.result().toHex());
            const QString thumbnailPath = cacheDir + "/" + hashStr + ".png";

            // Check if thumbnail already exists
            if (QFileInfo::exists(thumbnailPath)) {
                m_imageThumbnail = thumbnailPath;
                return m_imageThumbnail;
            }

            // Load the original image
            QImage image(m_path);
            if (image.isNull()) {
                m_imageThumbnail = QString();
                return m_imageThumbnail;
            }

            // Scale image to 512px max dimension while preserving aspect ratio
            const int maxSize = 512;
            QImage thumbnail;
            if (image.width() > maxSize || image.height() > maxSize) {
                thumbnail = image.scaled(maxSize, maxSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
            } else {
                // If image is already small, just use it as-is
                thumbnail = image;
            }

            // Save the thumbnail as PNG to preserve transparency
            if (thumbnail.save(thumbnailPath, "PNG")) {
                m_imageThumbnail = thumbnailPath;
            } else {
                // If saving fails, return the original path
                m_imageThumbnail = m_path;
            }
        }
        return m_imageThumbnail;
    }

    bool FileSystemEntry::isVideo() const {
        if (!m_isVideoInitialised) {
            // Check MIME type to determine if it's a video
            const QMimeDatabase db;
            const QString mime = db.mimeTypeForFile(m_path).name();
            m_isVideo = mime.startsWith("video/");
            m_isVideoInitialised = true;
        }
        return m_isVideo;
    }

    QString FileSystemEntry::videoThumbnail() const {
        if (!m_videoThumbnailInitialised) {
            m_videoThumbnailInitialised = true;

            // Only generate thumbnails for video files
            if (!isVideo()) {
                m_videoThumbnail = QString();
                return m_videoThumbnail;
            }

            // Generate cache directory path
            const QString cacheDir = QDir::homePath() + "/.cache/unite/video-thumbnails";
            QDir().mkpath(cacheDir);

            // Generate unique filename based on video path
            QCryptographicHash hash(QCryptographicHash::Sha256);
            hash.addData(m_path.toUtf8());
            const QString hashStr = QString(hash.result().toHex());
            const QString thumbnailPath = cacheDir + "/" + hashStr + ".jpg";

            // Check if thumbnail already exists and is not mostly black
            if (QFileInfo::exists(thumbnailPath)) {
                QImage existingImage(thumbnailPath);
                if (!existingImage.isNull() && !isMostlyBlack(existingImage)) {
                    m_videoThumbnail = thumbnailPath;
                    return m_videoThumbnail;
                }
                // If existing thumbnail is mostly black, delete it and regenerate
                QFile::remove(thumbnailPath);
            }

            // Try different timestamps to avoid black frames
            QStringList timestamps = {"10%", "20%", "30%", "5%"};

            // Try to generate thumbnail using ffmpegthumbnailer first
            for (const QString& timestamp : timestamps) {
                QProcess ffmpegthumbnailer;
                ffmpegthumbnailer.start("ffmpegthumbnailer", QStringList()
                    << "-i" << m_path
                    << "-o" << thumbnailPath
                    << "-s" << "512"
                    << "-t" << timestamp);

                if (ffmpegthumbnailer.waitForFinished(5000) && ffmpegthumbnailer.exitCode() == 0) {
                    // Check if the generated thumbnail is mostly black
                    QImage thumbnail(thumbnailPath);
                    if (!thumbnail.isNull() && !isMostlyBlack(thumbnail)) {
                        m_videoThumbnail = thumbnailPath;
                        return m_videoThumbnail;
                    }
                    // If mostly black, try next timestamp
                    QFile::remove(thumbnailPath);
                }
            }

            // Fallback to ffmpeg if ffmpegthumbnailer is not available or all attempts failed
            QStringList ffmpegTimestamps = {"00:00:03", "00:00:05", "00:00:10", "00:00:01"};
            for (const QString& timestamp : ffmpegTimestamps) {
                QProcess ffmpeg;
                ffmpeg.start("ffmpeg", QStringList()
                    << "-ss" << timestamp
                    << "-i" << m_path
                    << "-vframes" << "1"
                    << "-vf" << "scale=512:-1"
                    << thumbnailPath
                    << "-y");

                if (ffmpeg.waitForFinished(5000) && ffmpeg.exitCode() == 0) {
                    // Check if the generated thumbnail is mostly black
                    QImage thumbnail(thumbnailPath);
                    if (!thumbnail.isNull() && !isMostlyBlack(thumbnail)) {
                        m_videoThumbnail = thumbnailPath;
                        return m_videoThumbnail;
                    }
                    // If mostly black, try next timestamp
                    QFile::remove(thumbnailPath);
                }
            }

            // If all attempts fail, return empty string
            m_videoThumbnail = QString();
        }
        return m_videoThumbnail;
    }

    bool FileSystemEntry::isMostlyBlack(const QImage& image) const {
        if (image.isNull() || image.width() == 0 || image.height() == 0) {
            return true;
        }

        // Sample pixels to check if image is mostly black
        // We don't need to check every pixel - sampling is faster
        const int sampleRate = 8; // Check every 8th pixel
        int blackPixels = 0;
        int totalSamples = 0;

        for (int y = 0; y < image.height(); y += sampleRate) {
            for (int x = 0; x < image.width(); x += sampleRate) {
                QColor pixel = image.pixelColor(x, y);
                totalSamples++;

                // Consider a pixel "black" if its brightness is very low
                // Calculate brightness as average of RGB
                int brightness = (pixel.red() + pixel.green() + pixel.blue()) / 3;

                if (brightness < 25) { // Very dark threshold (0-255 scale)
                    blackPixels++;
                }
            }
        }

        // Return true if more than 50% of sampled pixels are black
        return totalSamples > 0 && (static_cast<double>(blackPixels) / totalSamples) > 0.5;
    }

    bool FileSystemEntry::isMusic() const {
        if (!m_isMusicInitialised) {
            // Check MIME type to determine if it's an audio file
            const QMimeDatabase db;
            const QString mime = db.mimeTypeForFile(m_path).name();
            m_isMusic = mime.startsWith("audio/");
            m_isMusicInitialised = true;
        }
        return m_isMusic;
    }

    QString FileSystemEntry::musicThumbnail() const {
        if (!m_musicThumbnailInitialised) {
            m_musicThumbnailInitialised = true;

            // Only generate thumbnails for music files
            if (!isMusic()) {
                m_musicThumbnail = QString();
                return m_musicThumbnail;
            }

            // Generate cache directory path
            const QString cacheDir = QDir::homePath() + "/.cache/unite/music-thumbnails";
            QDir().mkpath(cacheDir);

            // Generate unique filename based on music file path
            QCryptographicHash hash(QCryptographicHash::Sha256);
            hash.addData(m_path.toUtf8());
            const QString hashStr = QString(hash.result().toHex());
            const QString thumbnailPath = cacheDir + "/" + hashStr + ".jpg";

            // Check if thumbnail already exists in cache
            if (QFileInfo::exists(thumbnailPath)) {
                m_musicThumbnail = thumbnailPath;
                return m_musicThumbnail;
            }

            // Try to extract embedded album art using ffmpeg
            QProcess ffmpeg;
            ffmpeg.start("ffmpeg", QStringList()
                << "-i" << m_path
                << "-an"  // Disable audio
                << "-vcodec" << "copy"  // Copy video stream (album art)
                << thumbnailPath
                << "-y");

            if (ffmpeg.waitForFinished(5000) && ffmpeg.exitCode() == 0 && QFileInfo::exists(thumbnailPath)) {
                // Successfully extracted embedded art
                m_musicThumbnail = thumbnailPath;
                return m_musicThumbnail;
            }

            // If no embedded art, look for folder.* in the same directory
            const QDir musicDir = m_fileInfo.absoluteDir();
            const QStringList imageExtensions = {"jpg", "jpeg", "png", "gif", "bmp", "webp"};

            for (const QString& ext : imageExtensions) {
                const QString folderImagePath = musicDir.filePath("folder." + ext);
                if (QFileInfo::exists(folderImagePath)) {
                    // Found a folder image, create a cached copy
                    QImage folderImage(folderImagePath);
                    if (!folderImage.isNull()) {
                        // Scale to 512px and save to cache
                        const int maxSize = 512;
                        QImage thumbnail;
                        if (folderImage.width() > maxSize || folderImage.height() > maxSize) {
                            thumbnail = folderImage.scaled(maxSize, maxSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
                        } else {
                            thumbnail = folderImage;
                        }

                        if (thumbnail.save(thumbnailPath, "JPG", 85)) {
                            m_musicThumbnail = thumbnailPath;
                            return m_musicThumbnail;
                        }
                    }
                }
            }

            // Also check for uppercase extensions
            for (const QString& ext : imageExtensions) {
                const QString folderImagePath = musicDir.filePath("folder." + ext.toUpper());
                if (QFileInfo::exists(folderImagePath)) {
                    QImage folderImage(folderImagePath);
                    if (!folderImage.isNull()) {
                        const int maxSize = 512;
                        QImage thumbnail;
                        if (folderImage.width() > maxSize || folderImage.height() > maxSize) {
                            thumbnail = folderImage.scaled(maxSize, maxSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
                        } else {
                            thumbnail = folderImage;
                        }

                        if (thumbnail.save(thumbnailPath, "JPG", 85)) {
                            m_musicThumbnail = thumbnailPath;
                            return m_musicThumbnail;
                        }
                    }
                }
            }

            // No thumbnail found
            m_musicThumbnail = QString();
        }
        return m_musicThumbnail;
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
    , m_maxResults(-1)
    , m_taskGeneration(0) {
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
        ++m_taskGeneration;
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
        ++m_taskGeneration;
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
        ++m_taskGeneration;
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
        ++m_taskGeneration;
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
        ++m_taskGeneration;
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
        ++m_taskGeneration;
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
        ++m_taskGeneration;
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
        ++m_taskGeneration;
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
        ++m_taskGeneration;
        emit maxResultsChanged();

        update();
    }

    QQmlListProperty<FileSystemEntry> FileSystemModel::entries() {
        return QQmlListProperty<FileSystemEntry>(this, &m_entries);
    }

    int FileSystemModel::length() const {
        return m_entries.size();
    }

    QList<QObject*> FileSystemModel::slice(int start, int count) {
        QList<QObject*> result;

        // Validate start index
        if (start < 0 || start >= m_entries.size()) {
            return result;
        }

        // Calculate actual count (don't go past the end)
        const int actualCount = qMin(count, m_entries.size() - start);

        // Slice the entries
        for (int i = 0; i < actualCount; ++i) {
            result.append(m_entries[start + i]);
        }

        return result;
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
                emit lengthChanged();
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
        // Capture generation number FIRST to validate results before applying
        const auto taskGeneration = m_taskGeneration;
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

            // Images filter: Generate patterns for all supported image formats.
            // Note: nameFilters is intentionally IGNORED for specialized filters (Images, Applications)
            // to provide complete filter specifications. Users should use filter: Files with nameFilters
            // if they want to restrict to specific image formats.
            if (filter == Images) {
                QStringList imageNameFilters;  // Start with empty list (don't use nameFilters)
                const auto formats = QImageReader::supportedImageFormats();
                for (const auto& format : formats) {
                    imageNameFilters << "*." + format;
                }

                QDir::Filters filters = QDir::Files;
                if (showHidden) {
                    filters |= QDir::Hidden;
                }

                iter.emplace(dir, imageNameFilters, filters, flags);
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

        connect(watcher, &QFutureWatcher<QPair<QSet<QString>, QSet<QString>>>::finished, this, [dir, watcher, taskGeneration, this]() {
            m_futures.remove(dir);

            if (!watcher->future().isResultReadyAt(0)) {
                watcher->deleteLater();
                return;
            }

            // VALIDATE: Only apply results if generation matches
            // This prevents race condition where properties changed between task start and completion
            if (taskGeneration != m_taskGeneration) {
                // Results are stale - discard them
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

        // Build a set of existing paths to prevent duplicates
        QSet<QString> existingPaths;
        for (const auto& entry : std::as_const(m_entries)) {
            existingPaths.insert(entry->path());
        }

        // Only create entries for paths that don't already exist
        for (const auto& path : addedPaths) {
            if (!existingPaths.contains(path)) {
                newEntries << new FileSystemEntry(path, m_dir.relativeFilePath(path), this);
            }
        }

        // Append new entries to the list
        if (!newEntries.isEmpty()) {
            const int startRow = m_entries.size();
            beginInsertRows(QModelIndex(), startRow, startRow + newEntries.size() - 1);
            m_entries.append(newEntries);
            endInsertRows();
        }

        // If sorting is enabled, re-sort the entire list after adding new entries
        if (m_sort && !newEntries.isEmpty()) {
            resortEntries();
        }

        emit entriesChanged();
        emit lengthChanged();
    }

    void FileSystemModel::resortEntries() {
        if (!m_entries.isEmpty() && m_sort) {
            beginResetModel();
            std::sort(m_entries.begin(), m_entries.end(), [this](const FileSystemEntry* a, const FileSystemEntry* b) {
                return compareEntries(a, b);
            });
            endResetModel();
            emit entriesChanged();
            emit lengthChanged();
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
