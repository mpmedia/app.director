Spine                 = require("spine")
$                     = Spine.$
Model                 = Spine.Model
Model.Gallery         = require('models/gallery')
Model.Album           = require('models/album')
Model.Photo           = require('models/photo')
Model.AlbumsPhoto     = require('models/albums_photo')
Model.GalleriesAlbum  = require('models/galleries_album')
SpineError            = require("models/spine_error")

Model.Extender =

  extended: ->

    Extend =
      
      record: false

      selection: [global:[]]

      current: (recordOrID) ->
        rec = false
        id = recordOrID?.id or recordOrID
        rec = @find(id) if @exists(id)
        prev = @record
        @record = rec
        same = !!(@record?.eql?(prev) and !!prev)
        Spine.trigger('change:selected'+@className, @record, !same)
        @record

      fromJSON: (objects) ->
        @createJoinTables objects
        key = @className
        json = @fromArray(objects, key) if @isArray(objects)# and objects[key]#test for READ or PUT !
        json || @__super__.constructor.fromJSON.call @, objects

      createJoinTables: (arr) ->
        return unless @isArray arr
        joinTables = @joinTables()
        for key in joinTables
          Model[key].refresh(@createJoins arr, key)
        
      joinTables: ->
        fModels = @foreignModels()
        joinTables = for key, value of fModels
          fModels[key]['joinTable']
        joinTables

      fromArray: (arr, key) ->
        res = []
        extract = (obj) =>
          unless @isArray obj[key]
            item = =>
              res.push new @(obj[key])
            itm = item()
        
        extract(obj) for obj in arr
        res
        
      createJoins: (json, tableName) ->
        res = []
        introspect = (obj) =>
          if @isObject(obj)
            for key, val of obj
              if key is tableName
                res.push item for item in val
              else introspect obj[key]
          
          if @isArray(obj)
            for val in obj
              introspect val

        for obj in json
          introspect(obj)
        res
        
      selectionList: (recordID) ->
        id = recordID or @record?.id
        return @selection[0].global unless id
        for item in @selection
          return item[id] if item[id]

      updateSelection: (list, id) ->
        @emptySelection list, id

      emptySelection: (list = [], id) ->
        originalList = @selectionList(id)
        originalList[0...originalList.length] = list
        @trigger('change:selection', originalList)
        originalList

      removeFromSelection: (id) ->
        list = @selectionList()
        index = list.indexOf(id)
        list.splice(index, 1) unless index is -1
        list

      isArray: (value) ->
        Object::toString.call(value) is "[object Array]"

      isObject: (value) ->
        Object::toString.call(value) is "[object Object]"

      selected: ->
        @record
        
      toID: (records = @records) ->
        record.id for record in records
      
      successHandler: (data, status, xhr) ->
#        console.log data
        
      errorHandler: (record, xhr, statusText, error) ->
        status = xhr.status
        unless status is 200
          error = new SpineError
            record      : record
            xhr         : xhr
            statusText  : statusText
            error       : error

          error.save()
          User.redirect 'users/login'
          
#        console.log record
#        console.log xhr
#        console.log statusText
#        console.log error
        
      customErrorHandler: (record, xhr) ->
        status = xhr.status
        unless status is 200
          error = new Error
            flash       : '<strong style="color:red">Login failed</strong>'
            xhr         : xhr

          error.save()
          User.redirect 'users/login'
          
      filterRelated: (id, options) ->
        joinTableItems = Model[options.joinTable].filter(id, options)
        if options.sorted
          return @sortByOrder @filter joinTableItems
        else
          return @filter joinTableItems
          
    Include =
      
      updateSelection: (list) ->
        modelName = @constructor['parent']
        list = [list] unless @constructor.isArray list
        list = Model[modelName].updateSelection list

      emptySelection: ->
        modelName = @constructor['parent']
        list = Model[modelName].emptySelection()

      addRemoveSelection: (isMetaKey) ->
        modelName = @constructor['parent']
        list = Model[modelName].selectionList()
        return unless list
        if isMetaKey
          @addUnique(list)
        else
          @addRemove(list)
        Model[modelName].trigger('change:selection', list)
        list

      #prevents an update if model hasn't changed
      updateChangedAttributes: (atts) ->
        origAtts = @attributes()
        for key, value of atts
          unless origAtts[key] is value
            invalid = yes
            @[key] = value

          @save() if invalid
        
      #private
      
      addUnique: (list) ->
        list[0...list.length] = [@id]
        list

      addRemove: (list) ->
        unless @id in list
          list.unshift @id
        else
          index = list.indexOf(@id)
          list.splice(index, 1) unless index is -1
        list
        
      allGalleryAlbums: =>
        gallery = Gallery.record
        return unless gallery
        albums = []
        gas = GalleriesAlbum.filter(gallery.id, key:'gallery_id')
        for ga in gas
          albums.push Album.find(ga.album_id) if Album.exists(ga.album_id)
        albums
        
      allAlbumPhotos: =>
        album = Album.record
        return unless album
        photos = []
        aps = AlbumsPhoto.filter(album.id, key:'album_id')
        for ap in aps
          photos.push Photo.find(ap.album_id) if Photo.exists(ap.album_id)
        photos
        
    @extend Extend
    @include Include

module?.exports = Model.Extender