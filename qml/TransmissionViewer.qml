/*  ImgItem.qml */
import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3
import io.thp.pyotherside 1.3
import Ubuntu.Content 1.3

Item {
  id: root
    property string name: ""
    property string adress: ""
    property string status: ""
    property string fullstatus: ""
    property string icon: ""
    property real   progressvalue: 50
    property int    indx: -1
    signal insfinished
    signal torrentpause
    signal torrentresume
    signal torrentremove
    signal torrentshow

    onTorrentshow:{
      listModel.clear()
      python2.call('viewer.readfiles', [adress], function() {});
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
        Icon {
        id: icon2
        anchors{
            left: parent.left
            leftMargin: units.gu(1)
            top: parent.top
            topMargin: units.gu(2)
            bottom: parent.bottom
            bottomMargin: units.gu(1.5)
        }
        color: theme.palette.normal.backgroundText
        name : "back"
        width: units.gu(4)
        }
        Text {
            text: i18n.tr("Torrent info")
            anchors{
                topMargin: units.gu(1)
                top: parent.top
                left: icon2.right
                }
            verticalAlignment: Label.AlignVCenter
            font.pixelSize: units.gu(2.5)
            padding: units.gu(1)
            wrapMode : Text.WordWrap
            color: theme.palette.normal.backgroundText
        }
        MouseArea {
          id: mouseArea
          anchors.fill: parent
          onClicked: {root.insfinished()}
        }
        Rectangle {
                height: units.gu(0.1)
                color: theme.palette.normal.base
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
            }
    }
Rectangle {
  id: infoitem
        clip: true
        radius: units.gu(0.5)
        border.width: units.gu(0.1)
        color: theme.palette.normal.background
        border.color: theme.palette.normal.base
        height: units.gu(9)
        anchors{
          margins: units.gu(1)
          top: headwin.bottom
          left: parent.left
          right: parent.right
        }

    Image {
      id: img
      fillMode: Image.PreserveAspectFit
      width: units.gu(8)
      height: units.gu(6)
      source: {
        if (root.icon=="_up") {
            "../src/img/transmission_up.png"
          }else
          if (root.icon=="_share") {
            "../src/img/transmission_share.png"
          }else
          {
            "../src/img/transmission_down.png"
          }
      }
      anchors{
          margins: units.gu(1)
          top: parent.top
          left: parent.left
        }
    }

    Text {
        id: label
        text: root.name
        color: theme.palette.normal.backgroundText
        font.pixelSize: units.gu(2)
        clip: true
        anchors{
          top: parent.top
          topMargin: units.gu(1.5)
          left: img.right
          right: parent.right
          rightMargin: units.gu(1)
        }
        verticalAlignment: Text.AlignVCenter
    }
    Rectangle {
        id: progress
        height: units.gu(2)
        color: theme.palette.normal.background
        anchors
        {
        top: label.bottom
        left: img.right
        right: parent.right
        rightMargin: units.gu(1)
        }
        Rectangle {
            color: "#AEA79F"
            anchors.fill: parent
            border.width: units.gu(0.5)
            radius: units.gu(1)
            border.color: theme.palette.normal.background
        }    
        Rectangle {
            id: progressbar1
            color: {
            if (icon=="_up") {
            UbuntuColors.orange
          }else
          if (icon=="_share") {
            UbuntuColors.green
          }else
          {
            "#888"
          }}
            anchors{
                rightMargin: parent.width/100*(100-root.progressvalue)
                fill: parent
            }
            border.width: units.gu(0.5)
            radius: units.gu(1.5)
            border.color: theme.palette.normal.background
        }
    }

    Text {
        id: labelstatus
        color: theme.palette.normal.backgroundSecondaryText
        text: root.fullstatus
        font.pixelSize: units.gu(1)
        clip: true
        anchors{
          top: progress.bottom
          left: img.right
          right: parent.right
          rightMargin: units.gu(1)
        }
        wrapMode : Text.WordWrap
        verticalAlignment: Text.AlignVCenter
    }
}

OpenButton{
  id: statButton
  anchors{
    top: infoitem.bottom
    left: parent.left
    right: parent.right
    margins : units.gu(1);
  }
    iconName: {
    if (root.icon=="_down") {
      "media-playback-start"
    }else{
      "media-playback-pause"
      }}
    text: {
    if (root.icon=="_down") {
      i18n.tr("Resume torrent")
    }else{
      i18n.tr("Pause torrent")
      }}
    onClicked: {
      if (root.icon=="_down") {
      root.torrentresume()
    }else{
      root.torrentpause()
      }
    }
  }
OpenButton{
  id: removeButton
  anchors{
    top: statButton.bottom
    left: parent.left
    right: parent.right
    margins : units.gu(1);
  }
    iconName: "delete"
    text: i18n.tr("Remove torrent")
    colorBut: UbuntuColors.red
    colorButText: "white"
    onClicked: {
      root.torrentremove()
    }
  }
UbuntuShape {
  backgroundColor: theme.palette.normal.foreground
  anchors{
          top: removeButton.bottom
          topMargin: units.gu(1.5)
          left: parent.left
          right: parent.right
          bottom: parent.bottom
        }
  aspect: UbuntuShape.Inset
  
Text {  
      id: labelFiles  
      text: i18n.tr("Files:")
      color: theme.palette.normal.foregroundText
      font.pixelSize: units.gu(2)
        anchors{
          top: parent.top
          topMargin: units.gu(0.5)
          left: parent.left
          leftMargin: units.gu(2)
        }
    }

ListView {
            id: grig
            clip: true
            anchors{
                top: labelFiles.bottom;
                bottom: parent.bottom;
                left: parent.left;
                right: parent.right;
                margins : units.gu(1);
            }
            spacing: units.gu(0.5)
            model: listModel
            delegate: FileItem {
                name: nam
                adress: adr
                image: ico
                onClicked:{
                  if (ico=="package-x-generic-symbolic"){
                    myDialog.text = i18n.tr("File is not ready.\nWait for the download to finish.")
                    myDialog.visible = true;
                  }else{
                    exportPage.url=adr
                    stack.push(exportPage)
                  }
                }
            }
        }
      }
        ListModel{
            id:listModel
        }

Python {
            id: python2
            property string tmpn: "";
            Component.onCompleted: {
                addImportPath(Qt.resolvedUrl('../src/'));
                setHandler('progressviewer', function(returnValue) {
                    var newItem = {}
                    newItem.adr = returnValue[0]
                    newItem.nam = returnValue[1]
                    newItem.ico = returnValue[2]
                    listModel.append(newItem)
                });
                importModule('viewer', function () {});
            }
            onError: {
                myDialog.text = 'python error: ' + traceback
                myDialog.visible = true;
                console.log('python error: ' + traceback);
            }
        }
}