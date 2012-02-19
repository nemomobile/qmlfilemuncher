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

#include <QFile>
#include <QCryptographicHash>
#include <QDebug>
#include <QDesktopServices>
#include <QDir>
#include <QImageReader>

#include "filethumbnailprovider.h"

static inline void setupCache(const QString &baseCachePath)
{
    // the syscalls make baby jesus cry; but this protects us against sins like users
    QDir d(baseCachePath);
    if (!d.exists())
        d.mkpath(baseCachePath);
    if (!d.exists("raw"))
        d.mkdir("raw");

    // in the future, we might store a nicer UI version which can blend in with our UI better, but
    // we'll always want the raw version.
}

static inline QByteArray cacheKey(const QString &id, const QSize &requestedSize)
{
    QByteArray baId = id.toLatin1(); // is there a more efficient way than a copy?

    // check if we have it in cache
    QCryptographicHash hash(QCryptographicHash::Sha1);

    hash.addData(baId.constData(), baId.length());
    return hash.result().toHex() + "nemo";
}

QImage FileThumbnailImageProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    qDebug() << Q_FUNC_INFO << "Requested image: " << id;
    QSize actualSize;

    if (requestedSize.isValid())
        actualSize = requestedSize;
    else
        actualSize = QSize(64, 64);

    if (size)
        *size = actualSize;

    QByteArray hashData = cacheKey(id, actualSize);

    QString cachePath = QDesktopServices::storageLocation(QDesktopServices::CacheLocation) + ".nemothumbs";
    setupCache(cachePath);

    QFile fi(cachePath + QDir::separator() + "raw" + QDir::separator() + hashData);
    if (fi.exists() && fi.open(QIODevice::ReadOnly)) {
        // cached file exists! hooray.
        qDebug() << Q_FUNC_INFO << "Read " << id << " from cache";
        QImage img;
        img.load(&fi, "JPG");
        qDebug() << img.size();
        return img;
    } else {
        // slow path: read image in, scale it, write to cache, return it
        QImageReader ir(id);
        QImage img = ir.read();
        if (img.size() != actualSize) {
            // TODO: we should probably handle cropping here too to get better results
            qDebug() << Q_FUNC_INFO << "Wrote " << id << " to cache";
            img = img.scaled(actualSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);

            if (fi.open(QIODevice::WriteOnly)) {
                img.save(&fi, "JPG");
                fi.flush();
                fi.close();
            } else {
                qWarning() << "Couldn't cache " << id << " to " << fi.fileName();
            }

            return img;
        } else {
            return img;
        }
    }

    // should be unreachable
    Q_ASSERT(false);
    return QImage();
}
