# frozen_string_literal: true

RSpec.describe TTY::Cursor do
  subject(:cursor) { described_class }

  it "scrolls down by one line" do
    expect(cursor.scroll_down).to eq("\eD")
  end

  it "scrolls up by one line" do
    expect(cursor.scroll_up).to eq("\eM")
  end
end
