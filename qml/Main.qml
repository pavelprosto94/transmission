/*
 * Copyright (C) 2021  Pavel Prosto
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * transmission is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import Ubuntu.Components 1.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3
import Ubuntu.Content 1.3
import QtQuick.Window 2.2
import Ubuntu.Components.Themes 1.3

Window {
    id: root
    width: units.gu(45)
    height: units.gu(75)
    color: theme.palette.normal.background
    title: 'Transmission'
    property string torrentpath: ""
    
    Component.onCompleted: {
    i18n.domain = "transmission.pavelprosto"
    }

    StackView {
        id: stack
        initialItem: complimentView
        anchors.fill: parent
    }

    ComplimentScreen
    {
        id: complimentView
    }
    
    Item {
        id: mainView
        visible:false
        property var activeTransfer
        property bool ready: false

        ListView {
            id: grig
            clip: true
            anchors{
                top: headwin.bottom;
                bottom: parent.bottom;
                left: parent.left;
                right: parent.right;
                margins : units.gu(1);
            }
            property bool enablScroll: true
            interactive: enablScroll
            spacing: units.gu(0.5)
            model: listModel
            delegate: TransmissionItem {
                name: nam
                adress: adr
                status: st
                fullstatus: fullst
                icon: ico
                progressvalue: prval
                indx: ind
                onClicked:{
                    transmissionViewer.name = nam
                    transmissionViewer.adress = adr
                    transmissionViewer.fullstatus = fullst
                    transmissionViewer.icon = ico
                    transmissionViewer.progressvalue = prval
                    transmissionViewer.indx = ind     
                    stack.push(transmissionViewer)
                    transmissionViewer.torrentshow()      
                }
            }
        }
        ListModel{
            id:listModel
        }
        Text {
                id: clearlabel
                text: i18n.tr("Torrents list is emty.\nClick \"+\" to start new Torrent");
                color: theme.palette.normal.backgroundText;
                visible: false;
                anchors{
                top: headwin.bottom;
                bottom: parent.bottom;
                left: parent.left;
                right: parent.right;
                margins : units.gu(1);
                }
                verticalAlignment: Label.AlignVCenter
                horizontalAlignment: Label.AlignHCenter
                font.pixelSize: units.gu(2)
                padding: units.gu(1)
                wrapMode : Text.WordWrap
        }
        Rectangle {
        id: headwin
        anchors{
        top: parent.top;
        left: parent.left;
        right: parent.right;
        }
        color: theme.palette.normal.background    
        height: units.gu(6);
        Text {
            text: root.title
            anchors{
                margins: units.gu(1)
                top: parent.top
                left: parent.left
                }
            verticalAlignment: Label.AlignVCenter
            font.pixelSize: units.gu(2.5)
            padding: units.gu(1)
            wrapMode : Text.WordWrap
            color: theme.palette.normal.backgroundText
        }
            Rectangle {
                height: units.gu(0.1)
                color: theme.palette.normal.base
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
            }
            MenuProg {
                id: programmenu
                anchors{
                right: parent.right
                rightMargin: units.gu(2)
                top: parent.top
                //topMargin: units.gu(1.5)
                }  
            }
            OpenButton{
                id: openButton
                anchors{
                    top: parent.top
                    topMargin : units.gu(0.5);
                    right: parent.right
                    rightMargin: units.gu(6.5)
                    margins : units.gu(1);
                }
                iconName: "add"
                width: units.gu(6)
                colorBut: theme.palette.normal.background
                aspectBorder: UbuntuShape.Flat
                colorButText: theme.palette.normal.backgroundText
                onClicked: {
                    stack.push(importPage)
                }
            }
        }
        Connections {
            id: torrentimport
            target: ContentHub
            property var activeConTransfer
            onImportRequested: {
                console.log("try add:"+transfer.items[0].url.toString())
                torrentimport.activeConTransfer=transfer
                python.call('main.movefile', [torrentimport.activeConTransfer.items[0].url.toString()], function(returnValue) {
                if (returnValue==1){
                    if (root.torrentpath==""){
                        python.call('main.gettorrentpath', [], function(returnValue) {
                        root.torrentpath=returnValue
                        torrentimport.activeConTransfer.items[0].move(root.torrentpath)
                        python.init_transmission();
                        torrentimport.activeConTransfer.finalize()
                        });
                    }else{
                    torrentimport.activeConTransfer.items[0].move(root.torrentpath)
                    python.init_transmission();
                    torrentimport.activeConTransfer.finalize()
                    }
                } else if (returnValue==-1)
                {
                    myDialog.text = i18n.tr("The torrent you are trying to add is already in the list.")
                    myDialog.visible = true;
                    torrentimport.activeConTransfer.finalize()
                }else{    
                    myDialog.text = i18n.tr("It's not torrent file.")
                    myDialog.visible = true;
                    torrentimport.activeConTransfer.finalize()
                }
                });
            }
        }
        Python {
            id: python
            property string tmpn: "";
            Component.onCompleted: {
                addImportPath(Qt.resolvedUrl('../src/'));
                setHandler('add', function(returnValue) {
                    if (root.torrentpath!=""){
                    var newItem = {}
                    newItem.ind=returnValue[0]
                    newItem.adr=returnValue[1]
                    newItem.nam=returnValue[2]
                    newItem.st=returnValue[3]
                    newItem.fullst=returnValue[4]
                    newItem.ico=returnValue[5]
                    newItem.prval=returnValue[6]
                    listModel.append(newItem)
                    }
                });
                setHandler('progress', function(returnValue) {
                    var ind=-1
                    for (var i = 0; i < listModel.count; i++)  {
                        if (String(listModel.get(i).ind)==String(returnValue[0]))
                        {
                            ind=i;
                            break;
                        }
                    }
                    if (ind>-1){
                        listModel.get(ind).st=returnValue[1]
                        listModel.get(ind).fullst=returnValue[2]
                        listModel.get(ind).ico=returnValue[3]
                        listModel.get(ind).prval=returnValue[4]
                        if (transmissionViewer.indx == ind)
                        {
                            transmissionViewer.fullstatus = returnValue[2]
                            transmissionViewer.icon = returnValue[3]
                            transmissionViewer.progressvalue = returnValue[4]
                        }
                    }
                });
                setHandler('removeitem', function(returnValue) {
                    var ind=-1
                    for (var i = 0; i < listModel.count; i++)  {
                        if (String(listModel.get(i).ind)==String(returnValue))
                        {
                            ind=i;
                            break;
                        }
                    }
                    if (ind>-1){
                        listModel.remove(ind)
                        if (listModel==null){
                        clearlabel.visible=true
                        } else
                        if (listModel.count==0){
                        clearlabel.visible=true
                    }
                    }
                });
                setHandler('progress_sh', function(returnValue) {
                    var ind=-1
                    for (var i = 0; i < listModel.count; i++)  {
                        if (String(listModel.get(i).ind)==String(returnValue[0]))
                        {
                            ind=i;
                            break;
                        }
                    }
                    if (ind>-1){
                        listModel.get(ind).ico=returnValue[1]
                        listModel.get(ind).st=returnValue[2]
                        listModel.get(ind).fullst=returnValue[2]
                        if (transmissionViewer.indx == ind)
                        {
                            transmissionViewer.fullstatus = returnValue[2]
                            transmissionViewer.icon = returnValue[1]
                        }
                    }
                });
                setHandler('finished', function() {
                    if (listModel==null){
                        console.log("list empty")
                        clearlabel.visible=true
                    } else
                    if (listModel.count==0){
                        console.log("list empty")
                        clearlabel.visible=true
                    }
                });
                setHandler('error', function(returnValue) {
                    myDialog.text = returnValue
                    myDialog.visible = true;
                });
                importModule('main', function () {
                    init_transmission()
                });
            }
            onError: {
                myDialog.text = 'python error: ' + traceback
                myDialog.visible = true;
                console.log('python error: ' + traceback);
            }
            function init_transmission(){
                clearlabel.visible=false
                    call('main.check_transmission', [], function(returnValue) {
                    if (returnValue==true){
                        call('main.gettorrentpath', [], function(returnValue) {
                        root.torrentpath=returnValue
                        call('main.slow_function', [], function(returnValue) {
                            mainView.ready=true
                            if (complimentView.ready==true)
                            {
                                stack.push(mainView)
                            }
                        });
                        });
                    }else{
                        stack.push(installerView)
                    }
                    });
            }
        }
    }

    TransmissionInstaller{
        id: installerView
        anchors.fill: parent
        visible: false
        onInsfinished: {
            if (mainView.ready==true)
            {stack.pop()}
            else
            {stack.push(mainView)}
            python.init_transmission();
        }
    }
    TransmissionViewer{
        id: transmissionViewer
        anchors.fill: parent
        visible: false
        property bool enblcon: false
        onInsfinished: {
            stack.pop();
            transmissionViewer.indx=-1;
        }
        onTorrentpause: {
            python.call('main.transmission_stop', [transmissionViewer.indx], function() {});
        }
        onTorrentresume: {
            python.call('main.transmission_resume', [transmissionViewer.indx], function() {});
        }
        onTorrentremove: {
            myDialog.text = i18n.tr("Are you shure remove this torrent and downloaded files?\n") + transmissionViewer.name
            myDialog.okbutton = true;
            myDialog.oktext = i18n.tr("Remove")
            myDialog.visible = true;
            transmissionViewer.enblcon=true
        }
        Connections {
            enabled: transmissionViewer.enblcon
            target: myDialog
            onClicked: { 
            transmissionViewer.enblcon=false
            stack.pop();
            python.call('main.transmission_remove', [transmissionViewer.indx], function() {});
            }
        }
    }
    ExportPage {
    id: exportPage
    anchors.fill: parent
    visible: false
    }
    ImportPage {
    id: importPage
    anchors.fill: parent
    visible: false
    }
    TransmissionSettings {
    id: settingsPage
    anchors.fill: parent
    visible: false
    property bool enblcon: false
    onTransmissionremove:{
        myDialog.text = i18n.tr("Are you shure remove Transmission librory?\n If you wish to continue using this program, you will have to reinstall the library.")
        myDialog.okbutton = true;
        myDialog.oktext = i18n.tr("Remove")
        myDialog.visible = true;
        settingsPage.enblcon=true
      }
    Connections {
            enabled: settingsPage.enblcon
            target: myDialog
            onClicked: { 
            settingsPage.enblcon=false
            stack.pop();
            waitScreen.visible=true
            python.call('main.remove_transmission_lib', [], function() {
                waitScreen.visible=false
                python.init_transmission();
            });
            }
        }
    }
    WaitScreen{
        id: waitScreen
        visible: false
        anchors.fill: parent
    }
    MyDialog {
        id: myDialog
        visible: false
        anchors.fill: parent
    }
}