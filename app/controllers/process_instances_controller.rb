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

  def diagram
    instance = Activiti[:history].createHistoricProcessInstanceQuery.processInstanceId(params[:id]).singleResult
    execution = Activiti[:runtime].createExecutionQuery.processInstanceId(params[:id]).singleResult
    definition = Activiti[:repository].createProcessDefinitionQuery.processDefinitionId(instance.getProcessDefinitionId).singleResult if instance
    bpmn_model = Activiti[:repository].getBpmnModel(instance.getProcessDefinitionId) if instance
    if instance and execution and definition and bpmn_model
      stream = org.activiti.engine.impl.bpmn.diagram.ProcessDiagramGenerator.generateDiagram(
          bpmn_model, 'png', Activiti[:runtime].getActiveActivityIds(execution.getId)
        )
      size = stream.available
      bytes = Java::byte[size].new
      stream.read bytes, 0, size

      respond_to do |format|
        format.png do
          send_data bytes.to_s, disposition: 'inline', type: 'image/png', filename: definition.getDiagramResourceName()
        end
        format.json do
          render json: {
            data: Base64::strict_encode64(bytes.to_s)
          }        
        end
      end
    else
      render json: {
          message: 'not found',
          failed: true
        }, status: 404
    end
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
