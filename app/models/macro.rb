# = Overview
#
# Macros are used by PowerDNS on Rails to apply a whole sequence of updates to a
# specific domain in the system.
#
# The following pseudo examples might help clear it up a bit
#
# Name: Change MX to Postini
# Action 1: Remove existing MX records
# Action 2: Add 4 new MX records based on template
#
# Name: Add asset hosts to Rails app
# Action 1: Add A record for static1.%ZONE%
# Action 2: Add A record for static2.%ZONE%
#
# == Implementation
#
# The #Macro model serves are a container for a number of steps (defined as
# #MacroStep), and will perform the changes on a domain as defined by each step.
#
# Steps are ordered and will be executed in that order.
#
class Macro < ActiveRecord::Base

  scope_user
  
  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :macro_steps, :dependent => :destroy
  belongs_to :user
end

