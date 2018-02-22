STATUS_UPDATE_STATES_FILTER = ["error", "failure"]

hookSummary =
  summary: (data) ->
    this[data.eventType]?(data.data)

  status: (data) ->
    if data.state in STATUS_UPDATE_STATES_FILTER
      """
        > Status update for commit: <#{data.commit.url}|#{data.commit.message}>
        > #{data.context}: #{data.description}
        > *#{data.state.toUpperCase()}*
      """

module.exports = hookSummary
