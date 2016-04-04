var AsmBlock, CodeBlock, LineCanvas, codeb, link, pcodeb, render, updateCompileString;

CodeBlock = (function() {

  function CodeBlock(el, c_codecode, normaloff) {
    this.el = el;
    this.c_codecode = c_codecode;
    this.normaloff = normaloff;
  }

  CodeBlock.prototype.getPos = function() {
    return {
      x: 0,
      y1: $(this.el).offset().top - this.normaloff,
      y2: $(this.el).outerHeight() + $(this.el).offset().top - this.normaloff
    };
  };

  return CodeBlock;

})();

AsmBlock = (function() {

  function AsmBlock(el, c_codecode, normaloff) {
    this.el = el;
    this.c_codecode = c_codecode;
    this.normaloff = normaloff;
  }

  AsmBlock.prototype.getPos = function() {
    var start;
    start = $(this.el).offset().top - this.normaloff;
    return {
      x: this.parent.gap + 2,
      y1: start,
      y2: start + $(this.el).outerHeight()
    };
  };

  AsmBlock.prototype.update = function() {
    var left, right;
    right = this.getPos();
    left = this.parent.left.getPos();
    this.path.attr("path", "M" + left.x + " " + left.y1 + " C " + ((right.x - left.x) / 2) + " " + left.y1 + " " + ((right.x - left.x) / 2) + " " + right.y1 + " " + right.x + " " + right.y1 + " L " + right.x + " " + right.y2 + " C " + ((right.x - left.x) / 2) + " " + right.y2 + " " + ((right.x - left.x) / 2) + " " + left.y2 + " " + left.x + " " + left.y2 + " z");
  };

  return AsmBlock;

})();

LineCanvas = (function() {

  function LineCanvas(paper, left, max, gap) {
    this.paper = paper;
    this.left = left;
    this.max = max;
    this.gap = gap;
    this.container = [];
    this.paper.setSize(this.gap, this.max);
  }

  LineCanvas.prototype.add = function(item) {
    return this.container.push(item);
  };

  LineCanvas.prototype.update = function() {
    var item, _i, _len, _ref;
    _ref = this.container;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      item.update();
    }
  };

  return LineCanvas;

})();

pcodeb = null;

codeb = null;

link = function(asm_code, c_codecode, current, permanent) {
  var color, connection, gap, k2, lcanvas, max, normaloff, paper, prefix;
  prefix = permanent ? "p" : "";
  color = permanent ? "#B8FF79" : "#ffee79";
  $("." + prefix + "glow").removeClass("" + prefix + "glow");
  $("#" + prefix + "connection").remove();
  gap = asm_code.offset().left - c_codecode.offset().left - $(current).outerWidth() + 4;
  connection = $("<div id=\"" + prefix + "connection\"></div>");
  $(current).parent().append(connection);
  connection.css({
    "margin-left": $(current).outerWidth() - 1,
    top: c_codecode.offset().top - $(current).parent().parent().offset().top
  });
  normaloff = c_codecode.offset().top;
  max = Math.min(c_codecode.height(), asm_code.height());
  paper = Raphael("" + prefix + "connection", gap, max);
  lcanvas = new LineCanvas(paper, new CodeBlock(current, gap, normaloff), max, gap);
  $(current).addClass("" + prefix + "glow");
  k2 = $(current).data("id") + 1;
  $(".link" + k2).each(function() {
    var asmb;
    $(this).addClass("" + prefix + "glow");
    asmb = new AsmBlock($(this), gap, normaloff);
    asmb.path = paper.path("M  0 0 1 1 z");
    asmb.path.attr({
      stroke: "none",
      fill: color
    });
    asmb.parent = lcanvas;
    asmb.update();
    lcanvas.add(asmb);
  });
  if (permanent) {
    pcodeb = lcanvas;
  } else {
    codeb = lcanvas;
  }
};

render = function(data) {
  var asm_code, c_codecode;
  if (data.error != null) {
    $("#code").html("");
    $("#compile").button('reset');
    $("#error").text(data.error).show();
    $('html, body').animate({
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
    pcodeb = null;
    codeb = null;
    c_codecode.css({
      "overflow": "auto",
      height: $(window).height() - 100
    });
    asm_code.scroll(function() {
      if (codeb != null) codeb.update();
      if (pcodeb != null) return pcodeb.update();
    });
    c_codecode.scroll(function() {
      if (codeb != null) codeb.update();
      if (pcodeb != null) return pcodeb.update();
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
      link(asm_code, c_codecode, this, true);
      k2 = $(this).data("id") + 1;
      el = this;
      first = $(".link" + k2).first();
      if (first.length > 0) {
        return asm_code.animate({
          scrollTop: first.offset().top - asm_code.offset().top + asm_code.scrollTop() - $(this).offset().top + asm_code.offset().top
        }, 1);
      }
    });
  }
  c_codecode.find("pre").hover(function() {
    return link(asm_code, c_codecode, this, false);
  }, function() {
    codeb = null;
    $(".glow").removeClass("glow");
    $("#connection").remove();
  });
  sh_highlightDocument();
  $("#compile").button('reset');
  return $('html, body').animate({
    scrollTop: $("#code").offset().top - 10
  }, 380);
};

updateCompileString = function() {
  var compilestring = '';
  compilestring += $("input[name=arm]").is(":checked") ? "arm-linux-gnueabi-g++-4.6 " : "gcc ";
  compilestring += $("input[name='intel_asm']").is(":checked") ? "-masm=intel " : "";
  compilestring += "-std=" + $("select[name='standard']").val() + " ";
  compilestring += "-c ";
  compilestring += $("input[name='optimize']").is(":checked") ? "-O2 " : "";
  compilestring += "-Wa,-ald -g ";
  compilestring += "myCode." + $("input[name=language]:checked").val();

  $('#compilation_string').html(compilestring);
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
  updateCompileString();
  $("#compilation-form").change(updateCompileString);
});
