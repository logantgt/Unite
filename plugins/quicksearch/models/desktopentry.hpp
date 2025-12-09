#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QList>
#include <QSettings>
#include <qqmlintegration.h>
#include <optional>

namespace quicksearch::models {

    // Forward declaration
    class DesktopAction;

    // Desktop Action - matches Quickshell DesktopAction API
    class DesktopAction : public QObject {
        Q_OBJECT
        QML_ELEMENT
        QML_UNCREATABLE("DesktopAction instances can only be retrieved from a FileSystemEntry")

        Q_PROPERTY(QString id READ id CONSTANT)
        Q_PROPERTY(QString name READ name CONSTANT)
        Q_PROPERTY(QString execString READ execString CONSTANT)
        Q_PROPERTY(QString icon READ icon CONSTANT)
        Q_PROPERTY(QStringList command READ command CONSTANT)

    public:
        explicit DesktopAction(const QString& actionId, const QString& actionName,
                              const QString& exec, const QString& iconName,
                              QObject* parent = nullptr);

        [[nodiscard]] QString id() const { return m_id; }
        [[nodiscard]] QString name() const { return m_name; }
        [[nodiscard]] QString execString() const { return m_execString; }
        [[nodiscard]] QString icon() const { return m_icon; }
        [[nodiscard]] QStringList command() const { return m_command; }

    private:
        QString m_id;
        QString m_name;
        QString m_execString;
        QString m_icon;
        QStringList m_command;
    };

    // Internal data holder - not exposed to QML
    struct DesktopEntryData {
        QString name;
        QString genericName;
        QString comment;
        QString icon;
        QStringList command;
        QString execString;
        QStringList categories;
        QStringList keywords;
        QList<DesktopAction*> actions;
        QString id;
        bool noDisplay;
        bool runInTerminal;
        QString workingDirectory;
        QString startupClass;

        ~DesktopEntryData() {
            qDeleteAll(actions);
        }

        // Delete copy operations to prevent double-free
        DesktopEntryData(const DesktopEntryData&) = delete;
        DesktopEntryData& operator=(const DesktopEntryData&) = delete;

        // Allow move operations
        DesktopEntryData(DesktopEntryData&&) = default;
        DesktopEntryData& operator=(DesktopEntryData&&) = default;

        DesktopEntryData() = default;
    };

    // Desktop entry parser utility
    class DesktopEntryParser {
    public:
        // Parse a .desktop file and return its data
        static std::optional<DesktopEntryData> parse(const QString& filePath);

        // Parse Exec string, remove field codes, handle quotes
        static QStringList parseExecString(const QString& exec);

        // Resolve XDG application directories
        static QStringList resolveXdgDataDirs();

    private:
        // Parse localized keys (e.g., Name[en_US])
        static QString parseLocalizedKey(QSettings& settings,
                                        const QString& key);
    };

} // namespace quicksearch::models
