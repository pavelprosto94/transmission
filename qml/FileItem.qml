/*  ImgItem.qml */
import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3

Rectangle {
        id: root
        signal clicked
        clip: true
        radius: units.gu(0.5)
        border.width: units.gu(0.1)
        color: theme.palette.normal.background
        border.color: theme.palette.normal.base
        width: parent.width
        height: units.gu(6)
    
    property string name: ""
    property string adress: ""
    property alias image: img.name
    Icon {
      id: img
      width: units.gu(4)
      height: units.gu(4)
      name: "folder"
      color: theme.palette.normal.backgroundText
      anchors{
          margins: units.gu(1)
          top: parent.top
          left: parent.left
        }
    }
    Text {
        id: label
        font.pixelSize: units.gu(1.5)
        text: name
        clip: true
        anchors{
          top: parent.top
          topMargin: units.gu(2)
          left: img.right
          leftMargin: units.gu(1)
          right: imgSh.left
          rightMargin: units.gu(1)
        }
        color: theme.palette.normal.backgroundText
        wrapMode : Text.WordWrap
        verticalAlignment: Text.AlignVCenter
    }
    Icon {
      id: imgSh
      width: {
      if (image!="package-x-generic-symbolic")
      {units.gu(3)}
      else
      {units.gu(0)}
      }
      height: units.gu(3)
      name: "document-save"
      color: theme.palette.normal.backgroundText
      anchors{
          topMargin: units.gu(1.5)
          top: parent.top
          right: parent.right
          rightMargin: units.gu(2)
        }
      transform: Rotation {origin.x: units.gu(1.5); origin.y: units.gu(1.5); angle: -90}
    }
    MouseArea {
        id: mouseArea
        anchors{
      top: parent.top
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      rightMargin: units.gu(2)
      }
        onClicked: {parent.clicked()}
    }
}