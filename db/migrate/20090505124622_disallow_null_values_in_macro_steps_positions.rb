class DisallowNullValuesInMacroStepsPositions < ActiveRecord::Migration
  def self.up
    change_column_null :macro_steps, :position, false
  end

  def self.down
    change_column_null :macro_steps, :position, true
  end
end
