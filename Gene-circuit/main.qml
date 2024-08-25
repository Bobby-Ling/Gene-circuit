import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Universal
import QtCore

import "Utils.js" as Utils

import Emulator 1.0
import FileIO 1.0 

Item {
    id: root

    width: 800
    height: 600
    anchors.fill: parent
    anchors.margins: 1

    objectName: "Gene-circuit Main Window"

    Settings {
        id: settings
        property bool debug: debugSwitch.checked
        property color debugRed: debug ? Qt.lighter("red") : "transparent"
        property color debugGreen: debug ? Qt.lighter("green") : "transparent"
        property color debugPurple: debug ? Qt.lighter("purple") : "transparent"
        property url questionsDataUrl: "Assets/Questions/Questions.json"
        property url tutorialDataUrl: "Assets/Tutorial/Tutorial.json"
        property url sourceModelDataUrl: "Assets/Genetic_Element/GeneticElementData.json"
        property url predefinedCommandsUrl: "Assets/PredefinedCommands.json"
        property url saveUrl: "Assets/Save.json"
        property url lightCloseUrl: "Assets/Light_button/Light_close.png"
        property url lightOpenUrl: "Assets/Light_button/Light_open.png"
        property url formulaUrl: "Assets/Misc/Formula.png"

        property var dropModelData
        property var sequenceModelData

    }

    Emulator {
        id: emulator
    }

    RowLayout {
        anchors.fill: parent

        Rectangle {
            id: leftZone

            Layout.fillHeight: true
            Layout.fillWidth: true
            border.color: Qt.lighter("gray")
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 4

                Rectangle {
                    id: canvas
                    clip: true
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    border.color: Qt.lighter("gray")
                    border.width: 2

                    z: 1

                    // MVC

                    ListModel {
                        id: sourceModel
                        // ListElement {
                        //     name: "9XUAS"
                        //     internalName: "9XUAS"
                        //     sourceUrl: "Assets/Genetic_Element/promoter.svg"
                        //     type: "promoter"
                        //     color: "orange"
                        //     description: ""
                        // }
                        function init() {
                            let sourceModelJSON = FileIO.read(settings.sourceModelDataUrl)
                            sourceModel.append(JSON.parse(sourceModelJSON))
                        }
                    }

                    ListModel {
                        id: dragModel
                        // ListElement {
                        //     uuid: string
                        //     modelData: string
                        //     posX: real
                        //     posY: real
                        //     itemWidth: real
                        //     itemHeight: real
                        //     stateType: string ["inSource" | "dropped" | "inSequence"]
                        //     sourceData: var
                        // }
                        function init() {
                            for (let i = 0; i < sourceModel.count; i++) {
                                dragModel.append({
                                    "uuid": Utils.uuid(),
                                    "modelData": "data: " + i,
                                    "posX": 0,
                                    "posY": 0,
                                    "stateType": "inSource",
                                    "sourceData": JSON.parse(JSON.stringify(sourceModel.get(i))),
                                    "itemWidth": 200,
                                    "itemHeight": 100
                                })
                            }
                        }
                    }

                    ListModel {
                        id: dropModel
                        // ListElement {
                        //     uuid: string
                        //     modelData: string
                        //     posX: real
                        //     posY: real
                        //     itemWidth: real
                        //     itemHeight: real
                        //     stateType: string ["inSource" | "dropped" | "inSequence"]
                        //     sourceData: var
                        // }
                    }

                    ListModel {
                        id: sequenceModel
                        // ListElement {
                        //     uuid: string
                        //     droppedItemModel: var
                        //     posX: real
                        //     posY: real
                        // }
                    }

                    Repeater {
                        id: sequenceRepeater
                        model: sequenceModel

                        delegate: sequenceComponent
                    }

                    Repeater {
                        id: dropRepeater
                        model: dropModel

                        delegate: dragCompenent
                    }

                    Component {
                        id: sequenceComponent

                        Rectangle {
                            id: sequenceItem
                            color: "transparent"
                            border.color: settings.debugGreen
                            border.width: 4
                            z: 10

                            required property var droppedItemModel
                            required property string uuid
                            required property int index
                            required property real posX
                            required property real posY

                            height: calHeight()
                            width: calWidth()
                            x: posX
                            y: posY
                            RowLayout {
                                spacing: -45
                                anchors.fill: parent

                                Repeater {
                                    model: droppedItemModel

                                    delegate: dragCompenent
                                    // delegate: Rectangle {
                                    //     id: element

                                    //     required property int index
                                    //     required property string uuid
                                    //     required property real posX
                                    //     required property real posY
                                    //     required property real itemWidth
                                    //     required property real itemHeight
                                    //     required property string modelData
                                    //     required property string stateType
                                    //     required property var sourceData

                                    //     height: 100
                                    //     width: 200
                                    //     color: "transparent"
                                    //     border.color: "black"
                                    //     border.width: 2
                                    //     Text {
                                    //         text: element.modelData
                                    //     }
                                    // }
                                }
                            }

                            function calHeight() {
                                let childrenHeight = 0.0
                                for (let i = 0; i < droppedItemModel.count ; i++) {
                                    childrenHeight = Math.max(childrenHeight, droppedItemModel.get(i).itemHeight)
                                }
                                return childrenHeight
                            }

                            function calWidth() {
                                let childrenWidth = 0.0
                                for (let i = 0; i < droppedItemModel.count ; i++) {
                                    childrenWidth += droppedItemModel.get(i).itemWidth
                                }
                                return childrenWidth
                            }

                            function getCurrentData() {
                                return sequenceModel.get(index)
                            }

                            function stringify() {
                                let str = ""
                                str+="uuid: "+sequenceItem.uuid+"\n"
                                str+="posX: "+sequenceItem.posX+" posY: "+sequenceItem.posY+"\n"
                                str+=Utils.modelToJSON(droppedItemModel)
                                return str
                            }

                            property string stateType: "isSequence"

                            Drag.dragType: Drag.Internal
                            Drag.keys: [stateType]

                            Rectangle {
                                width: parent.width
                                height: 48
                                anchors.bottom: parent.bottom

                                color: "transparent"
                                border.color: settings.debugRed
                                border.width: 2

                                MouseArea {
                                    anchors.fill: parent
                                    drag.target: sequenceItem

                                    onPressed: {
                                        canvas.clip = false
                                        sequenceItem.z+=1
                                        console.log("sequenceItem started")
                                        sequenceItem.Drag.start()
                                    }
                                    onReleased: {
                                        canvas.clip = true
                                        sequenceItem.z-=1
                                        console.log("sequenceItem released")
                                        sequenceItem.Drag.drop()
                                        sequenceItem.getCurrentData().posX = sequenceItem.x
                                        sequenceItem.getCurrentData().posY = sequenceItem.y
                                    }
                                    onDoubleClicked: {
                                        console.log("sequenceItem doubleClicked")

                                        for (let i = 0; i < droppedItemModel.count ; i++) {
                                            let reAddItem = droppedItemModel.get(i)
                                            reAddItem.stateType = "dropped"
                                            reAddItem.posX = sequenceItem.posX + i * (reAddItem.itemWidth + 15)
                                            reAddItem.posY = sequenceItem.posY
                                            dropModel.append(reAddItem)
                                        }
                                        sequenceModel.remove(index)
                                    }
                                    onClicked: {
                                        console.log(sequenceItem.stringify())
                                    }
                                }
                            }
                            Component.onCompleted: {
                                console.log("sequenceItem.droppedItemModel")
                                console.log(Utils.modelToJSON(sequenceItem.droppedItemModel))
                            }
                        }
                    }

                    Component {
                        id: dragCompenent

                        Rectangle {
                            id: dragItem

                            required property int index
                            required property string uuid
                            required property real posX
                            required property real posY
                            required property real itemWidth
                            required property real itemHeight
                            required property string modelData
                            required property string stateType
                            required property var sourceData

                            property int sequenceIndex: (stateType==="inSequence" && (typeof(parent.parent.index)!="undefined")) ? parent.parent.index : -1

                            function getSequenceIndex() {
                                if (stateType==="inSequence") {
                                    if ((typeof(parent.parent.index)=="undefined")){
                                        return -1
                                    }
                                    return parent.parent.index
                                }
                            }

                            function getCurrentData() {
                                return getModel().get(index)
                            }

                            function getModel() {
                                switch (stateType) {
                                    case "inSource":
                                        return dragModel
                                    case "dropped":
                                        return dropModel
                                    case "inSequence":
                                        return sequenceModel.get(sequenceIndex).droppedItemModel
                                }
                            }

                            function stringify() {
                                return Utils._QObjectToJson(getCurrentData())
                            }
                            function actualState() {
                                let str = ""
                                str+="uuid: "+dragItem.uuid+"\n"
                                str+="z: "+dragItem.z+"\n"
                                str+="active: "+dragItem.Drag.active+"\n"
                                str+="pressed: "+pressed+"\n"
                                str+="type: "+(dragItem.Drag.dragType == Drag.Internal ? "Internal" : "Automatic")+"\n"
                                str+="state: "+dragItem.stateType+"\n"
                                str+="posX: "+dragItem.posX+" posY: "+dragItem.posY+"\n"
                                return str
                            }

                            // TODO loop binding
                            // onXChanged: getCurrentData().posX = x
                            // onYChanged: getCurrentData().posY = y

                            x: posX
                            y: posY
                            z: 10
                            width: itemWidth
                            height: itemHeight
                            color: "transparent"
                            border.color: settings.debugRed
                            border.width: 2
                            objectName: "description of dragItem"


                            PropertyAnimation {
                                id: dragItemOpacityAnimation
                                target: dragItem
                                property: "opacity"
                                from: 1.0
                                to: 0.8
                                easing.type : Easing.OutExpo
                                duration: 200
                            }
                            PropertyAnimation {
                                id: dragItemOpacityAnimationReversed
                                target: dragItem
                                property: "opacity"
                                from: 0.8
                                to: 1.0
                                easing.type : Easing.OutExpo
                                duration: 200
                            }
                            Connections {
                                target: dragArea
                                function onEntered (mouse) {
                                    dragItemOpacityAnimation.start()
                                }
                                function onExited (mouse) {
                                    dragItemOpacityAnimationReversed.start()
                                }
                            }

                            // Drag.active: dragArea.drag.active
                            // Drag.dragType: parent == canvas ? Drag.Internal : Drag.Automatic
                            Drag.dragType: (stateType === "dropped" || stateType === "inSequence") ? Drag.Internal : Drag.Automatic
                            // Drag.dragType: Drag.Internal
                            Drag.mimeData: {"inSource": "inSource", "dropped": "dropped", "inSequence": "inSequence"}
                            Drag.keys: [stateType]

                            property alias pressed: dragArea.pressed

                            Repeater {
                                model: ListModel {
                                    id: sourceDataModel
                                    Component.onCompleted: {
                                        sourceDataModel.append(dragItem.sourceData)
                                    }
                                }

                                delegate: GeneticElementComponent {
                                    height: dragItem.itemHeight
                                    width: dragItem.itemWidth
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 48
                                anchors.bottom: parent.bottom

                                color: "transparent"
                                border.color: settings.debugRed
                                border.width: 4
                                MouseArea {
                                    id: dragArea
                                    anchors.fill: parent

                                    drag.target: dragItem
                                    hoverEnabled: true
                                    preventStealing: true
                                    onPressed: {
                                        canvas.clip = false
                                        dragItem.z +=1
                                        console.log("startDrag")
                                        // console.log(mouse.x+" "+mouse.y)
                                        dragItem.Drag.hotSpot.x = mapToItem(dragItem, Qt.point(mouse.x, mouse.y)).x
                                        dragItem.Drag.hotSpot.y = mapToItem(dragItem, Qt.point(mouse.x, mouse.y)).y
                                        // dragItem.grabToImage(function(result) {
                                        //     dragItem.Drag.imageSource = result.url
                                        // })
                                        if (dragItem.Drag.dragType === Drag.Internal){
                                            dragItem.Drag.start()
                                        } else {
                                            dragItem.Drag.active = true
                                        }
                                    }
                                    onEntered: {
                                        if (dragItem.Drag.dragType === Drag.Automatic){
                                            dragItem.grabToImage(function(result) {
                                                dragItem.Drag.imageSource = result.url
                                                // imageDialog.loadImage(result.url)
                                            })
                                        }
                                    }
                                    // onPressedChanged: {
                                    //     if (dragArea.pressed) {
                                    //     }else {
                                    //     }
                                    // }

                                    onReleased: {
                                        canvas.clip = true
                                        dragItem.z -=1
                                        console.log("onReleased");
                                        dragItem.Drag.drop();
                                        getCurrentData().posX = dragItem.x
                                        getCurrentData().posY = dragItem.y
                                    }
                                    onClicked: {
                                        console.log("onClicked")
                                    }
                                    // onPressAndHold: {
                                    //     console.log("onPressAndHold")
                                    //     console.log(dragItem.stringify())
                                    // }
                                    onCanceled: {
                                        console.error("onCanceled !")
                                    }
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                Repeater {
                                    model: 2

                                    delegate: Rectangle {
                                        id: connectionArea
                                        color: "transparent"
                                        border.color: settings.debugPurple
                                        border.width: 2
                                        // anchors.fill: parent
                                        // anchors.margins: 4
                                        Layout.preferredHeight: 45
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignBottom

                                        required property int index

                                        DropArea {
                                            id: connectionDropArea
                                            anchors.fill: parent

                                            keys: ["dropped", "inSource"]

                                            function checkCompatibility(upItem, downItem) {
                                                if (!keys.includes(upItem.stateType)) {
                                                    return false
                                                }
                                                if (upItem.sourceData.type==="promoter") {
                                                    return false
                                                }
                                                if (downItem.sourceData.type==="promoter" && connectionArea.index===0) {
                                                    return false
                                                }
                                                return true
                                            }

                                            Connections {
                                                target: connectionDropArea
                                                function onEntered (mouse) {
                                                    dragItemOpacityAnimation.start()
                                                }
                                                function onExited (mouse) {
                                                    dragItemOpacityAnimationReversed.start()
                                                }
                                            }

                                            onEntered: {
                                                // console.log("entered connectionDropArea, index: "+connectionArea.index)
                                            }

                                            onDropped: { // connectionArea
                                                var upItem = drag.source
                                                var downItem = dragItem

                                                console.log("dropped at connectionDropArea:")
                                                if (!checkCompatibility(upItem, downItem)) {
                                                    console.log("not dropped")
                                                    return
                                                }
                                                console.log(upItem.stringify())
                                                if (upItem.stateType === "inSource") {
                                                    var upItemData = JSON.parse(JSON.stringify(upItem.getCurrentData()))
                                                    upItemData.uuid = Utils.uuid()
                                                    upItemData.posX = drop.x - drop.source.Drag.hotSpot.x
                                                    upItemData.posY = drop.y - drop.source.Drag.hotSpot.y
                                                    upItemData.stateType = "inSequence"
                                                    dropModel.append(upItemData)
                                                }
                                                let upItemIndex = upItem.stateType === "inSource" ? dropModel.count-1 : upItem.index

                                                if (upItem.stateType === "dropped") {
                                                    upItem.getCurrentData().stateType = "inSequence" // in dropModel
                                                }
                                                let currentSequenceIndex = downItem.sequenceIndex
                                                if(currentSequenceIndex !==-1){
                                                    // down is already in a sequence
                                                    console.log("down is already in a sequence")

                                                    // in sequenceModel.get(sequenceIndex).droppedItemModel
                                                    console.log(downItem.index+" "+connectionArea.index)
                                                    downItem.getModel().insert(downItem.index + connectionArea.index, dropModel.get(upItemIndex))

                                                    if (upItem.pressed) {
                                                        // workaround... >_<###
                                                        dragRepeater.rePresent()
                                                    }

                                                    dropModel.remove(upItemIndex)
                                                }else{
                                                    // Two new elements
                                                    console.log("Two new elements")
                                                    downItem.getCurrentData().stateType = "inSequence" // in dropModel
                                                    sequenceModel.append({
                                                        uuid: Utils.uuid(),
                                                        droppedItemModel: [dropModel.get(downItem.index), dropModel.get(upItemIndex)],
                                                        posX: dragItem.x,
                                                        posY: dragItem.y
                                                    })
                                                    if (upItem.pressed) {
                                                        // workaround... >_<###
                                                        dragRepeater.rePresent()
                                                    }
                                                    dropModel.remove(upItemIndex)
                                                    dropModel.remove(downItem.index)
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Text {
                                id: txt
                                visible: settings.debug
                                anchors.centerIn: parent
                                color: "gray"
                                font.pixelSize: 11
                                text: dragItem.actualState()
                            }
                        }
                    }

                    DropArea {
                        id: canvasDropArea
                        anchors.fill: parent
                        keys: ["inSource", "dropped"]

                        onEntered: {
                            // console.log("entered canvasDropArea")
                        }
                        onExited: {
                            // console.log("exited canvasDropArea")
                        }

                        onDropped: { // canvasDropArea
                            // dropped(DragEvent drop)
                            let upItem = drop.source

                            console.log("dropped at: canvasDropArea")
                            // console.log(upItem.stringify())
                            if (upItem.stateType !== "inSource") {
                                console.log("not dropped")
                                return
                            }

                            // console.log("drag at: ("+drop.x+", "+drop.y+") with Drag.hotSpot: ("+drag.source.Drag.hotSpot.x+", "+drop.source.Drag.hotSpot.y+")")
                            var upItemData = JSON.parse(JSON.stringify(upItem.getCurrentData()))
                            upItemData.uuid = Utils.uuid()
                            upItemData.posX = drop.x - drop.source.Drag.hotSpot.x
                            upItemData.posY = drop.y - drop.source.Drag.hotSpot.y
                            upItemData.stateType = "dropped"
                            dropModel.append(upItemData)

                            if (upItem.pressed) {
                                // workaround... >_<###
                                dragRepeater.rePresent()
                            }
                        }
                    }
                }
                Rectangle {
                    id: source
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    border.color: Qt.lighter("gray")
                    border.width: 2
                    z: 0

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 10
                        border.color: Qt.lighter("gray")
                        border.width: 2
                        ScrollView {
                            anchors.fill: parent
                            clip: true
                            anchors.margins: 4
                            Flow {
                                width: source.width
                                height: source.width
                                spacing: 40
                                Repeater {
                                    id: dragRepeater
                                    model: dragModel
                                    delegate: dragCompenent

                                    function rePresent() {
                                        canvas.clip = true
                                        var dragModelData = Utils.modelToJSON(dragModel)
                                        dragModel.clear()
                                        dragModel.append(JSON.parse(dragModelData))
                                    }

                                    Component.onCompleted: {
                                        sourceModel.init()
                                        dragModel.init()
                                        rePresent()
                                    }
                                }
                            }
                        }
                    }

                    DropArea {
                        id: removeArea
                        anchors.fill: parent

                        keys: ["dropped", "isSequence"]

                        onEntered: {
                            // console.log("entered removeArea")
                        }

                        onDropped: { // removeArea
                            // dropped(DragEvent drop)
                            var upItem = drag.source

                            console.log("dropped at removeArea")
                            console.log(upItem.stringify())
                            if (!keys.includes(upItem.stateType)) {
                                console.log("not dropped")
                                return
                            }
                            // console.log("drag at: ("+drop.x+", "+drop.y+") with Drag.hotSpot: ("+drag.source.Drag.hotSpot.x+", "+drop.source.Drag.hotSpot.y+")")
                            switch (upItem.stateType ) {
                                case "isSequence":
                                    sequenceModel.remove(upItem.index)
                                    break
                                case "dropped":
                                    dropModel.remove(upItem.index)
                                    break
                            }

                            if (upItem.pressed) {
                                // workaround... >_<###
                                dragRepeater.rePresent()
                            }
                        }
                    }
                }
            }

        }
        Rectangle {
            id: rightZone

            Layout.fillHeight: true
            Layout.preferredWidth: tabPanel.implicitWidth + 40
            border.color: Qt.lighter("gray")
            border.width: 2
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 4
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: formula.implicitHeight
                    Image {
                        id: formula
                        anchors.fill: parent
                        source: settings.formulaUrl
                        fillMode: Image.PreserveAspectFit
                    }
                }

                Rectangle {
                    id: interactiveZone
                    Layout.minimumHeight: 240
                    Layout.fillWidth: true
                    border.color: Qt.lighter("gray")
                    border.width: 2

                    ListModel {
                        id: ioModel
                        // MVC
                        // ListElement {
                        //     // environment
                        //     blueray: true
                        //     blood_sugar: 30
                        //     // output
                        //     greenLight: false
                        //     sugar: false
                        //     noResult: false
                        //     rawOutput: ""
                        // }
                        function init() {
                            ioModel.clear()
                            ioModel.append({
                               // environment
                               blueray: true,
                               blood_sugar: 30,
                               // output
                               greenLight: false,
                               sugar: false,
                               noResult: false,
                               rawOutput: ""
                            })
                        }
                        Component.onCompleted: {
                            ioModel.init()
                        }
                    }

                    Repeater {
                        model: ioModel

                        delegate: ColumnLayout {
                            id: ioZone
                            anchors.fill: parent
                            spacing: 10
                            anchors.margins: 20

                            required property bool blueray
                            required property int blood_sugar
                            required property bool greenLight
                            required property bool sugar
                            required property bool noResult
                            required property string rawOutput

                            Rectangle {
                                id: outputZone

                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                border.color: Qt.lighter("gray")
                                border.width: 2

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 4

                                    Repeater {
                                        model: ["Sugar"]
                                        delegate: PlotCanvas {
                                            required property string modelData
                                            Text {
                                                text: modelData
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            scale: 0.35
                                            border.color: Qt.lighter("gray")
                                            opacity: ioZone.sugar ? 1 : 0.5
                                            prisugar: ioZone.blood_sugar
                                            threshold: !ioZone.sugar ? sugarSlider.to : 40
                                            type: modelData
                                        }
                                    }
                                    Repeater {
                                        model: ["Insulin"]
                                        delegate: PlotCanvas {
                                            required property string modelData
                                            Text {
                                                text: modelData
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            scale: 0.35
                                            border.color: Qt.lighter("gray")
                                            opacity: ioZone.sugar ? 1 : 0.5
                                            prisugar: ioZone.sugar ? ioZone.blood_sugar : 10
                                            threshold: 40
                                            type: modelData
                                        }
                                    }

                                    Text {
                                        text: ioZone.rawOutput
                                        visible: settings.debug
                                        font.pixelSize: 20
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 60
                                        Layout.fillHeight: true
                                        border.color: settings.debugRed
                                        opacity: ioZone.greenLight ? 1 : 0.5

                                        Image {
                                            id: light
                                            anchors.fill: parent
                                            fillMode: Image.PreserveAspectFit
                                            source: ioZone.greenLight ? settings.lightOpenUrl : settings.lightCloseUrl
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                id: inputZone

                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Layout.margins: 10
                                spacing: 10

                                Switch {
                                    text: "Blueray"
                                    checked: ioZone.blueray
                                    onCheckedChanged: {
                                        ioModel.get(0).blueray = checked
                                    }
                                }

                                Slider {
                                    id: sugarSlider
                                    Layout.fillWidth: true
                                    from: 10
                                    to: 80
                                    value: ioZone.blood_sugar
                                    onValueChanged: {
                                        ioModel.get(0).blood_sugar = Math.floor(value)
                                        evaluate.clicked()
                                    }
                                }

                                Text {
                                    text: "Blood Sugar: " + ioZone.blood_sugar
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    id: functionZone
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    border.color: Qt.lighter("gray")
                    border.width: 2

                    MouseArea {
                        anchors.fill: parent
                        Timer {
                            id: scrollTimer
                            interval: 100 
                            repeat: false
                        }

                        onWheel: {
                            if(wheel.inverted||(!scrollTimer.running)||((Math.abs(wheel.angleDelta.y)>=120)||(Math.abs(wheel.angleDelta.y)>=120))){
                                scrollTimer.start();
                                if(wheel.angleDelta.x<0||wheel.angleDelta.y<0){
                                    if(bar.currentIndex===bar.count-1){
                                        bar.setCurrentIndex(0)
                                    }else{
                                        bar.incrementCurrentIndex();
                                    }
                                }else{
                                    if(bar.currentIndex===0){
                                        bar.setCurrentIndex(bar.count-1)
                                    }else{
                                        bar.decrementCurrentIndex();
                                    }
                                }
                            }else{
                                scrollTimer.restart();
                            }
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 4
                        Rectangle {
                            Layout.preferredHeight: tabPanel.implicitHeight + tabPanel.anchors.margins*2
                            Layout.fillWidth: true
                            border.color: Qt.lighter("gray")
                            border.width: 2
                            RowLayout {
                                id: tabPanel
                                anchors.fill: parent
                                anchors.margins: 4

                                Container {
                                    id: bar
                                    currentIndex: view.currentIndex

                                    contentItem: RowLayout {
                                    }
                                    Repeater {
                                        id: tabButtons
                                        model: ["Example 📚", "Tutorial 💡", "Load 🛠"]
                                        delegate: Control {
                                            Layout.fillHeight: true
                                            Layout.preferredWidth: tabButtons.getButtonWidth()
                                            required property int index
                                            required property string modelData
                                            contentItem: Button {
                                                anchors.fill: parent
                                                text: modelData
                                                down: index === bar.currentIndex
                                                onClicked: {
                                                    bar.currentIndex = index
                                                }
                                            }
                                        }
                                        function getButtonWidth() {
                                            let buttonWidth = 0.0
                                            for (let i = 0; i < tabButtons.count ; i++) {
                                                buttonWidth = Math.max(buttonWidth, tabButtons.itemAt(i).implicitWidth)
                                            }
                                            return buttonWidth
                                        }
                                    }
                                }
                                Button {
                                    id: clearCanvas
                                    text: "Clear ❌"
                                    onClicked: {
                                        dropModel.clear()
                                        sequenceModel.clear()
                                    }
                                }

                                Button {
                                    id: evaluate
                                    text: "Evaluate ▶️"
                                    onClicked: {
                                        var sequences_JSON_data = Utils.modelToJSON(sequenceModel)
                                        var environment_variables_JSON_data = JSON.stringify(ioModel.get(0))
                                        var result = JSON.parse(emulator.evaluate(sequences_JSON_data, environment_variables_JSON_data))
                                        console.log(Utils.modelToJSON(ioModel))
                                        console.log(JSON.stringify(result))
                                        ioModel.get(0).rawOutput = result.rawOutput
                                        ioModel.get(0).greenLight = result.greenLight
                                        ioModel.get(0).sugar = result.sugar
                                        ioModel.get(0).noResult = result.noResult
                                    }
                                }
                            }
                        }

                        Control {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            background: Rectangle {
                                border.color: Qt.lighter("gray")
                                border.width: 2
                            }
                            contentItem: SwipeView {
                                id: view
                                currentIndex: bar.currentIndex
                                clip: true

                                Item {
                                    id: questions

                                    SwipeBanner {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        Repeater {
                                            model: JSON.parse(FileIO.read(settings.questionsDataUrl))
                                            delegate: ColumnLayout {
                                                id: questionsTextSection
                                                spacing: 20
                                                required property string title
                                                required property string description
                                                required property string picture
                                                required property var loadData
                                                Control {
                                                    background: Rectangle {
                                                        border.color: settings.debugRed
                                                    }
                                                    Layout.fillWidth: true
                                                    Layout.alignment: Qt.AlignHCenter
                                                    contentItem: Text {
                                                        text: questionsTextSection.title
                                                        font.pixelSize: 18
                                                        font.bold: true
                                                        horizontalAlignment: Text.AlignHCenter
                                                    }
                                                }

                                                Control {
                                                    background: Rectangle {
                                                        border.color: settings.debugRed
                                                        border.width: 2
                                                    }
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    Layout.alignment: Qt.AlignHCenter
                                                    Image {
                                                        id: img
                                                        anchors.fill: parent
                                                        source: questionsTextSection.picture
                                                        fillMode: Image.PreserveAspectFit
                                                    }
                                                }

                                                Control {
                                                    background: Rectangle {
                                                        border.color: settings.debugRed
                                                    }
                                                    Layout.fillWidth: true
                                                    Layout.alignment: Qt.AlignHCenter
                                                    contentItem: Text {
                                                        text: questionsTextSection.description
                                                        wrapMode: Text.WordWrap
                                                        font.pixelSize: 14
                                                        horizontalAlignment: Text.AlignHCenter
                                                    }
                                                }
                                                Button {
                                                    Layout.alignment: Qt.AlignHCenter
                                                    text: "Load ⚡"
                                                    onClicked: {
                                                        dropModel.clear()
                                                        sequenceModel.clear()
                                                        ioModel.init()
                                                        sequenceModel.append(JSON.parse(JSON.stringify(questionsTextSection.loadData)))
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                Item {
                                    id: tutorial

                                    SwipeBanner {
                                        anchors.fill: parent
                                        anchors.margins: 6
                                        Repeater {
                                            model: JSON.parse(FileIO.read(settings.tutorialDataUrl))
                                            delegate: ColumnLayout {
                                                id: tutorialTextSection
                                                spacing: 20
                                                required property string title
                                                required property string description
                                                required property string picture
                                                Text {
                                                    Layout.fillWidth: true
                                                    text: parent.title
                                                    font.pixelSize: 14
                                                    wrapMode: Text.WordWrap
                                                }
                                                
                                                Control {
                                                    background: Rectangle {
                                                        border.color: settings.debugRed
                                                        border.width: 2
                                                    }
                                                    Layout.fillWidth: true
                                                    Layout.fillHeight: true
                                                    Layout.alignment: Qt.AlignHCenter
                                                    Image {
                                                        anchors.fill: parent
                                                        source: tutorialTextSection.picture
                                                        fillMode: Image.PreserveAspectFit
                                                    }
                                                }

                                                Text {
                                                    //Layout.fillHeight: true
                                                    Layout.fillWidth: true
                                                    text: parent.description
                                                    wrapMode: Text.WordWrap
                                                    font.pixelSize: 14
                                                }
                                            }
                                        }
                                    }
                                }

                                Item {
                                    id: load

                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            height: bar.implicitHeight
                                            width: bar.implicitWidth
                                            color: "transparent"
                                        }

                                        RowLayout {
                                            id: controlPanel
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 28
                                            Layout.alignment: Qt.AlignCenter | Qt.AlignTop
                                            Button {
                                                id: clear
                                                text: "Clear"
                                                onClicked: {
                                                    dropModel.clear()
                                                    sequenceModel.clear()
                                                }
                                            }
                                            Button {
                                                id: restore
                                                text: "Restore"
                                                onClicked: {
                                                    dropModel.append(JSON.parse(JSON.stringify(settings.dropModelData)))
                                                    sequenceModel.append(JSON.parse(JSON.stringify(settings.sequenceModelData)))
                                                }
                                            }
                                            Button {
                                                id: save
                                                text: "Save"
                                                onClicked: {
                                                    settings.dropModelData = JSON.parse(Utils.modelToJSON(dropModel))
                                                    settings.sequenceModelData = JSON.parse(Utils.modelToJSON(sequenceModel))
                                                }
                                            }
                                            Button {
                                                id: debugSwitch
                                                text: "Debug"
                                                checkable: true
                                                checked: settings.debug
                                            }
                                            JSConsoleButton {
                                                windowHeight: 600
                                                windowWidth: 800
                                                predefinedCommands: JSON.parse(FileIO.read(settings.predefinedCommandsUrl))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
