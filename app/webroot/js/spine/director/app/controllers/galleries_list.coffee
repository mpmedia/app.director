Spine           = require("spine")
$               = Spine.$
Gallery         = require('models/gallery')
GalleriesAlbum  = require('models/galleries_album')
AlbumsPhoto     = require('models/albums_photo')
Drag            = require("plugins/drag")
Extender        = require('plugins/controller_extender')

require("plugins/tmpl")

class GalleriesList extends Spine.Controller

  @extend Drag
  @extend Extender
  
  events:
    'click .item'             : 'click'
    'click .icon-set .back'   : 'back'
    'dblclick .item'          : 'zoom'
    'click .icon-set .delete' : 'deleteGallery'
    'click .icon-set .zoom'   : 'zoom'
    'mousemove .item'         : 'infoUp'
    'mouseleave .item'        : 'infoBye'
  
  constructor: ->
    super
    Gallery.bind('change', @proxy @renderOne)
    GalleriesAlbum.bind('destroy create', @proxy @renderRelated)
    AlbumsPhoto.bind('destroy create', @proxy @renderRelated)
    Photo.bind('destroy', @proxy @renderRelated)
    Album.bind('destroy', @proxy @renderRelated)

  renderRelated: (item, mode) ->
    console.log 'GalleriesList::renderRelated'
#    gallery = Gallery.record #|| Gallery.exists(item['gallery_id'])
    @updateTemplates()
#    @el
    
  renderOne: (item, mode) ->
    switch mode
      when 'create'
        console.log item
        @append @template item
        @exposeSelection(item)
      when 'update'
        console.log item 
        @updateTemplates item
        @reorder item
      when 'destroy'
        console.log item
        @children().forItem(item, true).remove()
    @el

  render: (items, mode) ->
    @activate()
    @html @template items
    @el

  updateTemplates: ->
    console.log 'GalleriesList::updateTemplates'
    for id, gallery of Gallery.records
      galleryEl = @children().forItem(gallery)
      galleryContentEl = $('.thumbnail', galleryEl)
      tmplItem = galleryContentEl.tmplItem()
      alert 'no tmpl item' unless tmplItem
      if tmplItem
        tmplItem.tmpl = $( "#galleriesTemplate" ).template()
        tmplItem.update?()
      if id is Gallery.record.id
        cur = gallery
    @exposeSelection(cur)

  reorder: (item) ->
    id = item.id
    index = (id, list) ->
      for itm, i in list
        return i if itm.id is id
      i
    
    children = @children()
    oldEl = @children().forItem(item)
    idxBeforeSort =  @children().index(oldEl)
    idxAfterSort = index(id, Gallery.all().sort(Gallery.nameSort))
    newEl = $(children[idxAfterSort])
    if idxBeforeSort < idxAfterSort
      newEl.after oldEl
    else if idxBeforeSort > idxAfterSort
      newEl.before oldEl

  select: (item) =>
    Spine.trigger('gallery:activate', item)
    App.showView.trigger('change:toolbarOne', ['Default'])
    
  exposeSelection: (item) ->
    console.log 'GalleryList::exposeSelection'
    @deselect()
    if item
      el = @children().forItem(item)
      el.addClass("active")
    App.showView.trigger('change:toolbarOne')
    Spine.trigger('gallery:exposeSelection')
        
  click: (e) ->
    console.log 'GalleryList::click'
    item = $(e.currentTarget).item()
    @select item
    App.showView.trigger('change:toolbarOne', ['Default'])
#    @navigate '/gallery', item.id
    Gallery.current(item.id)
    @exposeSelection item
    e.stopPropagation()
    e.preventDefault()

  back: ->
    @navigate '/overview/'

  zoom: (e) ->
    console.log 'GalleryList::zoom'
    item = $(e.currentTarget).item()
    return unless item?.constructor?.className is 'Gallery'
    Gallery.current item
    @navigate '/gallery', Gallery.record?.id or ''
    
    e.stopPropagation()
    e.preventDefault()
    
  deleteGallery: (e) ->
    item = $(e.currentTarget).item()
    el = $(e.currentTarget).parents('.item')
    el.removeClass('in')
    
    window.setTimeout( ->
      Spine.trigger('destroy:gallery', item)
    , 300)
    
    e.preventDefault()
    e.stopPropagation()
    
  infoUp: (e) =>
    el = $('.icon-set' , $(e.currentTarget)).addClass('in').removeClass('out')
    e.preventDefault()
    
  infoBye: (e) =>
    el = $('.icon-set' , $(e.currentTarget)).addClass('out').removeClass('in')
    e.preventDefault()

module?.exports = GalleriesList