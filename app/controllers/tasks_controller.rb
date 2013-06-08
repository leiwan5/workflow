class TasksController < ApplicationController
  def index
    query = Activiti[:task].createTaskQuery()
    query = query.processInstanceId(params[:process_instance_id]) if params[:process_instance_id]
    items = query.list.map do |task|
      {
        :id => task.getId,
        :name => task.getName,
        :execution_id => task.getExecutionId,
        :process_instance_id => task.getProcessInstanceId,
        :parent_task_id => task.getParentTaskId,
        :owner => task.getOwner,
        :create_date => Time.at(task.getCreateTime.getTime/1000),
        :assignee => task.getAssignee,
        :description => task.getDescription
      }
    end
    render json: items
  end

  def complete
    task = Activiti[:task].createTaskQuery().taskId(params[:id]).singleResult
    if task
      begin
        Activiti[:task].complete task.getId
        render json: {}
      rescue Exception => e
        render json: {
          failed: true,
          message: e.message
        }
      end
    else
      render json: {
        failed: true,
        message: 'task not found'
      }
    end
  end

  def claim
    task = Activiti[:task].createTaskQuery().taskId(params[:id]).singleResult
    if task
      begin
        Activiti[:task].claim task.getId, params[:user_id].to_s
        render json: {}
      rescue Exception => e
        render json: {
          failed: true,
          message: e.message
        }
      end
    else
      render json: {
        failed: true,
        message: 'task not found'
      }
    end
  end

  def unclaim
    task = Activiti[:task].createTaskQuery().taskId(params[:id]).singleResult
    if task
      begin
        Activiti[:task].claim task.getId, nil
        render json: {}
      rescue Exception => e
        render json: {
          failed: true,
          message: e.message
        }
      end
    else
      render json: {
        failed: true,
        message: 'task not found'
      }
    end
  end
end
