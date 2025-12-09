#include "desktopentry.hpp"

#include <QSettings>
#include <QFileInfo>
#include <QDir>
#include <QLocale>
#include <QDebug>

namespace quicksearch::models {

    DesktopAction::DesktopAction(const QString& actionId, const QString& actionName,
                                const QString& exec, const QString& iconName,
                                QObject* parent)
    : QObject(parent)
    , m_id(actionId)
    , m_name(actionName)
    , m_execString(exec)
    , m_icon(iconName)
    , m_command(DesktopEntryParser::parseExecString(exec)) {
    }

    QStringList DesktopEntryParser::resolveXdgDataDirs() {
        QStringList dirs;

        // 1. XDG_DATA_HOME (default: ~/.local/share/applications)
        QString dataHome = qEnvironmentVariable("XDG_DATA_HOME");
        if (dataHome.isEmpty()) {
            dataHome = QDir::homePath() + "/.local/share";
        }
        QString dataHomeApps = dataHome + "/applications";
        if (QDir(dataHomeApps).exists()) {
            dirs << dataHomeApps;
        }

        // 2. XDG_DATA_DIRS (default: /usr/local/share:/usr/share)
        QString dataDirs = qEnvironmentVariable("XDG_DATA_DIRS");
        if (dataDirs.isEmpty()) {
            dataDirs = "/usr/local/share:/usr/share";
        }

        for (const QString& dir : dataDirs.split(':', Qt::SkipEmptyParts)) {
            QString appDir = dir + "/applications";
            if (QDir(appDir).exists()) {
                dirs << appDir;
            }
        }

        return dirs;
    }

    QStringList DesktopEntryParser::parseExecString(const QString& exec) {
        QStringList result;
        QString current;
        bool inQuotes = false;
        bool escape = false;

        for (int i = 0; i < exec.length(); ++i) {
            QChar c = exec[i];

            if (escape) {
                current += c;
                escape = false;
                continue;
            }

            if (c == '\\') {
                escape = true;
                continue;
            }

            if (c == '"') {
                inQuotes = !inQuotes;
                continue;
            }

            if (c == ' ' && !inQuotes) {
                if (!current.isEmpty()) {
                    // Skip field codes (%u, %f, %F, %U, etc.)
                    if (!current.startsWith('%')) {
                        result.append(current);
                    }
                    current.clear();
                }
                continue;
            }

            current += c;
        }

        if (!current.isEmpty() && !current.startsWith('%')) {
            result.append(current);
        }

        return result;
    }

    QString DesktopEntryParser::parseLocalizedKey(QSettings& settings, const QString& key) {
        // Try locale-specific first
        QString locale = QLocale::system().name(); // e.g., "en_US"
        QString lang = locale.split('_').first();  // e.g., "en"

        // Try full locale
        QString value = settings.value(key + "[" + locale + "]").toString();
        if (!value.isEmpty()) {
            return value;
        }

        // Try language only
        value = settings.value(key + "[" + lang + "]").toString();
        if (!value.isEmpty()) {
            return value;
        }

        // Fall back to unlocalized
        return settings.value(key).toString();
    }

    std::optional<DesktopEntryData> DesktopEntryParser::parse(const QString& filePath) {
        QSettings settings(filePath, QSettings::IniFormat);

        // Verify Type=Application
        settings.beginGroup("Desktop Entry");
        QString type = settings.value("Type").toString();
        if (type != "Application") {
            settings.endGroup();
            return std::nullopt;
        }

        DesktopEntryData data;

        // Basic properties with localization support
        data.name = parseLocalizedKey(settings, "Name");
        data.genericName = parseLocalizedKey(settings, "GenericName");
        data.comment = parseLocalizedKey(settings, "Comment");
        data.icon = settings.value("Icon").toString();
        data.execString = settings.value("Exec").toString();
        data.command = parseExecString(data.execString);

        // Lists (semicolon-separated)
        QString categoriesStr = settings.value("Categories").toString();
        data.categories = categoriesStr.split(';', Qt::SkipEmptyParts);

        QString keywordsStr = parseLocalizedKey(settings, "Keywords");
        data.keywords = keywordsStr.split(';', Qt::SkipEmptyParts);

        // Booleans
        data.noDisplay = settings.value("NoDisplay", false).toBool();
        data.runInTerminal = settings.value("Terminal", false).toBool();

        // Additional properties
        data.workingDirectory = settings.value("Path").toString();
        data.startupClass = settings.value("StartupWMClass").toString();
        data.id = QFileInfo(filePath).fileName();

        settings.endGroup();

        // Parse Desktop Actions
        settings.beginGroup("Desktop Entry");
        QString actionsStr = settings.value("Actions").toString();
        settings.endGroup();

        QStringList actionIds = actionsStr.split(';', Qt::SkipEmptyParts);

        for (const QString& actionId : actionIds) {
            QString groupName = "Desktop Action " + actionId;
            if (settings.childGroups().contains(groupName)) {
                settings.beginGroup(groupName);

                QString actionName = parseLocalizedKey(settings, "Name");
                QString actionExec = settings.value("Exec").toString();
                QString actionIcon = settings.value("Icon").toString();

                auto* action = new DesktopAction(
                    actionId, actionName, actionExec, actionIcon, nullptr
                );
                data.actions.append(action);

                settings.endGroup();
            }
        }

        return data;
    }

} // namespace quicksearch::models
