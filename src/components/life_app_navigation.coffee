React = require 'react'
{Icon, FlatButton} = require 'material-ui'

LifeAppNavigation = React.createClass
  displayName: 'LifeAppNavigation'

  switchView: (e) ->
    @props.switchView $(e.target.parentElement).data('view')

  goToPast: (e) ->
    @props.changeTimeRange true

  goToFuture: (e) ->
    @props.changeTimeRange false

  goToToday: (e) ->
    @props.resetTimeRange()

  componentDidMount: () ->
    @initializeFilterField()

  getNavigationButtons: () ->
    className = 'navigation-button text-navigation-button'
    getButton = (label, onClick) ->
      React.createElement(FlatButton, {
        label
        onClick
        className
        linkButton: true
      })

    return [
      React.createElement("span", {key: 'today'},
        getButton 'Today', @goToToday
      )
      React.createElement("span", {key: 'past-future'},
        getButton React.createElement(Icon, {icon: "navigation-chevron-left"}), @goToPast
        getButton React.createElement(Icon, {icon: "navigation-chevron-right"}), @goToFuture
      )
    ]

  getViewChangeButtons: () ->
    getButton = (type) =>
      React.createElement FlatButton, {
        className: 'navigation-button text-navigation-button'
        onClick: @switchView
        'data-view': type
        label: type.charAt(0).toUpperCase() + type.substr(1).toLowerCase()
        disabled: type == @props.viewType
        linkButton: true
      }

    React.createElement("div", {key: "view-button"},
      getButton("day")
      getButton("week")
      getButton("month")
      getButton("year")
    )

  getAddEventButton: () ->
    React.createElement FlatButton, {
      className: 'navigation-button text-navigation-button'
      onClick: @props.addEvent
      label: 'Add Event'
      primary: true
      linkButton: true
      key: 'add-event-button'
    }

  getNewFilterTokens: (e) ->
    @props.filterTokens $("#label-filter").tokenfield('getTokensList')

  initializeFilterField: () ->
    getLabelList = () =>
      ({value: l} for l of @props.labels)

    engine = new Bloodhound({
      local: getLabelList()
      datumTokenizer: (d) ->
        return Bloodhound.tokenizers.whitespace(d.value)
      queryTokenizer: Bloodhound.tokenizers.whitespace
    })
    engine.initialize()

    $("#label-filter").tokenfield({
      delay: 100
      delimiter: " "
      createTokensOnBlur: true
      typeahead: [null, {source: engine.ttAdapter()}]
    }).on('tokenfield:createtoken', (e) ->
      e.attrs.value = e.attrs.value.toLowerCase()
    ).on('tokenfield:createdtoken', @getNewFilterTokens
    ).on('tokenfield:removedtoken', @getNewFilterTokens)

  getLabelFilterField: () ->
    React.createElement("div", {key: "label-filter"},
      React.createElement("input", {
        type: "text", id: "label-filter", placeholder: "Filter by labels..."
      })
    )

  render: () ->
    navigation_buttons = @getNavigationButtons()
    filterField = @getLabelFilterField()
    left_side = [@getAddEventButton(), navigation_buttons]

    right_side = []
    if @props.top
      right_side = [@getViewChangeButtons()]

    allButtons = []
    if @props.top
      allButtons.push(
        React.createElement("div", {key: "ff-wrapper", className: "well well-sm filter-field-well"}
          filterField
        )
      )
    allButtons = allButtons.concat [
      React.createElement("div",
        {key: "left-right-wrapper", className: "well well-sm controls-well"},
        React.createElement("div", {key: "ls-buttons", className: "nav-buttons-left-side"}
          left_side
        )
        React.createElement("div", {key: "rs-buttons", className: "nav-buttons-right-side"},
          right_side
        )
      )
    ]

    # View changes
    return React.createElement("div", {className: "col-sm-offset-2 col-sm-8 app-navigation"},
      allButtons
    )

module.exports = {LifeAppNavigation}
