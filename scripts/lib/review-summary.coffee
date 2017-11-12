reviewSummary =
  summary: (review) ->
    """
      > *<#{review['url']}|#{review['title']}>*
      > #{review['review']['state']}
    """

module.exports = reviewSummary
