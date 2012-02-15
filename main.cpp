#include <QApplication>
#include <QDeclarativeView>
#include <QtDeclarative> // XXX: where the fuck does qmlRegisterType live?

#include <QDirIterator>
#include <QDir>
#include <QThread>
#include <QObject>
#include <QAbstractListModel>
#include <QDebug>
#include <QDateTime>

class DirModel : public QAbstractListModel
{
    Q_OBJECT

    enum Roles {
        FileNameRole = Qt::UserRole,
        CreationDateRole,
        ModifiedDateRole,
        FileSizeRole,
        IconSourceRole,
        FilePathRole,
        IsDirRole,
        IsFileRole,
    };

public:
    DirModel(QObject *parent = 0) : QAbstractListModel(parent)
    {
        QHash<int, QByteArray> roles = roleNames();
        roles.insert(FileNameRole, QByteArray("fileName"));
        roles.insert(CreationDateRole, QByteArray("creationDate"));
        roles.insert(ModifiedDateRole, QByteArray("modifiedDate"));
        roles.insert(FileSizeRole, QByteArray("fileSize"));
        roles.insert(IconSourceRole, QByteArray("iconSource"));
        roles.insert(FilePathRole, QByteArray("filePath"));
        roles.insert(IsDirRole, QByteArray("isDir"));
        roles.insert(IsFileRole, QByteArray("isFile"));
        setRoleNames(roles);

        // make sure we cover all roles
        Q_ASSERT(roles.count() == IsFileRole - FileNameRole);
    }

    int rowCount(const QModelIndex &index) const
    {
        if (index.parent() != QModelIndex())
            return 0;

        return mDirectoryContents.count();
    }

    QVariant data(const QModelIndex &index, int role) const
    {
        // make sure we cover all roles
        Q_ASSERT(roles.count() == IsFileRole - FileNameRole);

        if (role < FileNameRole || role > IsFileRole) {
            qWarning() << Q_FUNC_INFO << "Got an out of range role: " << role;
            return QVariant();
        }

        if (index.row() < 0 || index.row() >= mDirectoryContents.count())
            return QVariant();

        if (index.column() != 0)
            return QVariant();

        const QFileInfo &fi = mDirectoryContents.at(index.row());

        switch (role) {
            case FileNameRole:
                return fi.fileName();
            case CreationDateRole:
                return fi.created();
            case ModifiedDateRole:
                return fi.lastModified();
            case FileSizeRole:
                return fi.size();
            case IconSourceRole:
                // not supported; yet.
                if (fi.isDir())
                    return "image://theme/icon-m-common-directory";
                else
                    return "image://theme/icon-m-content-document";
                return QVariant();
            case FilePathRole:
                return fi.filePath();
            case IsDirRole:
                return fi.isDir();
            case IsFileRole:
                return !fi.isDir();
            default:
                // this should not happen, ever
                Q_ASSERT(false);
                qWarning() << Q_FUNC_INFO << "Got an unknown role: " << role;
                return QVariant();
        }
    }

    static bool fileCompare(const QFileInfo &a, const QFileInfo &b)
    {
        if (a.isDir() && !b.isDir())
            return true;

        if (b.isDir() && !a.isDir())
            return false;

        return QString::localeAwareCompare(a.fileName(), b.fileName()) < 0;
    }

    Q_PROPERTY(QString path READ path WRITE setPath NOTIFY pathChanged);
    QString path() const
    {
        return mCurrentDir.path();
    }

    void setPath(const QString &pathName)
    {
        qDebug() << Q_FUNC_INFO << "Changing to " << pathName;

        beginResetModel();
        mDirectoryContents.clear();

        // TODO: I'd like to thread this I/O.
        // Model reset should happen on the UI thread, set the QML to a spinner.
        // I/O thread can go about starting to fetch items, say, max of 50 per
        // 20ms, emit them back to the UI thread.
        //
        // UI thread can keep a spinner until the I/O thread is completely done
        // fetching.
        //
        // Remember to set the priority of the I/O thread to idle, so as to
        // minimize UI starvation.
        //
        // TODO: do we want to monitor for changes, and fetch differences? or
        // just have a 'reload' method.
        QDir tmpDir = QDir(pathName);
        QDirIterator it(tmpDir);
        QVector<QFileInfo> directoryContents;

        while (it.hasNext()) {
            it.next();

            // skip hidden files
            if (it.fileName()[0] == QLatin1Char('.'))
                continue;

            directoryContents.append(it.fileInfo());
        }

        std::sort(directoryContents.begin(), directoryContents.end(), DirModel::fileCompare);

        mCurrentDir = tmpDir;
        mDirectoryContents = directoryContents;
        emit pathChanged();

#ifndef Q_DEBUG_OUTPUT
        qDebug() << Q_FUNC_INFO << "Changed successfully; contents:";
        foreach (const QFileInfo &fi, mDirectoryContents) {
            qDebug() << Q_FUNC_INFO << fi.fileName();
        }
#endif

        endResetModel();
    }

    Q_INVOKABLE void openFile(const QString &path)
    {
        QDesktopServices::openUrl(QUrl::fromLocalFile(path));
    }

signals:
    void pathChanged();

private:
    QDir mCurrentDir;
    QVector<QFileInfo> mDirectoryContents;
};

class Utils : public QObject
{
    Q_OBJECT
public:
    Q_INVOKABLE static QStringList pathsToHome()
    {
        QStringList paths;

#ifdef Q_OS_UNIX
        QByteArray rawPathToHome = qgetenv("HOME");
        QString pathToHome = QFile::decodeName(rawPathToHome);
        QDir tmp;

        if (pathToHome.isEmpty() || !tmp.exists(pathToHome)) {
            qWarning() << Q_FUNC_INFO << "Home path empty or nonexistent: " << rawPathToHome;
            pathToHome = QLatin1String("/");
        }

        QDir d(pathToHome);

        if (!d.isReadable()) {
            qWarning() << Q_FUNC_INFO << "Home path " << pathToHome << " not readable";
            pathToHome = QLatin1String("/");
            d = QDir(pathToHome);

            // if / isn't readable, we're all going to die anyway
        }

        do {
            paths.append(d.path());
        } while (d.cdUp());
#else
#error "only ported to UNIX at present"
#endif

        // get them in order for QML to instantiate things from
        std::reverse(paths.begin(), paths.end());

        qDebug() << Q_FUNC_INFO << paths;
        return paths;
    }

};

int main(int argc, char **argv)
{
    qmlRegisterType<DirModel>("FBrowser", 1, 0, "DirModel");
    QApplication a(argc, argv);

    QDeclarativeView v;

    QDeclarativeContext *c = v.rootContext();
    c->setContextProperty("fileBrowserUtils", new Utils);

    v.setSource(QUrl::fromLocalFile("main.qml"));
    v.show();

    return a.exec();
}

#include "main.moc"
