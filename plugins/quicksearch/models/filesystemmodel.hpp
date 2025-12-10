// https://raw.githubusercontent.com/caelestia-dots/shell/refs/heads/main/plugin/src/Caelestia/Models/filesystemmodel.hpp
// Original work by soramane, caelestia-dots/shell, licensed under GPL-3.0, thank you for your hard work!

#pragma once

#include <qabstractitemmodel.h>
#include <qdir.h>
#include <qfilesystemwatcher.h>
#include <qfuture.h>
#include <qimage.h>
#include <qimagereader.h>
#include <qmimedatabase.h>
#include <qobject.h>
#include <qqmlintegration.h>
#include <qqmllist.h>
#include <optional>

#include "desktopentry.hpp"

namespace quicksearch::models {

    class FileSystemEntry : public QObject {
        Q_OBJECT
        QML_ELEMENT
        QML_UNCREATABLE("FileSystemEntry instances can only be retrieved from a FileSystemModel")

        Q_PROPERTY(QString path READ path CONSTANT)
        Q_PROPERTY(QString relativePath READ relativePath NOTIFY relativePathChanged)
        Q_PROPERTY(QString fileName READ fileName CONSTANT)
        Q_PROPERTY(QString baseName READ baseName CONSTANT)
        Q_PROPERTY(QString parentDir READ parentDir CONSTANT)
        Q_PROPERTY(QString suffix READ suffix CONSTANT)
        Q_PROPERTY(qint64 size READ size CONSTANT)
        Q_PROPERTY(bool isDir READ isDir CONSTANT)
        Q_PROPERTY(bool isImage READ isImage CONSTANT)
        Q_PROPERTY(QString imageThumbnail READ imageThumbnail CONSTANT)
        Q_PROPERTY(bool isVideo READ isVideo CONSTANT)
        Q_PROPERTY(QString videoThumbnail READ videoThumbnail CONSTANT)
        Q_PROPERTY(bool isMusic READ isMusic CONSTANT)
        Q_PROPERTY(QString musicThumbnail READ musicThumbnail CONSTANT)
        Q_PROPERTY(QString mimeType READ mimeType CONSTANT)

        // Desktop entry properties
        Q_PROPERTY(bool isDesktopEntry READ isDesktopEntry CONSTANT)
        Q_PROPERTY(QString name READ name CONSTANT)
        Q_PROPERTY(QString genericName READ genericName CONSTANT)
        Q_PROPERTY(QString comment READ comment CONSTANT)
        Q_PROPERTY(QString icon READ icon CONSTANT)
        Q_PROPERTY(QStringList command READ command CONSTANT)
        Q_PROPERTY(QString execString READ execString CONSTANT)
        Q_PROPERTY(QStringList categories READ categories CONSTANT)
        Q_PROPERTY(QStringList keywords READ keywords CONSTANT)
        Q_PROPERTY(QQmlListProperty<quicksearch::models::DesktopAction> actions READ actions CONSTANT)
        Q_PROPERTY(QString desktopId READ desktopId CONSTANT)
        Q_PROPERTY(bool noDisplay READ noDisplay CONSTANT)
        Q_PROPERTY(bool runInTerminal READ runInTerminal CONSTANT)
        Q_PROPERTY(QString workingDirectory READ workingDirectory CONSTANT)
        Q_PROPERTY(QString startupClass READ startupClass CONSTANT)

    public:
        explicit FileSystemEntry(const QString& path, const QString& relativePath, QObject* parent = nullptr);

        [[nodiscard]] QString path() const;
        [[nodiscard]] QString relativePath() const;
        [[nodiscard]] QString fileName() const;
        [[nodiscard]] QString baseName() const;
        [[nodiscard]] QString parentDir() const;
        [[nodiscard]] QString suffix() const;
        [[nodiscard]] qint64 size() const;
        [[nodiscard]] bool isDir() const;
        [[nodiscard]] bool isImage() const;
        [[nodiscard]] QString imageThumbnail() const;
        [[nodiscard]] bool isVideo() const;
        [[nodiscard]] QString videoThumbnail() const;
        [[nodiscard]] bool isMusic() const;
        [[nodiscard]] QString musicThumbnail() const;
        [[nodiscard]] QString mimeType() const;

        // Desktop entry getters
        [[nodiscard]] bool isDesktopEntry() const;
        [[nodiscard]] QString name() const;
        [[nodiscard]] QString genericName() const;
        [[nodiscard]] QString comment() const;
        [[nodiscard]] QString icon() const;
        [[nodiscard]] QStringList command() const;
        [[nodiscard]] QString execString() const;
        [[nodiscard]] QStringList categories() const;
        [[nodiscard]] QStringList keywords() const;
        [[nodiscard]] QQmlListProperty<quicksearch::models::DesktopAction> actions() const;
        [[nodiscard]] QString desktopId() const;
        [[nodiscard]] bool noDisplay() const;
        [[nodiscard]] bool runInTerminal() const;
        [[nodiscard]] QString workingDirectory() const;
        [[nodiscard]] QString startupClass() const;

        Q_INVOKABLE void execute();

        void updateRelativePath(const QDir& dir);

    signals:
        void relativePathChanged();

    private:
        const QFileInfo m_fileInfo;

        const QString m_path;
        QString m_relativePath;

        mutable bool m_isImage;
        mutable bool m_isImageInitialised;

        mutable QString m_imageThumbnail;
        mutable bool m_imageThumbnailInitialised;

        mutable bool m_isVideo;
        mutable bool m_isVideoInitialised;

        mutable QString m_videoThumbnail;
        mutable bool m_videoThumbnailInitialised;

        mutable bool m_isMusic;
        mutable bool m_isMusicInitialised;

        mutable QString m_musicThumbnail;
        mutable bool m_musicThumbnailInitialised;

        mutable QString m_mimeType;
        mutable bool m_mimeTypeInitialised;

        mutable std::optional<DesktopEntryData> m_desktopData;
        mutable bool m_desktopDataInitialised;

        void ensureDesktopDataLoaded() const;
        [[nodiscard]] bool isMostlyBlack(const QImage& image) const;
    };

    class FileSystemModel : public QAbstractListModel {
        Q_OBJECT
        QML_ELEMENT

        Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged)
        Q_PROPERTY(bool recursive READ recursive WRITE setRecursive NOTIFY recursiveChanged)
        Q_PROPERTY(bool watchChanges READ watchChanges WRITE setWatchChanges NOTIFY watchChangesChanged)
        Q_PROPERTY(bool showHidden READ showHidden WRITE setShowHidden NOTIFY showHiddenChanged)
        Q_PROPERTY(bool sort READ sort WRITE setSort NOTIFY sortChanged)
        Q_PROPERTY(QString sortProperty READ sortProperty WRITE setSortProperty NOTIFY sortPropertyChanged)
        Q_PROPERTY(bool sortReverse READ sortReverse WRITE setSortReverse NOTIFY sortReverseChanged)
        Q_PROPERTY(Filter filter READ filter WRITE setFilter NOTIFY filterChanged)
        Q_PROPERTY(QStringList nameFilters READ nameFilters WRITE setNameFilters NOTIFY nameFiltersChanged)
        Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)
        Q_PROPERTY(double minScore READ minScore WRITE setMinScore NOTIFY minScoreChanged)
        Q_PROPERTY(int maxDepth READ maxDepth WRITE setMaxDepth NOTIFY maxDepthChanged)
        Q_PROPERTY(int maxResults READ maxResults WRITE setMaxResults NOTIFY maxResultsChanged)

        Q_PROPERTY(QQmlListProperty<quicksearch::models::FileSystemEntry> entries READ entries NOTIFY entriesChanged)
        Q_PROPERTY(int length READ length NOTIFY lengthChanged)

    public:
        enum Filter {
            NoFilter,
            Images,
            Files,
            Dirs,
            Applications
        };
        Q_ENUM(Filter)

        explicit FileSystemModel(QObject* parent = nullptr);

        int rowCount(const QModelIndex& parent = QModelIndex()) const override;
        QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
        QHash<int, QByteArray> roleNames() const override;

        [[nodiscard]] QString path() const;
        void setPath(const QString& path);

        [[nodiscard]] bool recursive() const;
        void setRecursive(bool recursive);

        [[nodiscard]] bool watchChanges() const;
        void setWatchChanges(bool watchChanges);

        [[nodiscard]] bool showHidden() const;
        void setShowHidden(bool showHidden);

        [[nodiscard]] bool sort() const;
        void setSort(bool sort);

        [[nodiscard]] QString sortProperty() const;
        void setSortProperty(const QString& sortProperty);

        [[nodiscard]] bool sortReverse() const;
        void setSortReverse(bool sortReverse);

        [[nodiscard]] Filter filter() const;
        void setFilter(Filter filter);

        [[nodiscard]] QStringList nameFilters() const;
        void setNameFilters(const QStringList& nameFilters);

        [[nodiscard]] QString query() const;
        void setQuery(const QString& query);

        [[nodiscard]] double minScore() const;
        void setMinScore(double minScore);

        [[nodiscard]] int maxDepth() const;
        void setMaxDepth(int maxDepth);

        [[nodiscard]] int maxResults() const;
        void setMaxResults(int maxResults);

        [[nodiscard]] QQmlListProperty<FileSystemEntry> entries();
        [[nodiscard]] int length() const;

        Q_INVOKABLE QList<QObject*> slice(int start, int count);

    signals:
        void pathChanged();
        void recursiveChanged();
        void watchChangesChanged();
        void showHiddenChanged();
        void sortChanged();
        void sortPropertyChanged();
        void sortReverseChanged();
        void filterChanged();
        void nameFiltersChanged();
        void queryChanged();
        void minScoreChanged();
        void maxDepthChanged();
        void maxResultsChanged();
        void entriesChanged();
        void lengthChanged();

    private:
        QDir m_dir;
        QFileSystemWatcher m_watcher;
        QList<FileSystemEntry*> m_entries;
        QHash<QString, QFuture<QPair<QSet<QString>, QSet<QString>>>> m_futures;
        uint64_t m_taskGeneration;

        QString m_path;
        bool m_recursive;
        bool m_watchChanges;
        bool m_showHidden;
        bool m_sort;
        QString m_sortProperty;
        bool m_sortReverse;
        Filter m_filter;
        QStringList m_nameFilters;
        QString m_query;
        double m_minScore;
        int m_maxDepth;
        int m_maxResults;

        mutable QHash<QString, double> m_scoreCache;

        void watchDirIfRecursive(const QString& path);
        void update();
        void updateWatcher();
        void updateEntries();
        void updateEntriesForDir(const QString& dir);
        void applyChanges(const QSet<QString>& removedPaths, const QSet<QString>& addedPaths);
        void resortEntries();
        [[nodiscard]] bool compareEntries(const FileSystemEntry* a, const FileSystemEntry* b) const;
        [[nodiscard]] bool matchesQuery(const QString& path) const;
    };

} // namespace quicksearch::models
