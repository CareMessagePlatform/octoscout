timeago = require("timeago.js")

prSummary =
  summary: (pr) ->
    """
      > *<#{pr['url']}|#{pr['title']}>*
      > Created #{timeago().format(pr['createdAt'])}
      > Checks state is #{pr['status']}
      > Labels: #{pr['labels'].join(', ')}
      > Reviews:
      #{this.reviews(pr['reviews']).join('\n')}
    """

  reviews: (reviews) ->
    for key, value of reviews
      "> - #{key}: #{value['state']} #{if value['createdAt'] then timeago().format(value['createdAt']) else ''}"

module.exports = prSummary
