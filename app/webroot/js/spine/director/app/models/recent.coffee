Spine   = require("spine")
Model   = Spine.Model
$       = Spine.$
Photo   = require("models/photo")
User    = require("models/user")
require('spine/lib/local')

class Recent extends Spine.Model

  @configure 'Recent', 'id'
  
  @extend Model.Local
  
  @logout: ->
    @destroyAll()
    @redirect 'logout'
  
  @redirect: (url) ->
    location.href = base_url + url
    
  init: (instance) ->
    return unless instance
    
  @loadRecent: (max = 100, callback) ->
    $.ajax
      contentType: 'application/json'
      dataType: 'json'
      processData: false
      headers: {'X-Requested-With': 'XMLHttpRequest'}
      url: base_url + 'photos/recent/' + max
      type: 'GET'
      success: (json) -> callback.call @, json
      error: @proxy @error
  
  @success: (json) ->

  @error: (xhr) ->
    console.log 'Ajax::error'
    @logout()
    @redirect 'users/login'
      
module?.exports = Recent