require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Snippet do

  let(:request)     { instance_double('Request', env: {}) }
  let(:services)    { Locomotive::Steam::Services.build_instance(request) }
  let(:finder)      { services.snippet_finder }
  let(:file_system) { Locomotive::Steam::Liquid::FileSystem.new(snippet_finder: finder) }
  let(:snippet)     { instance_double('Snippet', template: nil, :template= => nil, liquid_source: 'built by NoCoffee') }
  let(:source)      { 'Locomotive {% include footer %}' }

  before { allow(finder).to receive(:find).and_return(snippet) }

  describe 'parsing' do

    let(:page)      { instance_double('Page') }
    let!(:listener) { Liquid::SimpleEventsListener.new }
    let(:options)   { { page: page, snippet_finder: finder, parser: services.liquid_parser } }

    let!(:template) { parse_template(source, options) }

    it { expect(listener.event_names.first).to eq 'steam.parse.include' }

    # describe 'with an editable_element inside', pending: true do

    #   let(:snippet) { instance_double('Snippet', source: '{% editable_text company %}built by NoCoffee{% endeditable_text %}') }

    #   it { expect(listener.events.size).to eq 2 }

    # end

  end

  describe 'rendering' do

    let(:context) { ::Liquid::Context.new({}, {}, { services: services, file_system: file_system }) }

    subject { render_template(source, context) }

    it { is_expected.to eq 'Locomotive built by NoCoffee' }

    context 'rendering error (action) found in the snippet' do

      let(:snippet) { instance_double('Snippet', template: nil, :template= => nil, liquid_source: '{% action "Hello world" %}a.b(+}{% endaction %}') }

      it 'raises a TemplateError' do
        expect { subject }.to raise_exception(Locomotive::Steam::TemplateError)
      end

    end

  end

end
