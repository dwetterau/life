bcrypt = require 'bcrypt'

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
  , classMethods:
    associate: (models) ->
      Event.belongsTo(models.User)
      Event.hasMany(models.Label)

  return Event
