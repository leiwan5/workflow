class ProcessInstancesController < ApplicationController
  def index
    query = Activiti[:history].createHistoricProcessInstanceQuery()
    query = query.processDefinitionId(params[:process_definition_id]) if params[:process_definition_id]
    instances = query.list
    items = instances.map do |inst|
      {
        :id => inst.getId,
        :definition_id => inst.getProcessDefinitionId,
        :start_time => Time.at(inst.getStartTime.getTime/1000),
        :start_user_id => inst.getStartUserId,
        :business_key => inst.getBusinessKey
      }
    end
    render json: items
  end

  def show
    
  end

  def create
    definition = Activiti[:repository].createProcessDefinitionQuery.processDefinitionId(params[:process_definition_id]).singleResult
    if definition
      begin
        variables = java.util.HashMap.new params[:variables]

        instance = Activiti[:runtime].startProcessInstanceById definition.getId, nil, variables
        render json: {
          instance_id: instance.getId
        }
      rescue Exception => e
        render json: {
          failed: true,
          message: e.message
        }
      end
    else
      render json: {
        failed: true,
        message: 'process definition not found'
      }
    end
  end
end
