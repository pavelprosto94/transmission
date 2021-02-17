import QtQuick 2.4
import Ubuntu.Components 1.3

Item {
id: root
property bool ready: false
Rectangle {
anchors.fill: parent
color: "#222"
gradient: Gradient {
        GradientStop { position: 0.0; color: "#222" }
        GradientStop { position: 0.83; color: "#222" }
        GradientStop { position: 1.0; color: "#552a1d" }
    }

Image {
      id: img
      fillMode: Image.PreserveAspectFit
      anchors.fill: parent
      source: "../src/img/compliment.svg"
      Text {
        id: label
        text: {randomaboutName()}
        font.pixelSize: units.gu(3)
        color: "#db461b"
        anchors{
          centerIn: parent
          verticalCenterOffset: units.gu(16)
        }
        function randomaboutName()
        {
        var aboutName = new Array (
                "Joan CiberSheep",
                "Brian Douglass",
                "@PhoenixLandPirat",
                "@DOBEY",
                "@MATTEO"
                )
        var ind = Math.floor(aboutName.length * Math.random());
        return aboutName[ind]
        }
    }
    }
Timer {
        interval: 2000; 
        running: root.visible; 
        onTriggered: {
          root.ready=true
          if (mainView.ready==true)
          {
            stack.push(mainView)
          }
        }
    }
}
}