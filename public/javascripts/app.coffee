link=(asm_code,c_codecode,current)->
  gap=asm_code.offset().left-c_codecode.offset().left-$(current).outerWidth()+4
  connection=$ """<div id="connection"></div>"""
  $(current).parent().append(connection)
  connection.css
    "margin-left":$(current).outerWidth()-1
    top:c_codecode.offset().top-$(current).parent().parent().offset().top  
  normaloff=c_codecode.offset().top
  left =
      x: 0,
      y1: $(current).offset().top-normaloff,
      y2: $(current).outerHeight()+$(current).offset().top-normaloff

  #Create SVG canvas using Raphael.js
  paper = Raphael("connection", gap, left.y2);
  
  max=Math.min(left.y2,asm_code.height())
  $(current).addClass("glow")
  k2=$(current).data("id")+1
  $(".link#{k2}").each ()->
    $(this).addClass("glow")
    start=$(this).offset().top-normaloff
    right =
      x: gap + 2,
      y1: start,
      y2: start+$(this).outerHeight()
    if right.y2>max
      max=Math.min(right.y2,asm_code.height())
      paper.setSize(gap,max)
    #Create SVG path between the lements
    c = paper.path("M" + (left.x) + " " + (left.y1) + " C " + ((right.x - left.x) / 2) + " " + (left.y1) + " " + ((right.x - left.x) / 2) + " " + (right.y1) + " " + (right.x) + " " + (right.y1) + " L " + (right.x) + " " + (right.y2) + " C " + ((right.x - left.x) / 2) + " " + (right.y2) + " " + ((right.x - left.x) / 2) + " " + (left.y2) + " " + (left.x) + " " + (left.y2) + " z" );
    c.attr({stroke: "none",   fill:  "#ffee79"});
    return
  return
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
  else if data.code?
    #clean error message
    $("#error").text("").hide()
    #clean code block
    $("#code").html("<h2>Code Comparison</h2>")
    c_codecode=$("""<div class="span5"></div>""")
    asm_code=$("""<div class="span6 offset1"></div>""")
    asm_code.css
        "overflow":"auto"
        height:$(window).height()-100

    c_codecode.css
        "overflow":"auto"
        height:$(window).height()-100

    $("#code").append c_codecode
    $("#code").append asm_code
    #render each recived data block
    $.each data.code, (k,v)->
      code_block= $ """<pre></pre>"""
      code_block.data "id",k
      code_block.attr "id","code#{k}"
      code_block.text(v)
      code_block.addClass "sh_cpp code#{k}"
      c_codecode.append code_block
      return
    $.each data.asm, (k,v)->
      $.each v, (k2,v2)->
        asm_block= $ """<pre></pre>"""
 
        asm_block.text(v2)
        asm_block.addClass "sh_asm link#{k2}"
        asm_code.append asm_block
      return
    c_codecode.find("pre").click ()->
          k2=$(this).data("id")+1
          el=this
          first=$(".link#{k2}").first()
          if first.length>0
              asm_code.animate {
                    scrollTop: first.offset().top-asm_code.offset().top+asm_code.scrollTop()-$(this).offset().top+asm_code.offset().top
               }, 1
               ,()->
                  $(".glow").removeClass("glow")
                  $("#connection").remove()
                  link(asm_code,c_codecode,el)

    c_codecode.find("pre").hover ()->
          link(asm_code,c_codecode,this)
        ,
        ()->
          $(".glow").removeClass("glow")
          $("#connection").remove()
          return
      
    sh_highlightDocument()
    $("#compile").button('reset')
    $('html, body').animate {
          scrollTop: $("#code").offset().top-10
    }, 380

#On page load
$ ()->
  #bind load sample code
  $("#fileselect").dropdown()
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
 
 