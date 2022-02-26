# frozen_string_literal: true

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/jammy64'

  config.trigger.before :all do |trigger|
    trigger.info   = 'Avoid syncing repository'
    trigger.run    = { inline: 'git config --local sync.type never' }
    trigger.ignore = %i[destroy halt]
  end
end

# vim: ft=ruby
