object @domain

attributes :id, :name, :type, :errors

child :records => :records do
  attributes :id, :name, :type, :content, :prio
end
