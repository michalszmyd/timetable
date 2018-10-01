# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportsController do
  render_views
  let(:user) { create(:user) }
  let(:manager) { create(:manager) }

  describe '#project' do
    it 'authenticates user' do
      get :project, format: :csv
      expect(response.code).to eql('401')
    end

    it 'forbids regular user' do
      sign_in(user)
      get :project, format: :csv
      expect(response.code).to eql('403')
    end

    it 'returns project report in csv' do
      sign_in(manager)
      user = create(:user)
      project = create(:project, work_times_allows_task: true)
      work_time1 = create(:work_time, task: 'http://example.com/task/24', user: user, project: project, starts_at: '2016-01-05 08:00:00', ends_at: '2016-01-05 10:00:00')
      work_time2 = create(:work_time, task: 'http://example.com/task/24', user: user, project: project, starts_at: '2016-01-05 12:00:00', ends_at: '2016-01-05 13:00:00')
      work_time3 = create(:work_time, user: user, project: project, starts_at: '2016-01-05 10:00:00', ends_at: '2016-01-05 12:00:00')
      get :project, params: { id: project.id, from: '2016-01-01 00:00:00', to: '2016-01-31 23:59:59' }, format: :csv

      expect(response.code).to eql('200')
      require 'csv'
      csv = CSV.parse(response.body)
      expect(csv[0]).to eql(['Developer', 'Date', 'Task URL', 'Description', 'Duration'])
      expect(csv[1]).to eql([user.to_s, '2016-01-05', 'http://example.com/task/24', work_time1.body, '02:00'])
      expect(csv[2]).to eql([user.to_s, '2016-01-05', 'http://example.com/task/24', work_time2.body, '01:00'])
      expect(csv[3]).to eql([user.to_s, nil, nil, nil, '03:00'])
      expect(csv[4]).to eql([user.to_s, '2016-01-05', nil, work_time3.body, '02:00'])
      expect(csv[5]).to eql(['Developer Total', nil, nil, nil, '05:00'])
    end

    it 'returns project report in csv for user' do
      sign_in(manager)
      user = create(:user)
      project = create(:project, work_times_allows_task: true)
      work_time1 = create(:work_time, task: 'http://example.com/task/24', user: user, project: project, starts_at: '2016-01-05 08:00:00', ends_at: '2016-01-05 10:00:00')
      work_time2 = create(:work_time, task: 'http://example.com/task/24', user: user, project: project, starts_at: '2016-01-05 12:00:00', ends_at: '2016-01-05 13:00:00')
      work_time3 = create(:work_time, user: user, project: project, starts_at: '2016-01-05 10:00:00', ends_at: '2016-01-05 12:00:00')
      get :project, params: { user_id: user.id, id: project.id, from: '2016-01-01 00:00:00', to: '2016-01-31 23:59:59' }, format: :csv

      expect(response.code).to eql('200')
      require 'csv'
      csv = CSV.parse(response.body)
      expect(csv[0]).to eql(['Date', 'Task URL', 'Description', 'Duration'])
      expect(csv[1]).to eql(['2016-01-05', 'http://example.com/task/24', work_time1.body, '02:00'])
      expect(csv[2]).to eql(['2016-01-05', 'http://example.com/task/24', work_time2.body, '01:00'])
      expect(csv[3]).to eql([nil, nil, nil, '03:00'])
      expect(csv[4]).to eql(['2016-01-05', nil, work_time3.body, '02:00'])
      expect(csv[5]).to eql(['Developer Total', nil, nil, '05:00'])
    end
  end
end