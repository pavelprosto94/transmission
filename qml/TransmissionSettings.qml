/*  ImgItem.qml */
import QtQuick 2.7
import QtQuick.Controls 2.2
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3
import io.thp.pyotherside 1.3

Page { 
  id: root
    signal settingsshow
    signal transmissionremove

    onSettingsshow:{
      python.call('main.getsettings', [], function(returnValue) {
        var ind=-1
        for (var i = 0; i < speedActions.length; i++)  {
          if (speedActions[i]==returnValue[0]){
            ind=i;
            break;
        }}
        myDialog.text+=returnValue[0]+"\n"
        if (ind>-1){ sections1.selectedIndex=ind; }
        ind=-1
        for (var i = 0; i < speedActions.length; i++)  {
          if (speedActions[i]==returnValue[1]){
            ind=i;
            break;
        }}
        if (ind>-1){ sections2.selectedIndex=ind; }
        selector1.selectedIndex=returnValue[2]
      });
    }
header: PageHeader {
        title: i18n.tr("Settings")
    }
    property var speedActions: [
        "64 kB/s", "128 kB/s", "256 kB/s", "512 kB/s", "768 kB/s", "1 mB/s", "2 mB/s", "no limit"
    ]
Flickable {
    clip: true
    anchors{
          top: root.header.bottom
          left: parent.left
          right: parent.right
          bottom: okButton.top
        }
      contentWidth: rectRoot.width
      contentHeight: rectRoot.height
  
  Rectangle {
    id :rectRoot
        width: root.width
        height: {childrenRect.height+units.gu(4)}
        color: theme.palette.normal.background
        
    Text {
        id: label1
        text: i18n.tr("Downlimit")
        color: theme.palette.normal.backgroundText
        font.pixelSize: units.gu(2)
        anchors{
          top: parent.top
          topMargin: units.gu(2)
          left: parent.left
          leftMargin: units.gu(2)
        }
    }
    Sections {
        id: sections1
        selectedIndex: 0
        anchors{
          top: label1.bottom
          left: parent.left
          leftMargin: units.gu(2)
          right: parent.right
          rightMargin: units.gu(2)
          }
        model: speedActions
        width: parent.width
      }
    Text {
        id: label2
        text: i18n.tr("Uplimit")
        color: theme.palette.normal.backgroundText
        font.pixelSize: units.gu(2)
        anchors{
          top: sections1.bottom
          topMargin: units.gu(2)
          left: parent.left
          leftMargin: units.gu(2)
        }
    }
    Sections {
        id: sections2
        selectedIndex: 0
        anchors{
          top: label2.bottom
          left: parent.left
          leftMargin: units.gu(2)
          right: parent.right
          rightMargin: units.gu(2)
          }
        model: speedActions
      }
    Text {
        id: label3
        text: i18n.tr("Encryption")
        color: theme.palette.normal.backgroundText
        font.pixelSize: units.gu(2)
        anchors{
          top: sections2.bottom
          topMargin: units.gu(2)
          left: parent.left
          leftMargin: units.gu(2)
        }
    }
    property var encryptionmodel: [
        i18n.tr("Encrypt all peer connections"),
        i18n.tr("Prefer encrypted peer connections"),
        i18n.tr("Prefer unencrypted peer connections")
        ]

    OptionSelector {
        id: selector1
        model: parent.encryptionmodel
        selectedIndex: 0
        anchors{
          top: label3.bottom
          topMargin: units.gu(1)
          left: parent.left
          leftMargin: units.gu(2)
          right: parent.right
          rightMargin: units.gu(2)
        }
    }
    OpenButton{
  id: removeTransmission
  anchors{
    top: selector1.bottom
    topMargin: units.gu(2)
    left: parent.left
    leftMargin: units.gu(2)
    right: parent.right
    rightMargin: units.gu(2)
  }
    iconName: "delete"
    text: i18n.tr("Remove Transmission library")
    colorBut: UbuntuColors.red
    colorButText: "white"
    onClicked: {
      root.transmissionremove()
    }
    
  }
}}
OpenButton{
  id: okButton
  anchors{
    left: parent.left
    leftMargin: units.gu(2)
    bottom: parent.bottom
    bottomMargin: units.gu(1.5)
  }
  width: units.gu(16)
  colorBut: UbuntuColors.green
  colorButText: "white"
  iconOffset: true
  iconName: "document-save"
  text: i18n.tr("Save")
    onClicked: {
      var ans=[speedActions[sections1.selectedIndex],speedActions[sections2.selectedIndex],selector1.selectedIndex]
      stack.pop()
      python.call('main.savesettings', [ans], function() {});
    }
  }
OpenButton{
  id: cancelButton
  anchors{
    right: parent.right
    rightMargin: units.gu(2)
    bottom: parent.bottom
    bottomMargin: units.gu(1.5)
  }
  width: units.gu(16)
  iconOffset: true
  iconName: "close"
  text: i18n.tr("Cancel")
    onClicked: {
      stack.pop()
    }
  }
}