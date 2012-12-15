do (jQuery) ->
  $ = jQuery
  $ ->
    $('#graph').onClick()

     $.get '/cities/index', {}, (data)->
        $('#readings_div').empty().append data

#    $('.pagination a').live 'click', (event) ->
#      $.get $(this).attr('href'), (data) ->
#        $('#readings_div').empty().append data
#      false
#
#
#$('.get_miss').button().prev().button().end().parent().buttonset().end()
#      .click ->
#        $.post '/frontend/get_missing_xml', {}, (data) ->
#          $('body').ajaxAcc('text/javascript')
#          $.get '/frontend/index', {}, (data)->
#            $('#readings_div').empty().append data
#        false
#
#    r = Raphael "holder"
#    draw = (r) ->
#      $.getJSON 'profiles.json', (data) ->
#        if data[0].length < 2
#          $dialog = $ "<div id='dialog' style='display:none;'>
#                        W wybranym okresie nie zostały wykonane żadne
#pomiary
#</div>
#                      "
#          $dialog.appendTo('body').show().dialog()
#          return true
#        lines = r.g.linechart(35, 35, $('#holder').width() - 80, 500,
#          data[0],
#          data[1],
#            nostroke: false
#            axis:     "0 0 1 1"
#            symbol:   "o"
#            smooth:   false
#        ).hoverColumn( -> #popupy nad linią
#          this.flag = r.g.popup(this.x, this.y[0],
#"#{formatAxis(this.axis)} - #{parseInt(this.values)}" ).insertBefore(this)
#        , ->
#          this.flag.remove()
#        )
#
#        lines.symbols.attr
#          r: 3
#        lines.lines[0].animate
#          "stroke-width": 3.8
#          "stroke":       "#b10000"
#          , 5000
#
#        $.each lines.axis[0].text.items, (index, value) -> # zmiana
#timestampów w legendzie na daty
#          nd = new Date(parseInt(value.attr('text'))*1000)
#          if index % 2
#            value.attr('text', parseDate nd )
#          else
#            value.attr 'text', ' '
#        'ok'
#
#    draw(r)
