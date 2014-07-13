# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
#
ready = ->
  uploadDialog = ->
    url = $('#new_item').prop('action')

    $('#new_item').fileupload(
      url: url
      dataType: 'json'
      maxChunkSize: 4 * 1024 * 1024
      uploadTemplate: JST['templates/upload/upload-item']
      downloadTemplate: JST['templates/upload/download-item']

      add: (e, data) ->
        that = this
        $.ajax(
          type: 'HEAD',
          url: '/items.html',
          data: {filename: data.files[0].name, parent_item_id: $("#item_parent_item_id").val()}
        ).done((result, status, xhr)  ->
            data.uploadedBytes = parseInt(xhr.getResponseHeader('Content-Length'))
            yes
        ).always( ->
          $.blueimp.fileupload.prototype
            .options.add.call(that, e, data)
        )
    )

  $('body').on 'hidden.bs.modal', '#item_preview', ->
    $(this).removeData('bs.modal')

  $('body').on 'shown.bs.modal', '#item_upload', ->
    uploadDialog()

  $('body').on 'hidden.bs.modal', '#item_upload', ->
    Turbolinks.visit()

$(document).ready(ready)
$(document).on('page:load', ready)

