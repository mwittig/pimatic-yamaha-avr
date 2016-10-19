module.exports = (env) ->

  Promise = env.require 'bluebird'
  _ = env.require 'lodash'
  commons = require('pimatic-plugin-commons')(env)
  commands = require '../yamaha-avr-commands'
  cmd = commands.cmd

  # Device class representing the power switch of the Yamaha AVR
  class YamahaAvrPowerSwitch extends env.devices.PowerSwitch

    # Create a new YamahaAvrPowerSwitch device
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
        if status.Power?
          @_setState status.Power

    changeStateTo: (newState) ->
      return new Promise (resolve, reject) =>
        @plugin.sendRequest(cmd.command cmd.put, cmd.mainZone cmd.powerControl cmd.powerState newState).then (data) =>
          @_setState newState
          @plugin.emit "statusUpdate",
            Power: @_state
          resolve()
        .catch (errorResult) =>
          @base.rejectWithErrorString reject, if errorResult instanceof Error then errorResult else errorResult.error

    getState: () ->
      return Promise.resolve @_state
