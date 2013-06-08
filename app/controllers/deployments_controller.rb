class DeploymentsController < ApplicationController
  def index
    deployments = Activiti[:repository].createDeploymentQuery.list.map do |item|
      {
        id: item.getId,
        name: item.getName,
        deployment_time: item.getDeploymentTime,
        category: item.getCategory
      }
    end
    render json: deployments
  end

  def create
    if params[:file].is_a? ActionDispatch::Http::UploadedFile
      filename = params[:file].original_filename
      data = params[:file].read
    else
      filename = params[:file][:name]
      data = params[:file][:data]
    end

    begin
      deployment = Activiti[:repository].createDeployment.addString(
        filename, data
      ).deploy
      render json: {
        id: deployment.getId,
        name: deployment.getName,
        deployment_time: deployment.getDeploymentTime,
        category: deployment.getCategory
      }
    rescue Exception => e
      render json: {
        failed: true,
        message: e.message
      }
    end
  end

  def destroy
    Activiti[:repository].deleteDeployment params[:id], true
    render json: {
      id: params[:id]
    }
  end
end
