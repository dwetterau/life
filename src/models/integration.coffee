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
  , classMethods:
    associate: (models) ->
      Integration.belongsTo(models.User)

  return Integration
