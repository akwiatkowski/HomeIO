import Qt 4.7
import QtWebKit 1.0
import QtQuick 1.0
import "." 1.0


Item {
    width: 300
    height: 16
    Component.onCompleted: {
        refreshMeasurements();
    }

    MouseArea {
        anchors { top: parent.top; left: parent.left; right: parent.right; bottom: parent.bottom }
        id: refreshButton

        onClicked: {
            console.log('clicked')
            refreshMeasurements();
        }
        
        Text {
	  id: measText
	  anchors { top: parent.top; left: parent.left; right: parent.right; bottom: parent.bottom }
	  text: "Measurements"
	}
    }


    function showRequestInfo(text)  {
        console.log(text)
    }

    function refreshMeasurements() {
        // http://www.w3.org/TR/XMLHttpRequest/#the-responsetext-attribute
        var doc = new XMLHttpRequest();
        doc.onreadystatechange = function()  {
            if (doc.readyState == XMLHttpRequest.HEADERS_RECEIVED)  {
            } else if (doc.readyState == XMLHttpRequest.DONE)  {
                measText.text =  doc.responseText;
            }
        }

        doc.open("GET", "http://lakie.waw.pl:24/meas_type_groups/1/latest.txt?auth_token=ssqpFAzeNLpnqq8ssjaX");
        doc.send();
    }

    Timer  {
        id: timy
        interval: 10000; running: true; repeat: true
        onTriggered: {
            refreshMeasurements()

        }
    }
}
