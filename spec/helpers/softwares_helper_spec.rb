require 'spec_helper'

describe SoftwaresHelper do
  it "#collection_for_authentication_methods" do
    select = collection_for_authentication_methods
    assert select.include?([I18n.t("auth.internal"), "internal"])
    assert_equal SoftwareInstance::AVAILABLE_AUTHENTICATION_METHODS.size, select.size
  end
end
