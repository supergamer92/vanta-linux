import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#0c0c0d"

    Clock {
        id: clock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.15
        color: "#f5f5f7"
        font.family: "Inter"
        font.pointSize: 64
        font.weight: Font.Light
    }

    Text {
        id: dateDisplay
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: clock.bottom
        anchors.topMargin: 8
        color: "#aeaeb2"
        font.family: "Inter"
        font.pointSize: 14
        font.weight: Font.Normal
        text: new Date().toLocaleDateString(Qt.locale(), "dddd, MMMM d")
    }

    Rectangle {
        id: loginContainer
        width: 320
        height: 240
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 40
        color: "#1e1e21"
        radius: 8
        border.color: "#2c2c2e"
        border.width: 1

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 16
            width: parent.width - 48

            Image {
                id: logo
                source: "logo.svg"
                sourceSize.width: 48
                sourceSize.height: 48
                Layout.alignment: Qt.AlignHCenter
            }

            TextField {
                id: username
                Layout.fillWidth: true
                height: 36
                placeholderText: "Username"
                font.family: "Inter"
                font.pointSize: 12
                color: "#f5f5f7"
                background: Rectangle {
                    color: "#171719"
                    radius: 6
                    border.color: username.activeFocus ? "#e66100" : "#2c2c2e"
                    border.width: 1
                }
                leftPadding: 12
            }

            TextField {
                id: password
                Layout.fillWidth: true
                height: 36
                placeholderText: "Password"
                echoMode: TextInput.Password
                font.family: "Inter"
                font.pointSize: 12
                color: "#f5f5f7"
                background: Rectangle {
                    color: "#171719"
                    radius: 6
                    border.color: password.activeFocus ? "#e66100" : "#2c2c2e"
                    border.width: 1
                }
                leftPadding: 12
            }

            Button {
                id: loginButton
                Layout.fillWidth: true
                height: 36
                text: "Sign In"
                font.family: "Inter"
                font.pointSize: 12
                font.weight: Font.Medium
                highlighted: true
                palette.button: "#e66100"
                palette.buttonText: "#ffffff"
                background: Rectangle {
                    color: "#e66100"
                    radius: 6
                }
                onClicked: sddm.login(username.text, password.text, 0)
            }
        }
    }

    Text {
        id: sessionInfo
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        color: "#6e6e73"
        font.family: "Inter"
        font.pointSize: 10
        text: "Vanta Linux"
    }
}
