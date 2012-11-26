FactoryGirl.define do
  factory(:macro) do
    name 'Move to West Coast'
    active true
  end

  factory(:macro_step_create, :class => MacroStep) do
    action 'create'
    record_type 'A'
    name 'auto'
    content '127.0.0.1'
  end

  factory(:macro_step_change, :class => MacroStep) do
    action 'update'
    record_type 'A'
    name 'www'
    content '127.1.1.1'
  end

  factory(:macro_step_remove, :class => MacroStep) do
    action 'remove'
    record_type 'A'
    name 'ftp'
  end
end

