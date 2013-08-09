class @Wikipedia
  @_query = (params) ->
    #console.log "wikipedia_query", params
    Meteor.http.get(
      'http://en.wikipedia.org/w/api.php'
      params: _.extend(
        format: 'json'
        action: 'query'
        params
      )
    ).data.query

  @get_random_articles = ->
    result = @_query
      list: 'random'
      rnnamespace: 0
      rnlimit: 5
    page.title for page in result.random

  @get_article_content = (title) ->
    result = @_query
      titles: title
      prop: 'revisions'
      rvprop: 'content'
    for id, page of result.pages
      return page.revisions[0]['*']


class @YahooAnswers
  @get_random_articles = ->
    content = Meteor.http.get(
      'http://answers.yahoo.com/dir/index?link=resolved'
    ).content
    matches = content.match /href="\/question\/index;?[^"]*?qid=\w+"/g
    m.match(/^href="(.*)"$/)[1] for m in matches

  @get_article_content = (url) ->
    content = Meteor.http.get("http://answers.yahoo.com#{url}").content
    matches = content.match /<div class="content">[^<>]+<\/div>/g
    (m.match(/>(.*)</)[1] ? "" for m in matches).join " "

