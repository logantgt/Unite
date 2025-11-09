#pragma once
#include <QObject>
#include <QStringList>
#include <QtQml/qqml.h>

class QuickSearch : public QObject {
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged)
    Q_PROPERTY(QStringList paths READ paths WRITE setPaths NOTIFY pathsChanged)

public:
    explicit QuickSearch(QObject *parent = nullptr) : QObject(parent) {}
    QString query() const { return m_query; }
    QStringList paths() const { return m_paths; }

    void setQuery(const QString &qry) { m_query = qry; emit queryChanged(); }
    void setPaths(const QStringList &pths) { m_paths = pths; emit pathsChanged(); }

signals:
    void queryChanged();
    void pathsChanged();

private:
    QString m_query;
    QStringList m_paths;
};
