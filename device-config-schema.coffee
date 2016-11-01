module.exports = {
  title: "pimatic-yamaha-avr device config schemas"
  YamahaAvrPresenceSensor: {
    title: "Yamaha AVR Power Switch"
    description: "Yamaha AVR Power Switch"
    type: "object"
    extensions: ["xLink", "xPresentLabel", "xAbsentLabel"]
    properties:
      interval:
        description: "The time interval in seconds (minimum 10) at which the power state of the AVR will be read"
        type: "number"
        default: 30
  },
  YamahaAvrMasterVolume: {
    title: "Yamaha AVR Master Volume"
    description: "Yamaha AVR Master Volume"
    type: "object"
    extensions: ["xLink", "xPresentLabel", "xAbsentLabel"]
    properties:
      interval:
        description: "The time interval in seconds (minimum 10) at which the power state of the AVR will be read"
        type: "number"
        default: 30
      volumeLimit:
        description: "The maximum volume which can be set using the volume control"
        type: "number"
        default: 16.5
      volumeDbMin:
        description: "The minimal volume in dB of the receiver (check your manual to get the right setting)."
        type: "number"
        default: -80.5
      volumeDbMax:
        description: "The maximum volume in dB of the receiver (check your manual to get the right setting)."
        type: "number"
        default: 16.5
  },
  YamahaAvrPowerSwitch: {
    title: "Yamaha AVR Power Switch"
    description: "Yamaha AVR Power Switch"
    type: "object"
    extensions: ["xLink", "xOnLabel", "xOffLabel"]
    properties:
      interval:
        description: "The time interval in seconds (minimum 10) at which the power state of the AVR will be read"
        type: "number"
        default: 30
  },
  YamahaAvrMuteSwitch: {
    title: "Yamaha AVR Mute Switch"
    description: "Yamaha AVR Mute Switch"
    type: "object"
    extensions: ["xLink", "xOnLabel", "xOffLabel"]
    properties:
      interval:
        description: "The time interval in seconds (minimum 10) at which the mutr state of the AVR will be read"
        type: "number"
        default: 30
  },
  YamahaAvrInputSelector: {
    title: "Yamaha AVR Input Selector"
    description: "Yamaha AVR Input Selector"
    type: "object"
    extensions: ["xLink", "xOnLabel", "xOffLabel"]
    properties:
      interval:
        description: "The time interval in seconds (minimum 10) at which the mutr state of the AVR will be read"
        type: "number"
        default: 30
        minimum: 10
      buttons:
        description: "The inputs to select from"
        type: "array"
        default: [
          {
            id: "TUNER"
          }
          {
            id: "AUDIO1"
          }
        ]
        format: "table"
        items:
          type: "object"
          properties:
            id:
              enum: [
                "SIRIUS", "TUNER", "MULTI CH", "PHONO", "HDMI1", "HDMI2",
                "HDMI3", "HDMI4", "HDMI5", "HDMI6", "HDMI7", "AV1",
                "AV2", "AV3", "AV4", "AV5", "AV6", "AV7", "V-AUX", "AUDIO1",
                "AUDIO2", "AUDIO3", "AUDIO4", "DOCK", "iPod", "Bluetooth",
                "UAW", "NET", "Rhapsody", "SIRIUS InternetRadio", "Pandora",
                "Napster", "PC", "NET RADIO", "USB", "iPod (USB)", 
                "OPTICAL1", "OPTICAL2", "Spotify", "SERVER", "AirPlay", "CD",
                "COAXIAL1", "COAXIAL2", "LINE1", "LINE2", "LINE3"
              ]
              description: "The input ids switchable by the AVR"
            text:
              type: "string"
              description: "The button text to be displayed. The id will be displayed if not set"
              required: false
            confirm:
              description: "Ask the user to confirm the input select"
              type: "boolean"
              default: false
  }
}
