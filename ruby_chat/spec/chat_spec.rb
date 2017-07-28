require 'spec_helper'

describe Chat do
  context 'sends output to console' do
    let(:chat) { Chat.new('Khrystyna', BunnyMock.new.start)}

    it 'should have instance attributes' do
      expect(chat.current_user).to eq('Khrystyna')
      expect(chat.channel).not_to be_nil
      expect(chat.exchange).not_to be_nil
    end
  end
  context 'create correct RabbitMQ session' do
    let(:chat) { Chat.new('Khrystyna', BunnyMock.new.start)}

    it 'should create queues and exchanges' do
      queue = chat.channel.queue 'queue.test'
      expect(chat.session.queue_exists?('queue.test')).to be_truthy

      queue.delete
      expect(chat.session.queue_exists?('queue.test')).to be_falsey

      xchg = chat.channel.exchange 'xchg.test'
      expect(chat.session.exchange_exists?('xchg.test')).to be_truthy

      xchg.delete
      expect(chat.session.exchange_exists?('xchg.test')).to be_falsey
    end

    it 'should publish messages to queues' do

      queue = chat.channel.queue 'queue.test'

      queue.publish 'Testing message', priority: 5

      expect(queue.message_count).to eq(1)

      payload = queue.pop
      expect(queue.message_count).to eq(0)
      expect(payload[2]).to eq('Testing message')
      expect(payload[1][:priority]).to eq(5)
    end

    it 'should bind queues to exchanges' do

      queue = chat.channel.queue 'queue.test'
      xchg = chat.channel.exchange 'xchg.test'

      queue.bind xchg
      expect(queue.bound_to?(xchg)).to be_truthy
      expect(xchg.routes_to?(queue)).to be_truthy

      queue.unbind xchg
      expect(queue.bound_to?(xchg)).to be_falsey
      expect(xchg.routes_to?(queue)).to be_falsey

      queue.bind 'xchg.test'
      expect(queue.bound_to?(xchg)).to be_truthy
      expect(xchg.routes_to?(queue)).to be_truthy
    end

    it 'should bind exchanges to exchanges' do

      source = chat.channel.exchange 'xchg.source'
      receiver = chat.channel.exchange 'xchg.receiver'

      receiver.bind source
      expect(receiver.bound_to?(source)).to be_truthy
      expect(source.routes_to?(receiver)).to be_truthy

      receiver.unbind source
      expect(receiver.bound_to?(source)).to be_falsey
      expect(source.routes_to?(receiver)).to be_falsey

      receiver.bind 'xchg.source'
      expect(receiver.bound_to?(source)).to be_truthy
      expect(source.routes_to?(receiver)).to be_truthy
    end
  end
end
