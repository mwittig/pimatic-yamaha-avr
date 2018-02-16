module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  commons = require('pimatic-plugin-commons')(env)
  commands = require '../yamaha-avr-commands'
  cmd = commands.cmd

  # Device class representing the mute switch of the Yamaha AVR
  class YamahaAvrMuteSwitch extends env.devices.PowerSwitch

    # Create a new YamahaAvrMuteSwitch device
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
      @_state = false
      super()
      process.nextTick () =>
        @plugin.startStatusUpdates @interval * 1000

    destroy: () ->
      @plugin.removeListener 'statusUpdate', @statusUpdateHandler
      super()
      
    _createStatusUpdateHandler: () ->
      return (status) =>
        @base.debug "Status Update", status
        if status.Mute?
          @_setState status.Mute

    changeStateTo: (newState) ->
      return new Promise (resolve, reject) =>
        @plugin.sendRequest(cmd.command cmd.put, cmd.mainZone cmd.volume cmd.mute newState).then (data) =>
          @_setState newState
          @plugin.emit "statusUpdate",
            Mute: @_state
          resolve()
        .catch (errorResult) =>
          @base.rejectWithErrorString reject, if errorResult instanceof Error then errorResult else errorResult.error

    getState: () ->
      return Promise.resolve @_state
