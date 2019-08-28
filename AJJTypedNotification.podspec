Pod::Spec.new do |spec|
  spec.name                      = 'AJJTypedNotification'
  spec.module_name               = 'TypedNotification'
  spec.version                   = '2.0.1'

  spec.license                   = { :type => 'MIT' }
  spec.homepage                  = 'https://github.com/alexjohnj/TypedNotification'
  spec.authors                   = { 'Alex Jackson' => 'alex@alexj.org' }
  spec.summary                   = 'Strongly typed notifications in Swift'
  spec.source                    = {
    :git => 'https://github.com/alexjohnj/TypedNotification.git',
    :tag => "v#{spec.version}"
  }

  spec.source_files              = 'Sources/TypedNotification.swift'
  spec.swift_version             = '5.0'
  spec.static_framework          = true

  spec.ios.deployment_target     = '10.0'
  spec.osx.deployment_target     = '10.12'
  spec.watchos.deployment_target = '3.0'
  spec.tvos.deployment_target    = '10.0'

  spec.test_spec do |tspec|
    tspec.source_files = 'Tests/TypedNotificationTests.swift'

    # Re-declare targets to avoid running tests on watchOS simulator.
    tspec.ios.deployment_target     = '10.0'
    tspec.osx.deployment_target     = '10.12'
    tspec.tvos.deployment_target    = '10.0'
  end
end
