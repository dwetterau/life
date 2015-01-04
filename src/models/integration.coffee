module.exports = (sequelize, DataTypes) ->
  Integration = sequelize.define "Integration",
    type: {
      type: DataTypes.STRING
      allowNull: false
    }
    key: {
      type: DataTypes.STRING(1024)
      allowNull: false
    }
    uid: {
      type: DataTypes.STRING(255)
      allowNull: false
    }
  , classMethods:
    associate: (models) ->
      Integration.belongsTo(models.User)
  , instanceMethods:
    toJSON: () ->
      return {
        type: @type
        key: @key
        uid: @uid
        UserId: @UserId
      }
  return Integration
