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
    )

  $('body').on 'hidden.bs.modal', '#item_preview', ->
    $(this).removeData('bs.modal')

  $('body').on 'shown.bs.modal', '#item_upload', ->
    uploadDialog()

  $('body').on 'hidden.bs.modal', '#item_upload', ->
    Turbolinks.visit()

$(document).ready(ready)
$(document).on('page:load', ready)

