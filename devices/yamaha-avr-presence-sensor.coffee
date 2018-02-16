module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  commons = require('pimatic-plugin-commons')(env)


  # Device class representing an the power state of the Yamaha AVR including additional information
  # on the volume and selected input
  class YamahaAvrPresenceSensor extends env.devices.PresenceSensor

    # Create a new YamahaAvrPresenceSensor device
    # @param [Object] config    device configuration
    # @param [YamahaAvrPlugin] plugin   plugin instance
    # @param [Object] lastState state information stored in database
    constructor: (@config, @plugin, lastState) ->
      @base = commons.base @, @config.class
      @id = @config.id
      @name = @config.name
      @interval = @base.normalize @config.interval, 10
      @debug = @plugin.debug || false
      @statusUpdateHandler = @_createStatusUpdateHandler()
      @plugin.on 'statusUpdate', @statusUpdateHandler
      @attributes = _.cloneDeep(@attributes)
      @attributes.volume = {
        description: "Volume"
        type: "number"
        acronym: 'VOL'
        unit: 'dB'
      }
      @attributes.input = {
        description: "Input Source"
        type: "string"
        acronym: 'INPUT'
      }
      @_presence = false
      @_volume = 0
      @_input = ""
      super()
      process.nextTick () =>
        @plugin.startStatusUpdates @interval * 1000

    destroy: () ->
      @plugin.removeListener 'statusUpdate', @statusUpdateHandler
      super()

    _createStatusUpdateHandler: () ->
      return (status) =>
        @base.debug "Status Update", status
        if status.Power?
          @_setPresence status.Power
        if status.Volume?
          @base.setAttribute 'volume', status.Volume
        if status.Input?.Select?
          @base.setAttribute 'input', status.Input.Select

    getPresence: () ->
      return new Promise.resolve @_presence

    getVolume: () ->
      return new Promise.resolve @_volume

    getInput: () ->
      return new Promise.resolve @_input
