class CodeBlock
  constructor:(@el,@c_codecode,@normaloff)->
  getPos:()->
      x: 0,
      y1: $(@el).offset().top-@normaloff,
      y2: $(@el).outerHeight()+$(@el).offset().top-@normaloff

class AsmBlock
  constructor:(@el,@c_codecode,@normaloff)->
  getPos:()->
    start=$(@el).offset().top-@normaloff
    return {
      x: @parent.gap + 2,
      y1: start,
      y2: start+$(@el).outerHeight()
    }
  update:()->
    right=@getPos()
    left=@parent.left.getPos()
    @path.attr("path","M" + (left.x) + " " + (left.y1) + " C " + ((right.x - left.x) / 2) + " " + (left.y1) + " " + ((right.x - left.x) / 2) + " " + (right.y1) + " " + (right.x) + " " + (right.y1) + " L " + (right.x) + " " + (right.y2) + " C " + ((right.x - left.x) / 2) + " " + (right.y2) + " " + ((right.x - left.x) / 2) + " " + (left.y2) + " " + (left.x) + " " + (left.y2) + " z")
    return

class LineCanvas
  constructor:(@paper,@left,@max,@gap)->
    @container=[]
    @paper.setSize(@gap,@max)
  add:(item)->
    @container.push(item)
  update:()->
    item.update() for item in @container
    return
pcodeb=null;
codeb=null; 
link=(asm_code,c_codecode,current,permanent)->
  prefix=if permanent then "p" else ""
  color= if permanent then "#B8FF79" else "#ffee79"
  $(".#{prefix}glow").removeClass("#{prefix}glow")
  $("##{prefix}connection").remove()

  gap=asm_code.offset().left-c_codecode.offset().left-$(current).outerWidth()+4
  connection=$ """<div id="#{prefix}connection"></div>"""
  $(current).parent().append(connection)
  connection.css
    "margin-left":$(current).outerWidth()-1
    top:c_codecode.offset().top-$(current).parent().parent().offset().top  
  normaloff=c_codecode.offset().top
  max=Math.min(c_codecode.height(),asm_code.height())
  #Create SVG canvas using Raphael.js
  paper = Raphael("#{prefix}connection", gap, max);
  lcanvas=new LineCanvas(paper,new CodeBlock(current, gap,normaloff),max,gap)
  $(current).addClass("#{prefix}glow")
  k2=$(current).data("id")+1
  $(".link#{k2}").each ()->

    $(this).addClass("#{prefix}glow")
    asmb=new AsmBlock($(this),gap,normaloff)
    asmb.path= paper.path("M  0 0 1 1 z" );
    asmb.path.attr({stroke: "none",   fill:  color});
    asmb.parent=lcanvas;
    asmb.update()
    lcanvas.add(asmb)
    return
  if permanent
    pcodeb=lcanvas
  else
    codeb=lcanvas

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
    pcodeb=null
    codeb=null
    c_codecode.css
        "overflow":"auto"
        height:$(window).height()-100
    asm_code.scroll ()->
      if codeb?
        codeb.update()
      if pcodeb?
        pcodeb.update()
        
    c_codecode.scroll ()->
      if codeb?
        codeb.update()
      if pcodeb?
        pcodeb.update()
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
          link(asm_code,c_codecode,this,true)
          k2=$(this).data("id")+1
          el=this
          first=$(".link#{k2}").first()
          if first.length>0
              asm_code.animate {
                    scrollTop: first.offset().top-asm_code.offset().top+asm_code.scrollTop()-$(this).offset().top+asm_code.offset().top
               }, 1

    c_codecode.find("pre").hover ()->
          link(asm_code,c_codecode,this,false)
        ,
        ()->
          codeb=null
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
 
 