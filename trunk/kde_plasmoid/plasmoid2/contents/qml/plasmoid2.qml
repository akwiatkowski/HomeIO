import Qt 4.7
import QtWebKit 1.0
import QtQuick 1.0
import "." 1.0


Item {
    width: 300
    height: 300
    Component.onCompleted: {
        refreshMeasurements();
    }

    Text {
        id: measText
        anchors { top: refreshButton.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        text: "Measurements"

    }

    MouseArea {
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 20
        id: refreshButton

        onClicked: {
            console.log('clicked')
            refreshMeasurements();
        }

        Text {

            text: "Refresh"
            anchors { left: parent.left; right: parent.right; top: parent.top }
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
                /*
                showRequestInfo("Headers -->");
                showRequestInfo(doc.getAllResponseHeaders ());
                showRequestInfo("Last modified -->");
                showRequestInfo(doc.getResponseHeader ("Last-Modified"));
                */
            } else if (doc.readyState == XMLHttpRequest.DONE)  {
                /*
                var a = doc.responseXML.documentElement;
                for (var ii = 0; ii < a.childNodes.length; ++ii)  {
                    showRequestInfo(a.childNodes[ii].nodeName);
                }
                */

                /*
                showRequestInfo("Headers -->");
                showRequestInfo(doc.getAllResponseHeaders ());
                showRequestInfo("Last modified -->");
                showRequestInfo(doc.getResponseHeader ("Last-Modified"));

                console.log("****");
                console.log(doc.responseText);
                console.log("****");
                */

                //wv.html = doc.responseText;
                measText.text =  doc.responseText;

            }
        }

        doc.open("GET", "http://lakie.waw.pl:24/meas_caches.txt?auth_token=UXcJt42xRGYpGDRpJLtv");
        doc.send();
    }

    Timer  {
        id: timy
        interval: 60000; running: true; repeat: true
        onTriggered: {
            refreshMeasurements()

        }
    }
}
