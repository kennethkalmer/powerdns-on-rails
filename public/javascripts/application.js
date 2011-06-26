// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(document).ready(function() {

  // Setup tooltips where required
  $('.help-icn').each(function(i, icon){
    $(icon).tipTip({
      content: $( "#" + $(icon).data("help") ).text()
    });
  });

  // Used on /domains by the new record form
  $('#record-form #record_type').change(function(e) {
    toggleRecordFields( $(this).val() );
  });
});

