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
      render :json => {
        id: definition.getId,
        name: definition.getName,
        key: definition.getKey,
        deployment_id: definition.getDeploymentId,
        version: definition.getVersion,
        diagram_resource_name: definition.getDiagramResourceName,
        resource_name: definition.getResourceName
      }
    else
      render json: {error: 'not found'}, status: 404
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
      render json: {error: 'not found'}, status: 404
    end
  end
end
