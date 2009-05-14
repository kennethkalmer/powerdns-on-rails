// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// Easily control flash visibility from RJS
function showflash( level, message ) {
  f = $('flash-' + level);
  f.innerHTML = message;
  f.show();
  setTimeout( "$('flash-" + level + "').hide()", 5000 ) // hide after 7 seconds
}
