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
    height: units.gu(8)

    property string name: "Name file"
    property string adress: ""
    property string status: ""
    property string fullstatus: ""
    property string icon: ""
    property real   progressvalue: 50
    property int    indx: -1
    Image {
      id: img
      fillMode: Image.PreserveAspectFit
      width: units.gu(8)
      height: units.gu(6)
      source: {
        if (icon=="_up") {
            "../src/img/transmission_up.png"
          }else
          if (icon=="_share") {
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
        text: name
        font.pixelSize: units.gu(2)
        clip: true
        color: theme.palette.normal.backgroundText
        anchors{
          top: parent.top
          topMargin: units.gu(1.5)
          left: img.right
          right: parent.right
          rightMargin: units.gu(1)
        }
        //wrapMode : Text.WordWrap
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
        text: status
        font.pixelSize: units.gu(1)
        color: theme.palette.normal.backgroundSecondaryText
        clip: true
        anchors{
          top: progress.bottom
          left: img.right
          right: parent.right
          rightMargin: units.gu(1)
        }
        //wrapMode : Text.WordWrap
        verticalAlignment: Text.AlignVCenter
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
        onClicked: {
          parent.clicked()
        }
    }
}