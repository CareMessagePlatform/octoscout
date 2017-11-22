reviewSummary =
  summary: (review) ->
    """
      > *#{review['repository']} - <#{review['url']}|#{review['title']}>*
      > #{review['review']['state']}
    """

module.exports = reviewSummary
