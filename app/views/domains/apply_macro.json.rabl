# Has the macro been applied yet?
if @macro.present?
  # Yes
  object @domain
  attributes :id, :name, :type
  child :records => :records do
    attributes :id, :name, :type, :content, :prio
  end

else
  # No
  collection @macros
  attributes :id, :name

end
