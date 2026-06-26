import QtQuick 2.15
import calamares 1.0

Presentation {
    id: branding

    Image {
        source: "logo.svg"
        sourceSize.width: 128
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -80
    }

    Text {
        anchors.top: parent.verticalCenter
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Vanta Linux"
        font.family: "Inter"
        font.pointSize: 32
        font.weight: Font.Light
        color: "#f5f5f7"
    }

    Text {
        anchors.top: parent.verticalCenter
        anchors.topMargin: 88
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Minimalist Noir. Unix Power. Zero Visual Debt."
        font.family: "Inter"
        font.pointSize: 14
        color: "#aeaeb2"
    }
}
