var render;

render = function(data) {
  if (data.error != null) {
    $("#code").html("");
    $("#compile").button('reset');
    $("#error").text(data.error).show();
    return $('html, body').animate({
      scrollTop: $("#error").offset().top - 100
    }, 380);
  } else if (data.data != null) {
    $("#error").text("").hide();
    $("#code").html("<h2>Code Comparison</h2>");
    $.each(data.data, function(k, v) {
      var assembly_block, code_block, row;
      code_block = $("<pre></pre>");
      code_block.data("id", k);
      code_block.attr("id", "code" + k);
      code_block.text(v.code);
      code_block.addClass("span6 sh_cpp code" + v.code_part);
      assembly_block = $("<pre></pre>");
      assembly_block.data("id", k);
      assembly_block.attr("id", "assembly" + k);
      assembly_block.addClass("span5 sh_asm assembly" + v.assembly_part);
      assembly_block.text(v.assembly);
      row = $("<div></div>");
      if (code_block.text() === "") {
        assembly_block.addClass("offset7");
      } else {
        row.append(code_block);
        assembly_block.addClass("offset1");
      }
      row.append(assembly_block);
      row.addClass("row-fluid");
      $("#code").append(row);
    });
    $.each(data.mapping, function(k, v) {
      $(".code" + k).hover((function(v) {
        return function() {
          var connection, gap, left, max, normaloff, paper;
          gap = $(this).siblings().offset().left - $(this).offset().left - $(this).outerWidth() + 4;
          connection = $("<div id=\"connection\" class=\"offset6\"></div>");
          $(this).parent().append(connection);
          connection.css({
            "margin-left": $(this).outerWidth() - 1
          });
          left = {
            x: 0,
            y1: 0,
            y2: $(this).outerHeight()
          };
          paper = Raphael("connection", gap, left.y2);
          normaloff = $(this).offset().top;
          max = left.y2;
          $(this).addClass("glow");
          $.each(v, function(k, a) {
            var c, right, start;
            $(".assembly" + a).addClass("glow");
            start = $(".assembly" + a).offset().top - normaloff;
            right = {
              x: gap + 2,
              y1: start,
              y2: start + $(".assembly" + a).outerHeight()
            };
            if (right.y2 > max) {
              max = right.y2;
              paper.setSize(gap, max);
            }
            c = paper.path("M" + left.x + " " + left.y1 + " C " + ((right.x - left.x) / 2) + " " + left.y1 + " " + ((right.x - left.x) / 2) + " " + right.y1 + " " + right.x + " " + right.y1 + " L " + right.x + " " + right.y2 + " C " + ((right.x - left.x) / 2) + " " + right.y2 + " " + ((right.x - left.x) / 2) + " " + left.y2 + " " + left.x + " " + left.y2 + " z");
            c.attr({
              stroke: "none",
              fill: "#eee"
            });
          });
        };
      })(v), function() {
        $(".glow").removeClass("glow");
        $("#connection").remove();
      });
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
