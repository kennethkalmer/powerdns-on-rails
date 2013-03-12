Factory.define(:macro) do |f|
  f.name 'Move to West Coast'
  f.active true
end

Factory.define(:macro_step_create, :class => MacroStep) do |f|
  f.action 'create'
  f.record_type 'A'
  f.name 'auto'
  f.content '127.0.0.1'
end

Factory.define(:macro_step_change, :class => MacroStep) do |f|
  f.action 'update'
  f.record_type 'A'
  f.name 'www'
  f.content '127.1.1.1'
end

Factory.define(:macro_step_remove, :class => MacroStep) do |f|
  f.action 'remove'
  f.record_type 'A'
  f.name 'ftp'
end

