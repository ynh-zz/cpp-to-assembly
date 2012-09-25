var link, render;

link = function(asm_code, c_codecode, current) {
  var connection, gap, k2, left, max, normaloff, paper;
  gap = asm_code.offset().left - c_codecode.offset().left - $(current).outerWidth() + 4;
  connection = $("<div id=\"connection\"></div>");
  $(current).parent().append(connection);
  connection.css({
    "margin-left": $(current).outerWidth() - 1,
    top: c_codecode.offset().top - $(current).parent().parent().offset().top
  });
  normaloff = c_codecode.offset().top;
  left = {
    x: 0,
    y1: $(current).offset().top - normaloff,
    y2: $(current).outerHeight() + $(current).offset().top - normaloff
  };
  paper = Raphael("connection", gap, left.y2);
  max = Math.min(left.y2, asm_code.height());
  $(current).addClass("glow");
  k2 = $(current).data("id") + 1;
  $(".link" + k2).each(function() {
    var c, right, start;
    $(this).addClass("glow");
    start = $(this).offset().top - normaloff;
    right = {
      x: gap + 2,
      y1: start,
      y2: start + $(this).outerHeight()
    };
    if (right.y2 > max) {
      max = Math.min(right.y2, asm_code.height());
      paper.setSize(gap, max);
    }
    c = paper.path("M" + left.x + " " + left.y1 + " C " + ((right.x - left.x) / 2) + " " + left.y1 + " " + ((right.x - left.x) / 2) + " " + right.y1 + " " + right.x + " " + right.y1 + " L " + right.x + " " + right.y2 + " C " + ((right.x - left.x) / 2) + " " + right.y2 + " " + ((right.x - left.x) / 2) + " " + left.y2 + " " + left.x + " " + left.y2 + " z");
    c.attr({
      stroke: "none",
      fill: "#ffee79"
    });
  });
};

render = function(data) {
  var asm_code, c_codecode;
  if (data.error != null) {
    $("#code").html("");
    $("#compile").button('reset');
    $("#error").text(data.error).show();
    return $('html, body').animate({
      scrollTop: $("#error").offset().top - 100
    }, 380);
  } else if (data.code != null) {
    $("#error").text("").hide();
    $("#code").html("<h2>Code Comparison</h2>");
    c_codecode = $("<div class=\"span5\"></div>");
    asm_code = $("<div class=\"span6 offset1\"></div>");
    asm_code.css({
      "overflow": "auto",
      height: $(window).height() - 100
    });
    c_codecode.css({
      "overflow": "auto",
      height: $(window).height() - 100
    });
    $("#code").append(c_codecode);
    $("#code").append(asm_code);
    $.each(data.code, function(k, v) {
      var code_block;
      code_block = $("<pre></pre>");
      code_block.data("id", k);
      code_block.attr("id", "code" + k);
      code_block.text(v);
      code_block.addClass("sh_cpp code" + k);
      c_codecode.append(code_block);
    });
    $.each(data.asm, function(k, v) {
      $.each(v, function(k2, v2) {
        var asm_block;
        asm_block = $("<pre></pre>");
        asm_block.text(v2);
        asm_block.addClass("sh_asm link" + k2);
        return asm_code.append(asm_block);
      });
    });
    c_codecode.find("pre").click(function() {
      var el, first, k2;
      k2 = $(this).data("id") + 1;
      el = this;
      first = $(".link" + k2).first();
      if (first.length > 0) {
        return asm_code.animate({
          scrollTop: first.offset().top - asm_code.offset().top + asm_code.scrollTop() - $(this).offset().top + asm_code.offset().top
        }, 1, function() {
          $(".glow").removeClass("glow");
          $("#connection").remove();
          return link(asm_code, c_codecode, el);
        });
      }
    });
    c_codecode.find("pre").hover(function() {
      return link(asm_code, c_codecode, this);
    }, function() {
      $(".glow").removeClass("glow");
      $("#connection").remove();
    });
    sh_highlightDocument();
    $("#compile").button('reset');
    return $('html, body').animate({
      scrollTop: $("#code").offset().top - 10
    }, 380);
  }
};

$(function() {
  $("#fileselect").dropdown();
  $("#fileselect li a").click(function(event) {
    var lang, programm;
    event.preventDefault();
    $("#loadcode").button('loading');
    programm = $(this).data("programm");
    lang = $(this).data("lang");
    $("#lang_" + lang).attr("checked", "checked");
    return $.get("code/" + programm + ".html", function(data) {
      $("#ccode").val(data);
      return $("#loadcode").button('reset');
    });
  });
  $("#compile").click(function(e) {
    $(this).button('loading');
    $.post("/compile", $("form").serialize(), function(response) {
      return render(response);
    });
    return false;
  });
});
