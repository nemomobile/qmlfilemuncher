/*
 * Copyright (C) 2012 Robin Burchell <robin+nemo@viroteck.net>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in
 *     the documentation and/or other materials provided with the
 *     distribution.
 *   * Neither the name of Nemo Mobile nor the names of its contributors
 *     may be used to endorse or promote products derived from this
 *     software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

#include <QGuiApplication>
#include <QQuickView>
#include <QtQml>
#include <QThread>
#include <QObject>
#include <QAbstractListModel>
#include <QDebug>
#include <QThread>
#include <QMetaType>
#include <QQmlContext>
#ifdef HAS_BOOSTER
#include <MDeclarativeCache>
#endif

#include "utils.h"

#ifdef HAS_BOOSTER
Q_DECL_EXPORT
#endif
int main(int argc, char **argv)
{
    QGuiApplication *application;
    QQuickView *view;
#ifdef HAS_BOOSTER
    application = MDeclarativeCache::qApplication(argc, argv);
    view = MDeclarativeCache::qQuickView();
#else
    qWarning() << Q_FUNC_INFO << "Warning! Running without booster. This may be a bit slower.";
    QGuiApplication stackApp(argc, argv);
    QQuickView stackView;
    application = &stackApp;
    view = &stackView;
#endif

    QQmlContext *c = view->rootContext();
    c->setContextProperty("fileBrowserUtils", new Utils);

    if (QFile::exists("main.qml"))
        view->setSource(QUrl::fromLocalFile("main.qml"));
    else
        view->setSource(QUrl("qrc:/qml/main.qml"));

    if (QCoreApplication::arguments().contains("-fullscreen")) {
        qDebug() << Q_FUNC_INFO << "Starting in fullscreen mode";
        view->showFullScreen();
    } else {
        qDebug() << Q_FUNC_INFO << "Starting in windowed mode";
        view->show();
    }

    return application->exec();
}
