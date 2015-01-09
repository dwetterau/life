module.exports = (sequelize, DataTypes) ->
  Image = sequelize.define "Image",
    path: {
      type: DataTypes.STRING(1024)
      allowNull: false
    }
    uuid: {
      type: DataTypes.STRING(36)
      allowNull: false
    }
    date: {
      type: DataTypes.DATE
      allowNull: false
    }
    mime: {
      type: DataTypes.STRING(32)
      allowNull: false
    }
  , classMethods:
    associate: (models) ->
      Image.belongsTo(models.User)
      Image.belongsTo(models.Event)
  , instanceMethods:
    to_json: () ->
      return {
        id: this.id
        path: this.path
        uuid: this.uuid
        date: this.date
        mime: this.mime
      }
  return Image
