require 'rubygems'

require 'deps/activiti-engine-5.11.jar'
require 'deps/spring-core-3.1.2.RELEASE.jar'
require 'deps/spring-beans-3.1.2.RELEASE.jar'
require 'deps/spring-asm-3.1.2.RELEASE.jar'
require 'deps/commons-logging-1.1.1.jar'
require 'deps/mybatis-3.1.1.jar'
require 'deps/postgresql-9.1-901.jdbc4.jar'

import org.activiti.engine.ProcessEngines

activiti_process_engine = ProcessEngines.getDefaultProcessEngine

Activiti = {
  runtime: activiti_process_engine.getRuntimeService,
  repository: activiti_process_engine.getRepositoryService,
  task: activiti_process_engine.getTaskService,
  form: activiti_process_engine.getFormService,
}

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
