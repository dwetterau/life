bcrypt = require 'bcrypt'

module.exports = (sequelize, DataTypes) ->
  Label = sequelize.define "Label",
    name: {
      type: DataTypes.STRING
      allowNull: false
    }
    color: {
      type: DataTypes.STRING
      defaultValue: '#FFFFFF'
    }
  , classMethods:
    associate: (models) ->
      Label.belongsTo(models.User)
      Label.belongsTo(models.Event)

  return Label
