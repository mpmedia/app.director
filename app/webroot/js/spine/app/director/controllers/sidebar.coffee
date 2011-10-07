Spine ?= require("spine")
$      = Spine.$

class SidebarView extends Spine.Controller

  @extend Spine.Controller.Drag

  elements:
    'input'   : 'input'
    '.items'  : 'items'
    '.droppable':  'droppable'

  #Attach event delegation
  events:
    "click button"          : "create"
    "keyup input"           : "filter"
    "dblclick .draghandle"  : 'toggleDraghandle'

    'dragstart          .items .item'         : 'dragstart'
    'dragenter          .items .item'         : 'dragenter'
    'dragover           .items .item'         : 'dragover'
    'dragleave          .items .item'         : 'dragleave'
    'drop               .items .item'         : 'drop'
    'dragend            .items .item'         : 'dragend'

  #Render template
  template: (items) ->
    $("#galleriesTemplate").tmpl(items)

  constructor: ->
    super
    @list = new Spine.GalleryList
      el: @items,
      template: @template

    Gallery.bind("refresh change", @proxy @render)
    Spine.bind('render:count', @proxy @renderCount)
    Spine.bind('drag:start', @proxy @dragStart)
    Spine.bind('drag:over', @proxy @dragOver)
    Spine.bind('drag:leave', @proxy @dragLeave)
    Spine.bind('drag:drop', @proxy @dropComplete)

  filter: ->
    @query = @input.val();
    @render();

  render: (item, mode) ->
    console.log 'Sidebar::render'
    items = Gallery.filter @query, 'searchSelect'
    items = items.sort Gallery.nameSort
    @galleryItems = items
    @list.render items, item, mode

  renderCount: ->
    for item in @galleryItems
      $('#'+item.id).html(Album.filter(item.id).length)

  dragStart: ->
    selection = Gallery.selectionList()
    newSelection = selection.slice(0)
    newSelection.push Spine.dragItem.id unless Spine.dragItem.id in selection
    @newSelection = newSelection
    @oldtargetID = null

  dragOver: (e) ->
    target = $(e.target).item()
    return if target.id is @oldtargetID
    @oldtargetID = target.id
    items = GalleriesAlbum.filter(target.id)
    for item in items
      if item.album_id in @newSelection
        $(e.target).addClass('nodrop')
        

  dragLeave: (e) ->
    target = $(e.target).item()
    return if target.id is @oldtargetID
    @oldtargetID = target.id
    $('li').removeClass('nodrop')


  dropComplete: (source, target) ->
    console.log 'dropComplete'

    unless source instanceof Album
      alert 'You can only drop Albums here'
      return
    unless target instanceof Gallery
      return

    items = GalleriesAlbum.filter(target.id)
    for item in items
      if item.album_id is source.id
        alert 'Album already exists in Gallery'
        return

    albums = []
    Album.each (record) =>
      albums.push record unless @newSelection.indexOf(record.id) is -1
    Spine.trigger('create:albumJoin', target, albums)
    
  newAttributes: ->
    name: 'New Gallery'
    author: 'No Author'

  #Called when 'Create' button is clicked
  create: (e) ->
    e.preventDefault()
    @preserveEditorOpen('gallery', App.albumsShowView.btnGallery)
    gallery = new Gallery @newAttributes()
    gallery.save()
  
  toggleDraghandle: ->
    width = =>
      width =  @el.width()
      max = App.vmanager.max()
      min = App.vmanager.min
      if width >= min and width < max-20
        max+"px"
      else
        min+'px'
    
    @el.animate
      width: width()
      400

module?.exports = SidebarView