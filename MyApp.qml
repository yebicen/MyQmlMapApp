/* Copyright 2017 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0
import QtPositioning 5.3
import QtSensors 5.3

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.2
import Esri.ArcGISRuntime.Toolkit.Controls 100.2
import Esri.ArcGISRuntime.Toolkit.Dialogs 100.2

import "controls" as Controls

App {
    id: app
    width: 414
    height: 736
    function units(value) {
        return AppFramework.displayScaleFactor * value
    }
    property real scaleFactor: AppFramework.displayScaleFactor
    property int baseFontSize : app.info.propertyValue("baseFontSize", 15 * scaleFactor) + (isSmallScreen ? 0 : 3)
    property bool isSmallScreen: (width || height) < units(400)

    property Point calloutLocation
    property real xCoor
    property real yCoor

    Page{
        anchors.fill: parent
        header: ToolBar{
            id:header
            width: parent.width
            height: 50 * scaleFactor
            Material.background: "#8f499c"
            Controls.HeaderBar{}
        }

        //starts here ------------------------------------------------------------------
        contentItem: Rectangle{
            anchors.top:header.bottom


            // Create MapView that contains a Map with the Street Basemap
            MapView {
                id: mapView
                anchors.fill: parent
                Map {
                    BasemapStreets {}

                    // start the location display

                    onLoadStatusChanged: {
                        if (loadStatus === Enums.LoadStatusLoaded) {
                            mapView.locationDisplay.autoPanMode = Enums.LocationDisplayAutoPanModeRecenter;
                            mapView.locationDisplay.start();
                        }
                    }
                }

                // set the location display's position source
                locationDisplay {
                    positionSource: PositionSource {
                    }
                    compass: Compass {}
                }


                //! [show callout qml api snippet]
                // initialize Callout
                calloutData {
                    imageUrl: "./assets/RedShinyPin.png"
                    title: "Location"
                    location: calloutLocation
                    detail: "x: " + xCoor + " y: " + yCoor
                }

                Callout {
                    id: callout
                    calloutData: parent.calloutData
                }
                //! [show callout qml api snippet]

                // display callout on mouseClicked
                onMouseClicked: {
                    if (callout.calloutVisible)
                        callout.dismiss()
                    else
                    {
                        calloutLocation = mouse.mapPoint;
                        xCoor = mouse.mapPoint.x.toFixed(2);
                        yCoor = mouse.mapPoint.y.toFixed(2);
                        callout.accessoryButtonHidden = true;
                        callout.showCallout();
                        attachmentWindow.visible = true;
                    }
                }
            } //end of mapview
            
            
            // weather report popout window
            Rectangle {
                id: attachmentWindow
                anchors.centerIn: parent
                height: 200 * scaleFactor
                width: 250 * scaleFactor
                visible: false
                radius: 10
                color: "lightgrey"
                border.color: "darkgrey"
                opacity: 0.90
                clip: true

                // accept mouse events so they do not propogate down to the map
                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse.accepted = true
                    onWheel: wheel.accepted = true
                }

                Rectangle {
                    id: titleText
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                    }
                    height: 40 * scaleFactor
                    color: "transparent"

                    Text {
                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            margins: 10 * scaleFactor
                        }

                        text: "Weather"; font {bold: true; pixelSize: 20 * scaleFactor;}
                    }

                }
                
                
            Rectangle {
                id: rect
                anchors.fill: parent
                visible: autoPanListView.visible
                color: "black"
                opacity: 0.7
            }

            ListView {
                id: autoPanListView
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    margins: 10 * scaleFactor
                }
                visible: false
                width: parent.width
                height: 300 * scaleFactor
                spacing: 10 * scaleFactor
                model: ListModel {
                    id: autoPanListModel
                }

                delegate: Row {
                    id: autopanRow
                    anchors.right: parent.right
                    spacing: 10

                    Image {
                        source: image
                        width: 40 * scaleFactor
                        height: width
                        MouseArea {
                            anchors.fill: parent
                            // When an item in the list view is clicked
                            onClicked: {
                                autopanRow.updateAutoPanMode();
                            }
                        }
                    }

                    // set the appropriate auto pan mode
                    function updateAutoPanMode() {
                        currentAction.visible = true;
                        autoPanListView.visible = false;
                    }
                }
            }

            Row {
                id: currentAction
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    margins: 25 * scaleFactor
                }
                spacing: 10

                Text {
                    text: currentModeText
                    font.pixelSize: 25 * scaleFactor
                    color: "white"
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            currentAction.visible = false;
                            autoPanListView.visible = true;
                        }
                    }
                }

                Image {
                    source: currentModeImage
                    width: 40 * scaleFactor
                    height: width
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            currentAction.visible = false;
                            autoPanListView.visible = true;
                        }
                    }
                }
            }
        }
    }

    //ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
}


