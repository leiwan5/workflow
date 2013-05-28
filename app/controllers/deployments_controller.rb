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
    deployment = Activiti[:repository].createDeployment.addString(
      params[:file].original_filename, 
      params[:file].read
    ).deploy
    render json: {
      id: deployment.getId,
      name: deployment.getName,
      deployment_time: deployment.getDeploymentTime,
      category: deployment.getCategory
    }
  end

  def destroy
    Activiti[:repository].deleteDeployment params[:id], true
    render json: {
      id: params[:id]
    }
  end
end
