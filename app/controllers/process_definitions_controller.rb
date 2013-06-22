class ProcessDefinitionsController < ApplicationController
  def index
    definitions = Activiti[:repository].createProcessDefinitionQuery.list.map do |item|
      {
        id: item.getId,
        name: item.getName,
        key: item.getKey,
        deployment_id: item.getDeploymentId,
        version: item.getVersion,
        diagram_resource_name: item.getDiagramResourceName,
        resource_name: item.getResourceName
      }
    end
    render json: definitions
  end

  def show
    definition = Activiti[:repository].createProcessDefinitionQuery.processDefinitionId(params[:id]).singleResult
    if definition
      respond_to do |format|
        format.json do
          render :json => {
            id: definition.getId,
            name: definition.getName,
            key: definition.getKey,
            deployment_id: definition.getDeploymentId,
            version: definition.getVersion,
            diagram_resource_name: definition.getDiagramResourceName,
            resource_name: definition.getResourceName
          }
        end

        format.bpmn do
          stream = Activiti[:repository].getResourceAsStream(
            definition.getDeploymentId, definition.getResourceName
          )
          size = stream.available
          bytes = Java::byte[size].new
          stream.read bytes, 0, size
          send_data bytes.to_s, disposition: 'inline', type: 'text/xml',
            filename: definition.getResourceName
        end
      end
    else
      render json: {
          message: 'not found',
          failed: true
        }, status: 404
    end    
  end

  def properties
    data = Activiti[:form].getStartFormData(params[:id]).getFormProperties rescue nil
    if data
       data = data.map do |item|
        {
          id: item.getId,
          name: item.getName,
          value: item.getValue,
          type: item.getType.getName,
          required: item.isRequired,
          readable: item.isReadable,
          writeable: item.isWritable
        }
      end
      render json: data
    else
      render json: {
          message: 'not found',
          failed: true
        }, status: 404
    end
  end

  def diagram
    definition = Activiti[:repository].createProcessDefinitionQuery.processDefinitionId(params[:id]).singleResult
    if definition
      stream = Activiti[:repository].getResourceAsStream(definition.getDeploymentId(), definition.getDiagramResourceName())
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

  def bpmn_model
    definition = Activiti[:repository].createProcessDefinitionQuery.processDefinitionId(params[:id]).singleResult
    if definition
      model = Activiti[:repository].getBpmnModel(definition.getId)
      elements = model.getMainProcess.getFlowElements

      nodes = elements.find_all{|el| el.is_a? org.activiti.bpmn.model.FlowNode}.map do |el|
        if el.is_a? org.activiti.bpmn.model.StartEvent
          properties = el.getFormProperties.map do |item|
            {
              name: item.getName,
              variable: item.getVariable,
              type: item.getType,
              default_expression: item.getDefaultExpression,
              required: item.isRequired,
              readable: item.isReadable,
              writeable: item.isWriteable,
              form_values: item.getFormValues.map{|v| v.getName}
            }
          end
          {
            name: el.getName,
            documentation: el.getDocumentation,
            type: :start_event,
            form_properties: properties
          }
        elsif el.is_a? org.activiti.bpmn.model.EndEvent
          {
            name: el.getName,
            documentation: el.getDocumentation,
            type: :end_event
          }
        elsif el.is_a? org.activiti.bpmn.model.UserTask
          properties = el.getFormProperties.map do |item|
            {
              name: item.getName,
              variable: item.getVariable,
              type: item.getType,
              default_expression: item.getDefaultExpression,
              required: item.isRequired,
              readable: item.isReadable,
              writeable: item.isWriteable,
              form_values: item.getFormValues.map{|v| v.getName}
            }
          end
          {
            name: el.getName,
            documentation: el.getDocumentation,
            type: :user_task,
            assignee: el.getAssignee,
            priority: el.getPriority,
            due_date: el.getDueDate,
            candidate_users: el.getCandidateUsers.to_a,
            candidate_groups: el.getCandidateGroups.to_a,
            form_properties: properties            
          }
        else
          {
            name: el.getName,
            documentation: el.getDocumentation,
            type: el.class.to_s.split('::').last.underscore
          }
        end
      end
      render json: {
        nodes: nodes
      }        
    else
      render json: {
          message: 'not found',
          failed: true
        }, status: 404
    end
  end
end
