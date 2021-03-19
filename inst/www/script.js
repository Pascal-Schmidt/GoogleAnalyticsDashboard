$(document).on('click', '.delete', function() {

    var clicked_id = $(this).attr('id');
    console.log(clicked_id)
    var h2_header = $("#" + clicked_id).parent().parent().text().trim();
    $(".class_" + clicked_id).remove();

    var html = '<div class="added_' + clicked_id +
    '"> <a id=' + clicked_id + ' href="#" class="action-button added_btn">' +
    h2_header + '</a></div>'

    if ($( "[class^='added_']" ).length) {
        last_class_added = document.querySelectorAll("[class^='added_']:last-child")[0].classList.value;
        $(html).insertAfter($("." + last_class_added));
    } else {
        $(html).insertAfter($("#sidebar-sidebar_viz"));
    }

});

$(document).on('click', '.added_btn', function() {
    var clicked_id = $(this).attr('id');
    console.log(clicked_id);
    var p = $("#" + clicked_id).parent().text();
    var p = $.trim(p);
    console.log(p)
    Shiny.setInputValue('header', p, {priority: 'event'});
    $(".added_" + clicked_id).remove();

    if($("[class^='class_']").length) {
        last_panel = $("[class^='class_']").last().attr("class");
        Shiny.setInputValue('last_panel', last_panel, {priority: 'event'});
    } else {
        Shiny.setInputValue('last_panel', '#placeholder', {priority: 'event'});
    }

    Shiny.setInputValue('add_btn_clicked', clicked_id, {priority: 'event'});

});

function open_sidebar() {
    document.getElementById('menu').style.width = "250px";
    document.getElementById('entire-sidebar').style.marginLeft = "250px";
}

function close_sidebar() {
    document.getElementById('menu').style.width = "0px";
    document.getElementById('entire-sidebar').style.marginLeft = "0px";
}

document.getElementById("refresh_data-go").addEventListener("click", function() {

    var IDs = $(".delete")
    .map(function() { return this.id; })
    .get();

    Shiny.setInputValue('all_present_vizs', IDs, {priority: 'event'});

});

