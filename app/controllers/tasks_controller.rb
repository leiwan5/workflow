class TasksController < ApplicationController

  # 获取任务列表
  def index
    query = Activiti[:task].createTaskQuery()
    query = query.processInstanceId(params[:process_instance_id]) if params[:process_instance_id]
    query = query.taskUnassigned if params[:unassigned].to_s == 'true'
    [:assignee, :candidate_user, :name_like,
      :candidate_group, :candidate_group_in, :name].each do |item|
      query = query.send('task' + item.to_s.camelize, params[item]) if params[item]
    end

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

  # 分配任务
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

  # 取消分配任务
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

  # 完成任务
  def complete
    task = Activiti[:task].createTaskQuery().taskId(params[:id]).singleResult
    if task
      begin
        variables = java.util.HashMap.new params[:variables]
        Activiti[:task].complete task.getId, variables
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

  # 任务表单属性
  def form_properties
    task = Activiti[:task].createTaskQuery().taskId(params[:id]).singleResult
    if task
      begin
        properties = Activiti[:form].getTaskFormData(task.getId).getFormProperties().map do |item|
          {
            id: item.getId,
            name: item.getName,
            value: item.getValue,
            type: item.getType.getName,
            required: item.isRequired,
            readable: item.isReadable,
            writeable: item.isWriteable
          }
        end
        render json: properties
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
