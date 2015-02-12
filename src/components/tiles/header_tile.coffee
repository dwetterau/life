React = require 'react'

HeaderTile = React.createClass
  displayName: 'HeaderTile'
  render: () ->
    <div className="header-tile" id={@props.id}>
      <h4>{@props.header.date}</h4>
    </div>

module.exports = {HeaderTile}
