import { shallowMount, RouterLinkStub } from "@vue/test-utils";
import Menu from "../user_settings/Menu.vue";

describe("Menu.vue", () => {
  it("renders correctly with props", () => {
    const propsData = {
      name: "John Doe",
      avatar: "avatar-url.jpg",
    };
    const wrapper = shallowMount(Menu, {
      props: propsData,
      global: {
        components: {
          "router-link": RouterLinkStub,
          "el-avatar": {
            template: "<div></div>",
          },
        },
      },
    });
    expect(wrapper.html()).toContain(propsData.name);
  });

  it("renders menu items correctly", () => {
    const wrapper = shallowMount(Menu, {
      propsData: {
        name: "John",
        avatar: "/path/to/avatar.png",
      },
      mocks: {
        $route: {
          path: "/settings/account", // 模拟当前的路由路径
        },
      },
    });

    // 断言渲染的 menu item 是否包含正确的文本内容和样式类名
    expect(wrapper.html()).toContain("个人资料");
    expect(wrapper.html()).toContain("账户信息");
    expect(wrapper.html()).toContain("访问令牌");
    expect(wrapper.html()).toContain("SSH和GPG密钥");
    expect(wrapper.html()).toContain("账单");
  });
  it("returns correct menu class for active menu item", () => {
    const wrapper = shallowMount(Menu, {
      propsData: {
        name: "John Doe",
        avatar: "avatar-url.jpg",
      },
    });
    // 设置 window.location.pathname
    Object.defineProperty(window, "location", {
      value: {
        pathname: "/settings/profile",
      },
      writable: true,
    });
    // 调用 menuClass 方法并进行断言
    expect(wrapper.vm.menuClass("/settings/profile")).toBe(
      "text-[#303133] font-semibold"
    );
    // 还原 window.location.pathname
    Object.defineProperty(window, "location", {
      value: {
        pathname: null,
      },
    });
  });
  it('returns empty string for inactive menu item', () => {
    // 创建包含 menuClass 方法的浅渲染实例
    const wrapper = shallowMount(Menu);
    
    // 设置 window.location.pathname
    Object.defineProperty(window, 'location', {
      value: {
        pathname: '/home',
      },
      writable: true,
    });
    
    // 调用 menuClass 方法并进行断言
    expect(wrapper.vm.menuClass('/settings/profile')).toBe('');
    
    // 还原 window.location.pathname
    Object.defineProperty(window, 'location', {
      value: {
        pathname: null,
      },
    });
  });
});
