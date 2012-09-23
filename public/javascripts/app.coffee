render=(data)->
  #if error message recived
  if data.error?
    #clean code block
    $("#code").html("")
    #reset submit button
    $("#compile").button('reset')
    #show error message
    $("#error").text(data.error).show()
    #scroll to error message
    $('html, body').animate {
          scrollTop: $("#error").offset().top-100
    }, 380
  else if data.data?
    #clean error message
    $("#error").text("").hide()
    #clean code block
    $("#code").html("<h2>Code Comparison</h2>")
    #render each recived data block
    $.each data.data, (k,v)->
      code_block= $ """<pre></pre>"""
      code_block.data "id",k
      code_block.attr "id","code#{k}"
      code_block.text(v.code)
      code_block.addClass "span6 sh_cpp code#{v.code_part}"

      assembly_block= $ """<pre></pre>"""
      assembly_block.data "id",k
      assembly_block.attr "id","assembly#{k}"
      assembly_block.addClass "span5 sh_asm assembly#{v.assembly_part}"
      assembly_block.text(v.assembly)

      row=$ """<div></div>"""
      if code_block.text()==""
        assembly_block.addClass "offset7"
      else  
        row.append(code_block)
        assembly_block.addClass "offset1"
      row.append(assembly_block)
      row.addClass "row-fluid"
      $("#code").append row
      return

    #visualize code mapping
    $.each data.mapping, (k,v)->
      #bind hover event for each code block
      $(".code#{k}").hover do(v)->()->
          gap=$(this).siblings().offset().left-$(this).offset().left-$(this).outerWidth()+4
          connection=$ """<div id="connection" class="offset6"></div>"""
          $(this).parent().append(connection)
          connection.css
            "margin-left":$(this).outerWidth()-1
          left =
              x: 0,
              y1: 0,
              y2: $(this).outerHeight()
            
          #Create SVG canvas using Raphael.js
          paper = Raphael("connection", gap, left.y2);

         
          normaloff=$(this).offset().top
          max=left.y2
          $(this).addClass("glow")
          $.each v,(k,a)->
            $(".assembly#{a}").addClass("glow")
            start=$(".assembly#{a}").offset().top-normaloff
            right =
              x: gap + 2,
              y1: start,
              y2: start+$(".assembly#{a}").outerHeight()
            if right.y2>max
              max=right.y2
              paper.setSize(gap,max)
            #Create SVG path between the lements
            c = paper.path("M" + (left.x) + " " + (left.y1) + " C " + ((right.x - left.x) / 2) + " " + (left.y1) + " " + ((right.x - left.x) / 2) + " " + (right.y1) + " " + (right.x) + " " + (right.y1) + " L " + (right.x) + " " + (right.y2) + " C " + ((right.x - left.x) / 2) + " " + (right.y2) + " " + ((right.x - left.x) / 2) + " " + (left.y2) + " " + (left.x) + " " + (left.y2) + " z" );
            c.attr({stroke: "none",   fill:  "#eee"});
            return
          return
        ,
        ()->
          $(".glow").removeClass("glow")
          $("#connection").remove()
          return
      return
    sh_highlightDocument()
    $("#compile").button('reset')
    $('html, body').animate {
          scrollTop: $("#code").offset().top-10
    }, 380

#On page load
$ ()->
  #bind load sample code
  $("#fileselect li a").click (event)->
      event.preventDefault()
      $("#loadcode").button('loading')
      programm=$(this).data("programm")
      lang=$(this).data("lang")
      $("#lang_#{lang}").attr("checked", "checked")
      $.get "code/#{programm}.html", (data)->
        $("#ccode").val(data)
        $("#loadcode").button('reset')

  #bind submit button
  $("#compile").click (e)->
    #Disable submit button
    $(this).button('loading')
    #start ajax request
    $.post "/compile", $("form").serialize(), ( response )->
      render(response)  
    false
  return
 
 