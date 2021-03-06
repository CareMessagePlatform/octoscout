ghQuery =
  pullRequestQuery: """
    createdAt
    title
    url
    repository {
      name
    }
    author {
      login
    }
    commits(last: 1) {
      nodes {
        commit {
          message
          status {
            state
            contexts {
              context
              state
            }
          }
        }
      }
    }
    labels(last: 50) {
      nodes {
        name
      }
    }
    reviews(last:50, states:[DISMISSED,CHANGES_REQUESTED,APPROVED]) {
      nodes {
        createdAt
        state
        author {
          login
        }
      }
    }
    reviewRequests(last:50) {
      nodes {
        requestedReviewer {
          ... on User {
            login
          }
        }
      }
    }
  """

  userPullRequests: (login) ->
    JSON.stringify({
      query: """
        query($login:String!) {
          user(login: $login) {
            pullRequests(states:OPEN, last:50, orderBy:{field:CREATED_AT, direction:DESC}) {
              nodes {
                #{this.pullRequestQuery}
              }
            }
          }
        }
      """
      variables: {
        login: login
      }
    })

  teamPullRequests: (organization, slug) ->
    JSON.stringify({
      query: """
        query($organization: String!, $slug: String!) {
          organization(login: $organization) {
            team(slug: $slug) {
              members(last: 50) {
                nodes {
                  pullRequests(states:OPEN, last:50, orderBy:{field:CREATED_AT, direction:DESC}) {
                    nodes {
                     #{this.pullRequestQuery}
                    }
                  }
                }
              }
            }
          }
        }
      """
      variables: {
        organization: organization,
        slug: slug
      }
    })

  userReviewRequests: (login, organization) ->
    JSON.stringify({
      query: """
        query($login:String!, $organization:String!) {
          organization(login: $organization) {
            repositories(last:50) {
              nodes {
              pullRequests(states:OPEN, last:50, orderBy:{field:CREATED_AT, direction:DESC}) {
                nodes {
                  title
                  url
                  repository {
                    name
                  }
                  reviews(last:1, author:$login, states:[DISMISSED,PENDING,APPROVED,CHANGES_REQUESTED]) {
                    nodes {
                      createdAt
                      state
                      author {
                        login
                      }
                    }
                  }
                  reviewRequests(last:50) {
                    nodes {
                      requestedReviewer {
                        ... on User {
                          login
                        }
                      }
                    }
                  }
                }
              }
            }
            }
          }
        }
      """
      variables: {
        login: login
        organization: organization
      }
    })

module.exports = ghQuery
