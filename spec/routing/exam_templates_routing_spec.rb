require "rails_helper"

RSpec.describe Exam::ExamTemplatesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "exam/exam_templates").to route_to("exam/exam_templates#index")
    end

    it "routes to #new" do
      expect(:get => "exam/exam_templates/new").to route_to("exam/exam_templates#new")
    end

    it "routes to #show" do
      expect(:get => "exam/exam_templates/1").to route_to("exam/exam_templates#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "exam/exam_templates/1/edit").to route_to("exam/exam_templates#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "exam/exam_templates").to route_to("exam/exam_templates#create")
    end

    it "routes to #update" do
      expect(:put => "exam/exam_templates/1").to route_to("exam/exam_templates#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "exam/exam_templates/1").to route_to("exam/exam_templates#destroy", :id => "1")
    end

  end
end
