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
  , instanceMethods:
    to_json: () ->
      return {
        id: this.id
        name: this.name
        color: this.color
        UserId: this.UserId
        EventId: this.EventId
      }
  return Label
