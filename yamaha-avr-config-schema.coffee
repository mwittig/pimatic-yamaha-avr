# #pimatic-yamaha-avr plugin config options
module.exports = {
  title: "pimatic-yamaha-avr plugin config options"
  type: "object"
  properties:
    debug:
      description: "Debug mode. Writes debug messages to the pimatic log, if set to true."
      type: "boolean"
      default: false
    host:
      description: "Hostname or IP address of the AVR"
      type: "string"
    port:
      description: "AVR control port. Only required for testing purposes"
      type: "number"
      default: 80
}