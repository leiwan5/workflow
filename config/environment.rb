# Load the rails application

require 'deps/activiti-engine-5.11.jar'
require 'deps/spring-core-3.1.2.RELEASE.jar'
require 'deps/spring-beans-3.1.2.RELEASE.jar'
require 'deps/spring-asm-3.1.2.RELEASE.jar'
require 'deps/commons-logging-1.1.1.jar'
require 'deps/mybatis-3.1.1.jar'
require 'deps/postgresql-9.1-901.jdbc4.jar'
require 'deps/mysql-connector-java-5.1.25-bin.jar'

import org.activiti.engine.ProcessEngines

activiti_process_engine = ProcessEngines.getDefaultProcessEngine

Activiti = {
  runtime: activiti_process_engine.getRuntimeService,
  repository: activiti_process_engine.getRepositoryService,
  task: activiti_process_engine.getTaskService,
  form: activiti_process_engine.getFormService,
  history: activiti_process_engine.getHistoryService
}

require File.expand_path('../application', __FILE__)

# Initialize the rails application
Workflow::Application.initialize!
