/**
 * @vitest-environment jsdom
 * @vitest-environment-options { "url": "https://hub.opencsg.com/models/test-namespace/test-repo" }
 */
import { describe, it, expect, vi, beforeEach } from "vitest";
import { mount, flushPromises } from "@vue/test-utils";
import BranchDropdown from "../../shared/BranchDropdown.vue";

let { mockFetchApi } = vi.hoisted(() => {
  return {
    mockFetchApi: vi.fn(() => ({
      json: () => Promise.resolve({
        data: { value: { data: [{ name: "main" }, { name: "dev" }] } },
        error: { value: null }
      })
    }))
  };
});

vi.mock('../../../packs/useFetchApi', () => ({
  default: mockFetchApi
}));

const mockResetFileNotFound = vi.fn();
vi.mock('../../../stores/RepoTabStore', () => ({
  useRepoTabStore: () => ({
    resetFileNotFound: mockResetFileNotFound
  })
}));

describe("BranchDropdown", () => {
  let wrapper;

  beforeEach(async () => {
    mockFetchApi.mockClear();
    mockResetFileNotFound.mockClear();

    wrapper = mount(BranchDropdown, {
      props: {
        currentBranch: "main"
      }
    });
  });

  it("mounts correctly", () => {
    expect(wrapper.exists()).toBe(true);
  });

  it("fetches branches on mount and resolves them", async () => {
    expect(mockFetchApi).toHaveBeenCalled();
    await flushPromises();
    expect(wrapper.vm.branches).toEqual([{ name: "main" }, { name: "dev" }]);
  });

  it("triggers changeBranch event and resets file not found state when clicked", async () => {
    await flushPromises();
    await wrapper.vm.handleClick("dev");
    expect(wrapper.emitted().changeBranch[0]).toEqual(["dev"]);
    expect(mockResetFileNotFound).toHaveBeenCalled();
  });

  it("automatically emits changeBranch to default branch if props.currentBranch does not exist in resolved branch list", async () => {
    // Reset wrapper with non-existent current branch
    wrapper = mount(BranchDropdown, {
      props: {
        currentBranch: "non-existent"
      }
    });
    await flushPromises();
    expect(wrapper.emitted().changeBranch[0]).toEqual(["main"]); // fallback to index 0 branch
  });
});
