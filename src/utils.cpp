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

#include <QDir>
#include <QDebug>

#include "utils.h"

#include <algorithm>

QStringList Utils::pathsToHome()
{
    QStringList paths;
    QString pathToHome = QDir::homePath();
    QDir tmp;

    if (pathToHome.isEmpty() || !tmp.exists(pathToHome)) {
        qWarning() << Q_FUNC_INFO << "Home path empty or nonexistent: " << pathToHome;
#ifdef Q_OS_UNIX
        pathToHome = QLatin1String("/");
#else
#error "only ported to UNIX at present"
#endif
    }

    QDir d(pathToHome);

    if (!d.isReadable()) {
        qWarning() << Q_FUNC_INFO << "Home path " << pathToHome << " not readable";
#ifdef Q_OS_UNIX
        pathToHome = QLatin1String("/");
#else
#error "only ported to UNIX at present"
#endif
        d = QDir(pathToHome);

        // if / isn't readable, we're all going to die anyway
    }

    do {
        paths.append(d.path());
    } while (d.cdUp());

    // get them in order for QML to instantiate things from
    std::reverse(paths.begin(), paths.end());

    qDebug() << Q_FUNC_INFO << paths;
    return paths;
}
