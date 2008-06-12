# A collection of helper methods to ease the use of Prototip throughout the 
module PrototipHelper
  
  # Insert a help icon that displays the content of +dom_id+ in a tooltip
  def prototip_help_icon( dom_id )
    html = image_tag( 'help.png', :id => 'proto-' + dom_id )
    html << javascript_tag( :defer => 'defer' ) do
      <<-EOF
        new Tip('proto-#{dom_id}', $('#{dom_id}'), {
        title: 'Quick Help',
        stem: 'leftTop',
        delay: true,
        hideAfter: 2,
        hook: { target: 'middleRight', tip: 'leftTop' },
        hideOn: { element: 'closeButton', event: 'click' },
        offset: { x: 15, y: 0 }
        });
      EOF
    end
  end
end