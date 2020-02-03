require 'spec_helper'

RSpec.describe SimCtl do
  describe '#warmup' do
    if SimCtl.device_set_path.nil?
      it 'warms up and returns a device for given strings' do
        expect(SimCtl.warmup('iPhone 6', 'iOS 12.1')).to be_kind_of SimCtl::Device
      end

      it 'warms up and returns a device for given objects' do
        devicetype = SimCtl.devicetype(name: 'iPhone 6')
        runtime = SimCtl::Runtime.latest(:ios)
        expect(SimCtl.warmup(devicetype, runtime)).to be_kind_of SimCtl::Device
      end
    else
      it 'raises exception' do
        expect { SimCtl.warmup('iPhone 6', 'iOS 12.1') }.to raise_error SimCtl::DeviceNotFound
      end
    end
  end
end
