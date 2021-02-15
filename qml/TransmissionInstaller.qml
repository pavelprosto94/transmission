/*  CalculatorButton.qml */
import QtQuick 2.7
import Ubuntu.Components 1.3
import io.thp.pyotherside 1.3
import Ubuntu.Components.Themes 1.3

Item {
    id: root
    signal insfinished
    property string procalarm: ""
    property alias text: label.text
    property alias button: installbut.text
    property real   progressvalue: 0
        Rectangle {
            id: mainRec
            width: units.gu(40)
            height: units.gu(25)
            anchors{
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
            color: theme.palette.normal.background
            radius: units.gu(1)
            border.width: units.gu(0.25)
            border.color: theme.palette.normal.foreground
        Image {
            id: img
            fillMode: Image.PreserveAspectFit
            height: units.gu(8)
            source: "../src/img/transmission_up.png"
            anchors{
                margins: units.gu(1)
                top: parent.top
                left: parent.left
                right: parent.right
                }
        }
        Text {
            id: label
            text: {i18n.tr("Transmission not installed")+procalarm}
            anchors{
                margins: units.gu(1)
                top: img.bottom
                left: parent.left
                right: parent.right
                bottom: progress.top
                }
            horizontalAlignment: Label.AlignHCenter
            font.pixelSize: units.gu(2)
            padding: units.gu(1)
            wrapMode : Text.WordWrap
            color: theme.palette.normal.backgroundText
        }
        Rectangle {
        id: progress
        height: units.gu(2)
        color: theme.palette.normal.background
        anchors{
            bottom: installbut.top
            bottomMargin: units.gu(1)
            left: parent.left
            leftMargin: units.gu(1)
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
            color: "#E95420"
            anchors{
                rightMargin: parent.width/100*(100-root.progressvalue)
                fill: parent
            }
            border.width: units.gu(0.5)
            radius: units.gu(1.5)
            border.color: theme.palette.normal.background
        }
        }
        Button {
        id: installbut
        property int stat:0
        text: i18n.tr("Install")
        color: UbuntuColors.green
        anchors{
            right: parent.right
            rightMargin: units.gu(2)
            bottom: parent.bottom
            bottomMargin: units.gu(1)
        }
        onClicked: {
            if (stat==0)
            {
                mainRec.height=units.gu(25)
                stat=1
                installbut.text=i18n.tr("Wait ...")
                pythoninst.call('installer.install', [], function() {
                    stat=2
                });
            }
            if (stat==3){
               root.insfinished()
               label.text=i18n.tr("Transmission not installed")+procalarm
               installbut.text=i18n.tr("Install")
               installbut.stat=0
            }
        }
        }
    }
    Python {
            id: pythoninst
            property string tmpn: "";
            Component.onCompleted: {
                addImportPath(Qt.resolvedUrl('../src/'));
                setHandler('progressinstaller', function(returnValue) {
                    root.progressvalue=returnValue[0]
                    root.text=returnValue[1]
                });
                setHandler('finishedinstaller', function(returnValue) {
                    root.progressvalue=returnValue[0]
                    root.text=returnValue[1]
                    installbut.stat=3
                    installbut.text=i18n.tr("Close")
                });
                importModule('installer', function () {
                    pythoninst.call('installer.checkproc', [], function(ret) {
                        //myDialog.text = ret
                        //myDialog.visible = true;
                    });
                });
            }
            onError: {
                myDialog.text = 'python error: ' + traceback
                myDialog.visible = true;
                console.log('python error: ' + traceback);
            }
        }
}