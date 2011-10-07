Spine ?= require("spine")
$      = Spine.$

class Spine.GalleryList extends Spine.Controller
  events:
    "dblclick .item": "edit"
    "click .item"   : "click",
    
  elements:
    '.item'         : 'item'

  selectFirst: false
    
  constructor: ->
    super
    

  template: -> arguments[0]

  change: (item, mode, e) =>
    console.log 'GalleryList::change'
    
    cmdKey = e.metaKey || e.ctrlKey if e
    dblclick = e.type is 'dblclick' if e

    @children().removeClass("active")
    if (!cmdKey and item)
      @current = item unless mode is 'update'
      @children().forItem(@current).addClass("active")
    else
      @current = false

    Gallery.current(@current)

    Spine.trigger('change:selectedGallery', @current, mode)# unless mode is 'update'
  
  render: (items, item, mode) ->
    console.log 'GalleryList::render'
    console.log mode
    
    #inject counter
    for record in items
      record.count = Album.filter(record.id).length
    
    @items = items
    @html @template(@items)
    @change item, mode
    if (!@current or @current.destroyed) and !(mode is 'update')
      unless @children(".active").length
        @children(":first").click()

  children: (sel) ->
    @el.children(sel)

  click: (e) ->
    console.log 'GalleryList::click'
    item = $(e.target).item()
    @change item, 'show', e

  edit: (e) ->
    console.log 'GalleryList::edit'
    item = $(e.target).item()
    @change item, 'edit', e


module?.exports = Spine.GalleryList