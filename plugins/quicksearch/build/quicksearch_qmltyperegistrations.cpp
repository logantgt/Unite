/****************************************************************************
** Generated QML type registration code
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <QtQml/qqml.h>
#include <QtQml/qqmlmoduleregistration.h>

#if __has_include(<cachingimagemanager.hpp>)
#  include <cachingimagemanager.hpp>
#endif
#if __has_include(<filesystemmodel.hpp>)
#  include <filesystemmodel.hpp>
#endif
#if __has_include(<quicksearch.h>)
#  include <quicksearch.h>
#endif


#if !defined(QT_STATIC)
#define Q_QMLTYPE_EXPORT Q_DECL_EXPORT
#else
#define Q_QMLTYPE_EXPORT
#endif
Q_QMLTYPE_EXPORT void qml_register_types_QuickSearch()
{
    QT_WARNING_PUSH QT_WARNING_DISABLE_DEPRECATED
    qmlRegisterTypesAndRevisions<QuickSearch>("QuickSearch", 1);
    qmlRegisterTypesAndRevisions<quicksearch::internal::CachingImageManager>("QuickSearch", 1);
    qmlRegisterTypesAndRevisions<quicksearch::models::FileSystemEntry>("QuickSearch", 1);
    qmlRegisterTypesAndRevisions<quicksearch::models::FileSystemModel>("QuickSearch", 1);
    qmlRegisterAnonymousType<QAbstractItemModel, 254>("QuickSearch", 1);
    qmlRegisterEnum<quicksearch::models::FileSystemModel::Filter>("quicksearch::models::FileSystemModel::Filter");
    QT_WARNING_POP
    qmlRegisterModule("QuickSearch", 1, 0);
}

static const QQmlModuleRegistration quickSearchRegistration("QuickSearch", qml_register_types_QuickSearch);
