module.exports = {
  cmd:
    get: "GET"
    put: "PUT"
    getParam: "GetParam"
    command: (command, payload) -> "<YAMAHA_AV cmd=\"#{command}\">#{payload}</YAMAHA_AV>"
    mainZone: (command) -> "<Main_Zone>#{command}</Main_Zone>"
    basicStatus: (command) -> "<Basic_Status>#{command}</Basic_Status>"
    powerState: (state) -> if state then "On" else "Standby"
    powerControl: (command) -> "<Power_Control><Power>#{command}</Power></Power_Control>"
    volume: (command) -> "<Volume>#{command}</Volume>"
    level: (command) -> "<Lvl>#{command}</Lvl>"
    val: (command) -> "<Val>#{command}</Val><Exp>1</Exp><Unit>dB</Unit>"
    mute: (state) -> "<Mute>#{if state then "On" else "Off"}</Mute>"
    input: (command) -> "<Input>#{command}</Input>"
    scene: (command) -> "<Scene>#{command}</Scene>"
    inputSelect: (parameter) -> "<Input_Sel>#{parameter}</Input_Sel>"
    sceneSelect: (parameter) -> "<Scene_Sel>#{parameter}</Scene_Sel>"

  query:
    resultCode: (object) -> parseInt object.YAMAHA_AV.$.RC
    command: (object) -> object.YAMAHA_AV
    mainZone: (object) -> object.Main_Zone[0]
    basicStatus: (object) -> object.Basic_Status[0]
    powerControl: (object) -> object.Power_Control[0]
    powerState: (object) -> object.Power[0].toLowerCase() is 'on'
    volume: (object) -> object.Volume[0]
    mute: (object) -> object.Mute[0].toLowerCase() is 'on'
    level: (object) -> object.Lvl[0]
    val: (object) -> parseInt object.Val[0]
    input: (object) -> object.Input[0]
    inputSelect: (object) -> object.Input_Sel[0]
}