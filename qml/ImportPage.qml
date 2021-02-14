/*
 * Copyright (C) 2016 Stefano Verzegnassi
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License 3 as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see http://www.gnu.org/licenses/.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Content 1.3

Page {
    id: picker
    signal cancel()
    signal imported(string fileUrl)

    header: PageHeader {
        title: i18n.tr("    Import .torrent file from:")
        Icon{
            anchors{
                left: parent.left
                top: parent.top
                topMargin: units.gu(1.5)
                bottom: parent.bottom
                bottomMargin: units.gu(1.5)
            }
            width: height
            name: "go-previous"
            color: theme.palette.normal.backgroundText
        }
        MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked:{ 
        stack.pop()
        }
        }
    }

    ContentPeerPicker {
            id: contentPicker
            anchors {
            fill: parent
            topMargin: picker.header.height
        }
            visible: parent.visible
            showTitle: false
            contentType: ContentType.Documents
            handler: ContentHandler.Source

            onPeerSelected: {
                stack.pop()
                peer.selectionType = ContentTransfer.Single
                peer.request()
            }
        
            onCancelPressed: {
                stack.pop()
            }
        }

        ContentTransferHint {
            id: importHint
            anchors.fill: parent
            activeTransfer: mainView.activeTransfer
        }
}
