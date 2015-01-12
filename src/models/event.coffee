crypto = require 'crypto'
{config} = require '../lib/common'

module.exports = (sequelize, DataTypes) ->
  Event = sequelize.define "Event",
    detail: {
      type: DataTypes.STRING(64000)
      defaultValue: "Enter detail..."
    }
    date: {
      type: DataTypes.DATE
      allowNull: false
    }
    state: {
      type: DataTypes.ENUM
      values: ['active', 'archived', 'deleted']
      defaultValue: 'active'
    }
  , classMethods:
    associate: (models) ->
      Event.belongsTo(models.User)
      Event.hasMany(models.Label)
      Event.hasMany(models.Image)
  , instanceMethods:
    encrypt: () ->
      cipher = crypto.createCipher 'aes256', config.get('event_encryption_key')
      this.detail = cipher.update(this.detail, 'utf8', 'hex') + cipher.final 'hex'

    decrypt: () ->
      decipher = crypto.createDecipher 'aes256', config.get('event_encryption_key')
      this.detail = decipher.update(this.detail, 'hex', 'utf8') + decipher.final('utf8')

    to_json: () ->
      return {
        id: this.id
        detail: this.detail
        date: this.date
        state: this.state
      }
  return Event
