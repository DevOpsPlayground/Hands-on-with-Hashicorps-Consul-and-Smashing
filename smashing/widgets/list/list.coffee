class Dashing.List extends Dashing.Widget

  Dashing.Widget::accessor 'updatedAtMessage', ->
    if updatedAt = @get('updatedAt')
      timestamp = new Date(updatedAt * 1000)
      hours = timestamp.getHours()
      minutes = ("0" + timestamp.getMinutes()).slice(-2)
      seconds = ("0" + timestamp.getSeconds()).slice(-2)
      "Last updated at #{hours}:#{minutes}:#{seconds}"

      
  ready: ->
    if @get('unordered')
      $(@node).find('ol').remove()
    else
      $(@node).find('ul').remove()


  @accessor 'isServiceDown', ->
    @get('status') == "down"
