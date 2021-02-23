import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3

Item {
id: root
height: menubut.heightAnim
width: units.gu(16)

Rectangle {
    id: menubut
    height: units.gu(4)
    width: units.gu(4)
    color: theme.palette.normal.background
    anchors{
        right: root.right
        top: root.top
        topMargin: units.gu(1)
    }
    Icon {
        id: icon
        anchors{
            fill: parent
            margins: units.gu(0.5)
        }
        color: theme.palette.normal.backgroundText
        name : "contextual-menu"
    }
    property real heightAnim: units.gu(5)
    MouseArea {
          id: menumouse
          anchors.fill: parent
          onClicked: {
              if (parent.heightAnim > units.gu(5.5))
              {anim2w.start();}
              else
              {anim1w.start();}
          }
    }

NumberAnimation on heightAnim {
    id: anim2w
    from: parent.heightAnim; to: units.gu(5);
    }
NumberAnimation on heightAnim {
    id: anim1w
    from: parent.heightAnim; to: units.gu(20);
    }
}

OpenButton{
            id: donateButton
            anchors{
                right: root.right
                left: root.left
                top: menubut.bottom
                topMargin: units.gu(1.5)
            }
            iconOffset: true
            radiusBorder: units.gu(1.5)
            iconName: "like"
            text: i18n.tr("Donate");
            visible: {
                if (root.height<units.gu(10))
                {false}
                else
                {true}
            }
            opacity: {
                if (root.height<units.gu(10)) 
                {0.0}
                else if (root.height>units.gu(15))
                {1.0}
                else
                {(root.height-units.gu(10))/units.gu(5)}   
            }
            onClicked: {
                Qt.openUrlExternally("https://liberapay.com/pavelprosto/")
                anim2w.start();
            }
    }

OpenButton{
            id: settingsButton
            anchors{
                right: root.right
                left: root.left
                top: donateButton.bottom
                topMargin: units.gu(1)
            }
            iconOffset: true
            radiusBorder: units.gu(1.5)
            iconName: "settings"
            text: i18n.tr("Settings");
            visible: {
                if (root.height<units.gu(15))
                {false}
                else
                {true}
            }
            opacity: {
                if (root.height<units.gu(15)) 
                {0.0}
                else if (root.height>=units.gu(20))
                {1.0}
                else
                {(root.height-units.gu(15))/units.gu(5)}   
            }
        onClicked: {
            settingsPage.settingsshow()
            stack.push(settingsPage)
            anim2w.start();
        }
    }
}
