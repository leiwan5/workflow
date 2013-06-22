class VariablesController < ApplicationController
  def index
    execution = Activiti[:runtime].createExecutionQuery.processInstanceId(params[:process_instance_id]).singleResult
    if execution
      vars = Activiti[:runtime].getVariables(execution.getId)
    else
      vars = {}
    end
    render json: vars.to_hash
  end

  def show
    execution = Activiti[:runtime].createExecutionQuery.processInstanceId(params[:process_instance_id]).singleResult
    if execution
      value = Activiti[:runtime].getVariable(execution.getId, params[:id])
    else
      value = nil
    end
    unless value
      render json: 'not found', status: 404
    else
      var = {}
      var[params[:id]] = value
      render json: var
    end
  end

  def update
    execution = Activiti[:runtime].createExecutionQuery.processInstanceId(params[:process_instance_id]).singleResult
    if execution
      if params[:id] == 0 and params[:variables]
        params[:variables].each do |var|
          Activiti[:runtime].setVariable(execution.getId, var[:name], var[:value])
        end
      else
        Activiti[:runtime].setVariable(execution.getId, params[:id], params[:value])
      end
      render json: Activiti[:runtime].getVariables(execution.getId).to_hash
    else
      render json: {
        failed: true,
        message: 'instance not found'
      }
    end
  end
end
