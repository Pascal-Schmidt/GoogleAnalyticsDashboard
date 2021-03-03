$(document).on('click', '.delete', function() {

    var clicked_id = $(this).attr('id');
    class_delete = clicked_id.split("_")[1];
    $(".class_" + class_delete).remove();

    var html = '<div class="added_' + class_delete + '"><p>' + class_delete +
    '</p> <button class="btn btn-default action-button btn-success added_btn shiny-bound-input" id="add_' +
    class_delete + '" type="button"><i class="fa fa-plus"></i></button></div>'

    if ($( "[class^='added_']" ).length) {
        last_class_added = document.querySelectorAll("[class^='added_']:last-child")[0].classList.value;
        $(html).insertAfter($("." + last_class_added));
    } else {
        last_panel = document.querySelectorAll("[class^='class_']:last-child")[0].classList.value;
        $(html).insertAfter($("." + last_panel));
    }
    console.log($("[class^='class_']"));

});

$(document).on('click', '.added_btn', function() {
    var clicked_id = $(this).attr('id');
    class_delete = clicked_id.split("_")[1];
    $(".added_" + class_delete).remove();

    console.log($("[class^='class_']").last().attr("class"));

    if($("[class^='class_']").length) {
        last_panel = $("[class^='class_']").last().attr("class");
        Shiny.setInputValue('last_panel', last_panel, {priority: 'event'});
    } else {
        Shiny.setInputValue('last_panel', '#placeholder', {priority: 'event'});
    }

    Shiny.setInputValue('add_btn_clicked', clicked_id, {priority: 'event'});

});

