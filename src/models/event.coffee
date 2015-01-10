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
    to_json: () ->
      return {
        id: this.id
        detail: this.detail
        date: this.date
        state: this.state
      }
  return Event
