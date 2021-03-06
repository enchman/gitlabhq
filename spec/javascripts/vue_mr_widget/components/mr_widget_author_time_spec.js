import Vue from 'vue';
import authorTimeComponent from '~/vue_merge_request_widget/components/mr_widget_author_time.vue';
import mountComponent from '../../helpers/vue_mount_component_helper';

describe('MRWidgetAuthorTime', () => {
  let vm;

  beforeEach(() => {
    const Component = Vue.extend(authorTimeComponent);

    vm = mountComponent(Component, {
      actionText: 'Merged by',
      author: {
        name: 'Administrator',
        username: 'root',
        webUrl: 'http://localhost:3000/root',
        avatarUrl: 'http://www.gravatar.com/avatar/e64c7d89f26bd1972efa854d13d7dd61?s=80&d=identicon',
      },
      dateTitle: '2017-03-23T23:02:00.807Z',
      dateReadable: '12 hours ago',
    });
  });

  afterEach(() => {
    vm.$destroy();
  });

  it('renders provided action text', () => {
    expect(vm.$el.textContent).toContain('Merged by');
  });

  it('renders author', () => {
    expect(vm.$el.textContent).toContain('Administrator');
  });

  it('renders provided time', () => {
    expect(vm.$el.querySelector('time').getAttribute('title')).toEqual('2017-03-23T23:02:00.807Z');
    expect(vm.$el.querySelector('time').textContent.trim()).toEqual('12 hours ago');
  });
});
