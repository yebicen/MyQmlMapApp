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
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0
import QtPositioning 5.3
import QtSensors 5.3

import QtQuick.Window 2.2

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
                    // hide the attribute view
                    attributeView.height = 0;



                    // show the attribute view
                    attributeView.height = 200 * scaleFactor

//                    popup.open()
//                    xCoor = mouse.mapPoint.x.toFixed(2);
//                    yCoor = mouse.mapPoint.y.toFixed(2);

//                    if (callout.calloutVisible)
//                        callout.dismiss()
//                    else
//                    {
//                        calloutLocation = mouse.mapPoint;
                        xCoor = mouse.mapPoint.x.toFixed(2);
                        yCoor = mouse.mapPoint.y.toFixed(2);
//                        callout.accessoryButtonHidden = true;
//                        callout.showCallout();

//                    }
                }
            } //end of mapview

            Rectangle {
                id: attributeView
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: 0

                // Animate the expand and collapse of the legend
                Behavior on height {
                    SpringAnimation {
                        spring: 3
                        damping: 0.4
                    }
                }

                ListView {
                    anchors {
                        fill: parent
                        margins: 5 * scaleFactor
                    }

                    clip: true
                    model: relatedFeaturesModel
                    spacing: 5 * scaleFactor

                    // Create delegate to display the attributes

                    delegate: Text {

                           text: day + ": " + weather
                       }

                    // Create a section to separate features by table
                    section {
//                        property: "serviceLayerName"

                        criteria: ViewSection.FullString
                        labelPositioning: ViewSection.CurrentLabelAtStart | ViewSection.InlineLabels
                        delegate: Rectangle {
                            width: app.width
                            height: 20 * scaleFactor
                            color: "#8f499c"

                            Label {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "x: " + xCoor + " y: " + yCoor
                                font {
                                    bold: true
                                    pixelSize: 13 * scaleFactor
                                }
                                elide: Text.ElideRight
                                clip: true
                                color: "white"
                            }
                        }
                    }
                }
            }

            ListModel {
                id: relatedFeaturesModel
                ListElement {
                      day: "Monday"
                      weather: "82  89"
                  }
                  ListElement {
                      day: "Tuesday"
                      weather: "82  89"
                  }
                  ListElement {
                      day: "Wednesday"
                      weather: "82  89"
                  }
                  ListElement {
                      day: "Thursday"
                      weather: "82  89"
                  }
                  ListElement {
                      day: "Friday"
                      weather: "82  89"
                  }
                  ListElement {
                      day: "Saturday"
                      weather: "82  89"
                  }
                  ListElement {
                      day: "Sunday"
                      weather: "82  89"
                  }
            }


//            Popup {
//                    id: popup
//                    x: 100
//                    y: 100
//                    width: 200
//                    height: 300
//                    modal: true
//                    focus: true
//                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
//                    font.family: "Courier"

//                       Column {
//                           Label {
//                               text: qsTr("This will use Courier...")
//                           }
//                }
//            }


        } //end of big Rectangle
    } //end of Page

    //ends here ------------------------------------------------------------------------
    Controls.DescriptionPage{
        id:descPage
        visible: false
    }
} //end of App


