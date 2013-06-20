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
      Activiti[:runtime].setVariable(execution.getId, params[:id], params[:value])
      render json: {}
    else
      render json: {
        failed: true,
        message: 'instance not found'
      }
    end
  end
end
