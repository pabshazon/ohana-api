require 'rails_helper'

describe Admin::ServiceContactsController do
  describe 'GET edit' do
    before(:each) do
      @location = create(:location_with_admin)
      @service = @location.services.create!(attributes_for(:service))
      @contact = @service.contacts.create!(attributes_for(:contact))
    end

    context 'when admin is super admin' do
      it 'allows access to edit contact' do
        log_in_as_admin(:super_admin)

        get :edit, location_id: @location.id, service_id: @service.id, id: @contact.id

        expect(response).to render_template(:edit)
      end
    end

    context 'when admin is regular admin without privileges' do
      it 'redirects to admin dashboard' do
        create(:location_for_org_admin)
        log_in_as_admin(:admin)

        get :edit, location_id: @location.id, service_id: @service.id, id: @contact.id

        expect(response).to redirect_to admin_dashboard_path
        expect(flash[:error]).to eq(I18n.t('admin.not_authorized'))
      end
    end

    context 'when admin is regular admin with privileges' do
      it 'redirects to admin dashboard' do
        log_in_as_admin(:location_admin)

        get :edit, location_id: @location.id, service_id: @service.id, id: @contact.id

        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'GET new' do
    before(:each) do
      @location = create(:location_with_admin)
      @service = @location.services.create!(attributes_for(:service))
    end

    context 'when admin is super admin' do
      it 'allows access to create contact' do
        log_in_as_admin(:super_admin)

        get :new, location_id: @location.id, service_id: @service.id

        expect(response).to render_template(:new)
      end
    end

    context 'when admin is regular admin without privileges' do
      it 'redirects to admin dashboard' do
        create(:location_for_org_admin)
        log_in_as_admin(:admin)

        get :new, location_id: @location.id, service_id: @service.id

        expect(response).to redirect_to admin_dashboard_path
        expect(flash[:error]).to eq(I18n.t('admin.not_authorized'))
      end
    end

    context 'when admin is regular admin with privileges' do
      it 'allows access to create contact' do
        log_in_as_admin(:location_admin)

        get :new, location_id: @location.id, service_id: @service.id

        expect(response).to render_template(:new)
      end
    end
  end

  describe 'create' do
    before(:each) do
      @location = create(:location_with_admin)
      @service = @location.services.create!(attributes_for(:service))
    end

    context 'when admin is super admin' do
      it 'allows access to create contact' do
        log_in_as_admin(:super_admin)

        post :create, location_id: @location.id, service_id: @service.id, contact: { name: 'Jane' }

        expect(response).
          to redirect_to "/admin/locations/#{@location.friendly_id}/services/#{@service.id}"
      end
    end

    context 'when admin is regular admin without privileges' do
      it 'redirects to admin dashboard' do
        create(:location_for_org_admin)
        log_in_as_admin(:admin)

        post :create, location_id: @location.id, service_id: @service.id, contact: { name: 'Jane' }

        expect(response).to redirect_to admin_dashboard_path
        expect(flash[:error]).to eq(I18n.t('admin.not_authorized'))
        expect(@service.contacts).to be_empty
      end
    end

    context 'when admin is regular admin allowed to create a contact' do
      it 'creates the contact' do
        log_in_as_admin(:location_admin)

        post :create, location_id: @location.id, service_id: @service.id, contact: { name: 'Jane' }

        expect(response).
          to redirect_to "/admin/locations/#{@location.friendly_id}/services/#{@service.id}"
        expect(@service.contacts.last.name).to eq 'Jane'
      end
    end
  end

  describe 'update' do
    before(:each) do
      @location = create(:location_with_admin)
      @service = @location.services.create!(attributes_for(:service))
      @contact = @service.contacts.create!(attributes_for(:contact))
    end

    context 'when admin is super admin' do
      it 'allows access to update contact' do
        log_in_as_admin(:super_admin)

        post(
          :update,
          location_id: @location.id, service_id: @service.id,
          id: @contact.id, contact: { name: 'Jane' }
        )

        path_prefix = "/admin/locations/#{@location.friendly_id}/services/#{@service.id}/contacts"

        expect(response).to redirect_to "#{path_prefix}/#{@contact.id}"
      end
    end

    context 'when admin is regular admin without privileges' do
      it 'redirects to admin dashboard' do
        create(:location_for_org_admin)
        log_in_as_admin(:admin)

        post(
          :update,
          location_id: @location.id, service_id: @service.id,
          id: @contact.id, contact: { name: 'Jane' }
        )

        expect(response).to redirect_to admin_dashboard_path
        expect(flash[:error]).to eq(I18n.t('admin.not_authorized'))
        expect(@contact.reload.name).to_not eq 'Jane'
      end
    end

    context 'when admin is regular admin allowed to edit this contact' do
      it 'updates the contact' do
        log_in_as_admin(:location_admin)

        post(
          :update,
          location_id: @location.id, service_id: @service.id,
          id: @contact.id, contact: { name: 'Jane' }
        )

        path_prefix = "/admin/locations/#{@location.friendly_id}/services/#{@service.id}/contacts"

        expect(response).to redirect_to "#{path_prefix}/#{@contact.id}"
        expect(@contact.reload.name).to eq 'Jane'
      end
    end
  end

  describe 'destroy' do
    before(:each) do
      @location = create(:location_with_admin)
      @service = @location.services.create!(attributes_for(:service))
      @contact = @service.contacts.create!(attributes_for(:contact))
    end

    context 'when admin is super admin' do
      it 'allows access to destroy contact' do
        log_in_as_admin(:super_admin)

        delete :destroy, location_id: @location.id, service_id: @service.id, id: @contact.id

        expect(response).
          to redirect_to "/admin/locations/#{@location.friendly_id}/services/#{@service.id}"
      end
    end

    context 'when admin is regular admin without privileges' do
      it 'redirects to admin dashboard' do
        create(:location_for_org_admin)
        log_in_as_admin(:admin)

        delete :destroy, location_id: @location.id, service_id: @service.id, id: @contact.id

        expect(response).to redirect_to admin_dashboard_path
        expect(flash[:error]).to eq(I18n.t('admin.not_authorized'))
        expect(@contact.reload.name).to eq 'Moncef Belyamani'
      end
    end

    context 'when admin is regular admin allowed to destroy this contact' do
      it 'destroys the contact' do
        log_in_as_admin(:location_admin)

        delete :destroy, location_id: @location.id, service_id: @service.id, id: @contact.id

        expect(response).
          to redirect_to "/admin/locations/#{@location.friendly_id}/services/#{@service.id}"
        expect(Contact.find_by(id: @contact.id)).to be_nil
      end
    end
  end
end
